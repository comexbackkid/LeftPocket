//
//  ImportView.leftPocket.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/20/25.
//

import SwiftUI

struct LeftPocketImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showFileImporter = false
    @State private var showAlertModal = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: String = ""
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Left Pocket Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("If you have backed up data from a previous Left Pocket CSV export you can import the data from this screen. Follow the steps below.")
                    .bodyStyle()
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    HStack {
                        
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("If you're importing a CSV that contains Sessions with notes, you'll need to either remove all commas from the notes column, or just delete the cell contents.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Save or upload the CSV file to your iCloud Drive in UTF-8 format.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Tap the Import CSV Data button below.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }

                }
                .lineSpacing(5)
                .padding(.vertical, 20)
                .sheet(isPresented: $showAlertModal) {
                    AlertModal(message: showSuccessMessage, image: "checkmark.circle", imageColor: .green)
                        .presentationDetents([.height(280)])
                        .presentationBackground(.ultraThinMaterial)
                        .presentationDragIndicator(.visible)
                }
            }
            .padding(.horizontal)
            
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
                .padding(.horizontal)
            }
            
            HStack {
                Spacer()
            }
        }
        .background(Color.brandBackground)
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
        .padding(.horizontal)
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
                        
            do {
                let selectedURL = try result.get()
                
                if selectedURL.startAccessingSecurityScopedResource() {
                    let csvData = try Data(contentsOf: selectedURL)
                    let csvImporter = CSVImporter()
                    let importedSessions = try csvImporter.importCSVFromLeftPocket(data: csvData)
                    
                    // Overwrite any current Sessions, if there are any, and set our array of Sessions to the imported data
                    vm.sessions += importedSessions
                    vm.sessions.sort(by: {$0.date > $1.date})
                    showSuccessMessage = "All sessions imported successfully."
                    showAlertModal = true
                }
                
                selectedURL.stopAccessingSecurityScopedResource()
                
            } catch let error as URLError {
                // Handle URLError from the fileImporter
                errorMessage = "URL Error: \(error.localizedDescription)"
                print("URL Error: \(error)")
                
            } catch let error as CSVImporter.ImportError {
                // Handle specific CSV import errors from our class
                switch error {
                case .invalidData: errorMessage = "Error: Invalid Data. Contact Support for assistance."
                case .parsingFailed: errorMessage = "Error: Parsing Failed. Ensure correct number of columns & formatting in each cell. Contact Support for assistance."
                case .saveFailed: errorMessage = "Error: Failed to Save Data. Contact Support for assistance."
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
