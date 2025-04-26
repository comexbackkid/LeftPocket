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
    
    private let fileManager = FileManager.default
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    private let maxBackups = 12
    private let sessionsFileName = "sessions_v2.json"
    private let lastBackupKey = "lastBackupDate"
    
    func performMonthlyBackupIfNeeded() {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let now = Date()
        let lastBackup = UserDefaults.standard.object(forKey: lastBackupKey) as? Date
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        
        if let lastBackup = lastBackup, lastBackup > oneMonthAgo {
            return // Skip — backup already performed this month
        }
        
        let sessionsFile = documentsURL.appendingPathComponent(sessionsFileName)
        
        guard fileManager.fileExists(atPath: sessionsFile.path) else {
            return // No sessions file to back up
        }
        
        do {
            let data = try Data(contentsOf: sessionsFile)
            let decodedSessions = try JSONDecoder().decode([PokerSession_v2].self, from: data)
            
            guard !decodedSessions.isEmpty else {
                print("Backup skipped: sessions_v2.json is empty.")
                return
            }
            
        } catch {
            print("Backup skipped: failed to decode sessions: \(error.localizedDescription)")
            return
        }
        
        // Create backup file name
        let dateString = dateFormatter.string(from: now)
        let backupFileName = "sessions_backup_\(dateString).json"
        let backupFileURL = documentsURL.appendingPathComponent(backupFileName)
        
        do {
            try fileManager.copyItem(at: sessionsFile, to: backupFileURL)
            print("Backup created: \(backupFileURL.lastPathComponent)")
            UserDefaults.standard.set(now, forKey: lastBackupKey)
            
        } catch {
            print("Failed to create backup: \(error.localizedDescription)")
        }
        
        enforceBackupLimit(in: documentsURL)
    }
    
    private func enforceBackupLimit(in directory: URL) {
        do {
            let allFiles = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            let backupFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("sessions_backup_") }
            
            if backupFiles.count > maxBackups {
                let sorted = backupFiles.sorted(by: {
                    $0.lastPathComponent < $1.lastPathComponent // oldest first
                })
                let filesToDelete = sorted.prefix(backupFiles.count - maxBackups)
                
                for file in filesToDelete {
                    try? fileManager.removeItem(at: file)
                    print("Deleted old backup: \(file.lastPathComponent)")
                }
            }
        } catch {
            print("Failed to prune old backups: \(error.localizedDescription)")
        }
    }
}
