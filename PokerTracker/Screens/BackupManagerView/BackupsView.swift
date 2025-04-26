//
//  BackupsView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/25/25.
//

import SwiftUI

struct BackupsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var backupFiles: [URL] = []
    @State private var useDummyData = false
    @State private var showRestoreWarning = false
    @State private var showRestoreSuccessAlertModal = false
    @State private var selectedBackup: URL?
    
    var body: some View {
        
        NavigationStack {
            
            if backupFiles.isEmpty {
                VStack {
                    
                    screenTitle
                    
                    Spacer()
                }
                .overlay {
                    VStack {
                        Image(systemName: "doc.text")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundStyle(.secondary)
                        
                        Text("No backups generated yet")
                            .cardTitleStyle()
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.top)
                            .padding(.bottom, 5)
                        
                        Text("Automatic backups of your session data are generated every month. After 30 days you will see your backups on this screen.")
                            .foregroundColor(.secondary)
                            .subHeadlineStyle()
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 20)
                }
                
            } else {
                List {
                    
                    screenTitle
                    
                    ForEach(backupFiles, id: \.self) { file in
                        HStack {
                            
                            Image(systemName: "doc.text")
                                .foregroundColor(.brandPrimary)
                                .padding(.trailing, 12)
                            
                            VStack (alignment: .leading) {
                                
                                Text("\(monthAndYear(for: file))")
                                    .bodyStyle()
                                
                                Text(file.lastPathComponent)
                                    .captionStyle()
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            
                            Spacer()
                            
                            Menu {
                                Button("Restore from Backup") {
                                    let impact = UIImpactFeedbackGenerator(style: .soft)
                                    impact.impactOccurred()
                                    selectedBackup = file
                                    showRestoreWarning = true
                                }
                                
                            } label: {
                                Image(systemName: "ellipsis")
                            }
                        }
                        .padding(.bottom)
                        .listRowBackground(Color.brandBackground)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    }
                }
                .listRowSpacing(10)
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.brandBackground)
                .accentColor(.brandPrimary)
                .alert(Text("Are You Sure?"), isPresented: $showRestoreWarning) {
                    
                    Button("Yes", role: .destructive) {
                        if let fileURL = selectedBackup {
                            restoreBackup(fileURL)
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {
                        selectedBackup = nil
                    }
                    
                } message: {
                    Text("Pressing Yes below will restore your data from the selected backup and merge with your current session data.")
                }
                .sheet(isPresented: $showRestoreSuccessAlertModal, content: {
                    AlertModal(message: "You successfully restored your data.", image: "checkmark.circle", imageColor: .green)
                        .presentationDetents([.height(280)])
                        .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                        .presentationDragIndicator(.visible)
                })
            }
        }
        .onAppear { fetchBackupFiles() }
        .background(Color.brandBackground)
    }
    
    private func fetchBackupFiles() {
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            let allFiles = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            backupFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("sessions_backup_") }
                .sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
            
        } catch {
            print("Failed to fetch backup files: \(error.localizedDescription)")
        }
    }
    
    private func generateDummyBackups() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let today = Date()
        backupFiles = (0..<12).map { monthOffset in
            let date = Calendar.current.date(byAdding: .month, value: -monthOffset, to: today)!
            let dateString = formatter.string(from: date)
            return URL(fileURLWithPath: "sessions_backup_\(dateString).json")
        }
    }
    
    private func monthAndYear(for file: URL) -> String {
        let filename = file.lastPathComponent
        
        // Expected format: "sessions_backup_YYYYMMDD.json"
        let yearStartIndex = filename.index(filename.startIndex, offsetBy: 16)
        let yearEndIndex = filename.index(yearStartIndex, offsetBy: 4)
        let monthStartIndex = yearEndIndex
        let monthEndIndex = filename.index(monthStartIndex, offsetBy: 2)
        
        let yearSubstring = filename[yearStartIndex..<yearEndIndex]
        let monthSubstring = filename[monthStartIndex..<monthEndIndex]
        
        if let monthNumber = Int(monthSubstring),
           let yearNumber = Int(yearSubstring),
           (1...12).contains(monthNumber) {
            
            let formatter = DateFormatter()
            let monthName = formatter.monthSymbols[monthNumber - 1]
            
            return "\(monthName) \(yearNumber)"
        } else {
            return "Unknown Date"
        }
    }
    
    private func restoreBackup(_ file: URL) {
        
        do {
            let data = try Data(contentsOf: file)
            let decodedSessions = try JSONDecoder().decode([PokerSession_v2].self, from: data)
            
            let existingIDs = Set(viewModel.sessions.map { $0.id })
            let newSessions = decodedSessions.filter { !existingIDs.contains($0.id) }
            
            viewModel.sessions += newSessions
            viewModel.sessions.sort { $0.date < $1.date }
            showRestoreSuccessAlertModal = true
            print("Restored \(newSessions.count) new sessions from backup.")
            
        } catch {
            print("Failed to load sessions: \(error.localizedDescription)")
        }
    }
    
    var screenTitle: some View {
        
        HStack (alignment: .center) {
            Text("Backups")
                .titleStyle()
            
            Spacer()
        }
        .padding(.horizontal)
        .minimumScaleFactor(0.9)
        .lineLimit(1)
        .listRowBackground(Color.brandBackground)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

#Preview {
    BackupsView()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
