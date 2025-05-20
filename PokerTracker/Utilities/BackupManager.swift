//
//  BackupManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/25/25.
//

import Foundation

final class BackupManager {
    
    static let shared = BackupManager()
    private init() {}

    // MARK: – Paths & Constants

    private let fileManager = FileManager.default
    private let dateFormatter: DateFormatter = {
        let date = DateFormatter()
        date.dateFormat = "yyyyMMdd"
        return date
    }()
    private let lastBackupKey = "lastBackupDate"
    private let maxBackups = 12
    private var docs: URL { fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] }
    private var sessionsURL: URL { docs.appendingPathComponent("sessions_v2.json") }
    private var transactionsURL : URL { docs.appendingPathComponent("transactions.json") }
    private var bankrollsURL: URL { docs.appendingPathComponent("bankrolls.json") }

    private struct CombinedBackup: Codable {
        let sessions: [PokerSession_v2]
        let transactions: [BankrollTransaction]
        let bankrolls: [Bankroll]
    }

    // MARK: – Backup

    func performMonthlyBackupIfNeeded() {
        let now = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        
        if let last = UserDefaults.standard.object(forKey: lastBackupKey) as? Date, last > oneMonthAgo {
            return
        }
        
        // 1) Load your live sessions
        guard
            let sessionData = try? Data(contentsOf: sessionsURL),
            let sessions = try? JSONDecoder().decode([PokerSession_v2].self, from: sessionData),
            !sessions.isEmpty
                
        else {
            print("Backup skipped: no valid sessions to back up.")
            return
        }
        
        // 2) Load bankrolls (optional)
        var bankrolls: [Bankroll] = []
        if let bankrollData = try? Data(contentsOf: bankrollsURL), let decodedBankrolls = try? JSONDecoder().decode([Bankroll].self, from: bankrollData) {
            bankrolls = decodedBankrolls
        }
        
        var transactions: [BankrollTransaction] = []
        if let transactionsData = try? Data(contentsOf: transactionsURL), let decodedTransactions = try? JSONDecoder().decode([BankrollTransaction].self, from: transactionsData) {
            transactions = decodedTransactions
        }
        
        // 3) Create combined struct
        let combined = CombinedBackup(sessions: sessions, transactions: transactions, bankrolls: bankrolls)
        guard let backupData = try? JSONEncoder().encode(combined) else {
            print("Backup failed: couldn’t encode combined backup.")
            return
        }
        
        // 4) Write it out
        let stamp = dateFormatter.string(from: now)
        let backupName = "data_backup_\(stamp).json"
        let backupURL = docs.appendingPathComponent(backupName)
        
        do {
            try backupData.write(to: backupURL)
            UserDefaults.standard.set(now, forKey: lastBackupKey)
            print("Created backup: \(backupName)")
            
        } catch {
            print("Backup failed to write file: \(error)")
            return
        }
        
        pruneOldBackups()
    }

    private func pruneOldBackups() {
        guard let files = try? fileManager.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
        else { return }

        let backups = files.filter { $0.lastPathComponent.hasPrefix("data_backup_") && $0.pathExtension == "json" }

        guard backups.count > maxBackups else { return }

        let toDelete = backups.sorted { $0.lastPathComponent < $1.lastPathComponent }.prefix(backups.count - maxBackups)
        for url in toDelete {
            try? fileManager.removeItem(at: url)
            print("Deleted old backup: \(url.lastPathComponent)")
        }
    }

    // MARK: – Restore

    func restoreBackup(from file: URL, into viewModel: SessionsListViewModel) throws {
        let data = try Data(contentsOf: file)
        let combined = try JSONDecoder().decode(CombinedBackup.self, from: data)

        // 1) Merge top-level sessions without duplicates
        let existingSessionIDs = Set(viewModel.sessions.map { $0.id })
        let newSessions = combined.sessions.filter { !existingSessionIDs.contains($0.id) }
        viewModel.sessions.append(contentsOf: newSessions)
        viewModel.sessions.sort { $0.date > $1.date }
        print("Restored \(newSessions.count) new sessions.")

        // 2) Merge bankrolls
        var updated = viewModel.bankrolls
        for backupBankroll in combined.bankrolls {
            if let idx = updated.firstIndex(where: { $0.id == backupBankroll.id }) {
                // Merge sessions for that existing bankroll
                let existingBRSessionIDs = Set(updated[idx].sessions.map { $0.id })
                let toAddSessions = backupBankroll.sessions.filter { !existingBRSessionIDs.contains($0.id) }
                updated[idx].sessions.append(contentsOf: toAddSessions)
                updated[idx].sessions.sort { $0.date > $1.date }

                // Merge transactions (assuming BankrollTransaction has `id`)
                let existingTxnIDs = Set(updated[idx].transactions.map { $0.id })
                let toAddTxns = backupBankroll.transactions.filter { !existingTxnIDs.contains($0.id) }
                updated[idx].transactions.append(contentsOf: toAddTxns)

                print("Merged \(toAddSessions.count) sessions and \(toAddTxns.count) transactions into bankroll “\(backupBankroll.name)”.")
                
            } else {
                // Create new bankroll
                updated.append(backupBankroll)
                print("Added new bankroll “\(backupBankroll.name)” with \(backupBankroll.sessions.count) sessions.")
            }
        }
        
        // 3) Merge top-level transactions (not tied to any bankroll)
        let existingTransactionIDs = Set(viewModel.transactions.map { $0.id })
        let newTransactions = combined.transactions.filter { !existingTransactionIDs.contains($0.id) }

        viewModel.transactions.append(contentsOf: newTransactions)
        viewModel.transactions.sort { $0.date > $1.date }

        print("Restored \(newTransactions.count) top-level transactions.")

        viewModel.bankrolls = updated
        viewModel.saveNewSessions()
        viewModel.saveTransactions()
        viewModel.saveBankrolls()
        viewModel.writeToWidget()
    }
}
