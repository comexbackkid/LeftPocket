//
//  BackupsView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/25/25.
//

import SwiftUI

struct BackupsView: View {
    
    @State private var backupFiles: [URL] = []
    @State private var useDummyData = true
    
    var body: some View {
        
        NavigationStack {
            
            if backupFiles.isEmpty {
                screenTitle
            }
            
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
                                //
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
            .onAppear {
                if useDummyData {
                    generateDummyBackups()
                } else {
                    fetchBackupFiles()
                }
            }
        }
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
                .sorted(by: { $0.lastPathComponent > $1.lastPathComponent }) // Newest first
            
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
        .preferredColorScheme(.dark)
}
