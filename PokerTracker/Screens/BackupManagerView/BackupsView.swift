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
    @State private var showErrorAlert = false
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
                    emptyView
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
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.large)
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
                            do {
                                try BackupManager.shared.restoreBackup(from: fileURL, into: viewModel)
                                showRestoreSuccessAlertModal = true
                                
                            } catch {
                                print("Failed to load sessions: \(error.localizedDescription)")
                                showErrorAlert = true
                            }
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
                .alert(Text("Uh Oh!"), isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) {
                        showErrorAlert = false
                    }
                    
                } message: {
                    Text("An error occurred while restoring your backup. Contact support for assistance.")
                }
            }
        }
        .onAppear { if useDummyData { generateDummyBackups() } else { fetchBackupFiles() } }
        .background(Color.brandBackground)
    }
    
    var emptyView: some View {
        
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
    
    private func fetchBackupFiles() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let allFiles = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            backupFiles = allFiles
                .filter { $0.lastPathComponent.hasPrefix("data_backup_") && $0.pathExtension == "json" }
                .sorted { $0.lastPathComponent > $1.lastPathComponent }
            
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
        let base  = file.deletingPathExtension().lastPathComponent
        let parts = base.split(separator: "_")
        
        guard let stamp = parts.last, stamp.count == 8 else {
            return "Unknown Date"
        }
        
        let yearStr  = String(stamp.prefix(4))
        let monthStr = String(stamp.dropFirst(4).prefix(2))
        
        guard let year  = Int(yearStr), let month = Int(monthStr), (1...12).contains(month) else {
            return "Unknown Date"
        }
        
        let formatter = DateFormatter()
        let monthName = formatter.monthSymbols[month - 1]
        
        return "\(monthName) \(year)"
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
