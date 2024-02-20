//
//  ImportView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/5/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: String?
    
    var body: some View {
        
            ScrollView (.vertical) {
                
                VStack {
                    
                    title
                    
                    bodyText
                    
                    importButton
                    
                    if let errorMessage {
                        
                        VStack {
                            Text("Uh oh! There was a problem.")
                            Text(errorMessage)
                            Image(systemName: "x.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.top, 1)
                                .foregroundColor(.red)
                        }
                        
                    } else if let showSuccessMessage {
                        
                        VStack {
                            Text("Success!")
                            Text(showSuccessMessage)
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.top, 1)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .background(Color.brandBackground)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Import Data")
                .titleStyle()
                .padding(.top, -37)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var bodyText: some View {
        
        VStack (alignment: .leading) {
            
            Text("Please Read Carefully ✋")
                .subtitleStyle()
                .bold()
                .padding(.top, 10)
            
            Text("Currently, Left Pocket only supports data in CSV format exported from Poker Bankroll Tracker. You may need to lightly modify the contents of the file. Make sure to follow the steps below closely.")
                .bodyStyle()
                .opacity(0.8)
                .padding(.top, 1)
            
            VStack (alignment: .leading) {
                
                Text("1. Export CSV from Poker Bankroll Tracker\n2. Open the CSV on your computer. In the notes column, you'll need to __remove ALL COMMAS and SOFT RETURNS__. Text must be on one line.\n3. Export this new file to a folder in your iCloud Drive, using UTF-8 encoding.\n4. Tap the Import CSV Data button below.")
                    .calloutStyle()
                    .opacity(0.8)
                    .lineSpacing(5)
                    .padding(.vertical, 20)
            }
        }
        .padding(.horizontal)
    }
    
    var importButton: some View {
        
        Button {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            showFileImporter = true
            
        } label: {
            
            PrimaryButton(title: "Import CSV Data")
            
        }
        .padding(.bottom, 20)
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
                        
            do {
                let selectedURL = try result.get()
                let csvData = try Data(contentsOf: selectedURL)
                let csvImporter = CSVImporter()
                let importedSessions = try csvImporter.importCSV(data: csvData)
                
                // Overwrite any current Sessions, if there are any, and set our array of Sessions to the imported data
                vm.sessions += importedSessions
                vm.sessions.sort(by: {$0.date > $1.date})
                showSuccessMessage = "All sessions imported successfully."
                
            } catch let error as URLError {
                
                // Handle URLError from the fileImporter
                errorMessage = "URL Error: \(error.localizedDescription)"
                print("URL Error: \(error)")
                
            } catch let error as CSVImporter.ImportError {
                
                // Handle specific CSV import errors from our class
                switch error {
                case .invalidData:
                    errorMessage = "Error: Invalid Data"
                case .parsingFailed:
                    errorMessage = "Error: Parsing Failed"
                case .saveFailed:
                    errorMessage = "Error: Failed to Save Data"
                }
                print("CSV Import Error: \(error)")
                
            } catch {
                
                // Handle other errors
                errorMessage = error.localizedDescription
                print("Error importing file: \(error)")
            }
        })
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView()
            .preferredColorScheme(.dark)
    }
}
