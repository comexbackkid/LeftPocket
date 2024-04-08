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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack {
                
                title
                
                bodyText
                
                navigationLinks
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
            
            Text("Currently, Left Pocket only supports data in CSV format exported from Poker Bankroll Tracker & Pokerbase. Every poker app formats their CSV data differently and you may be required to lightly modify the contents of the file.\n\n__WARNING:__ Importing data will erase & overwrite any existing sessions you've saved on Left Pocket.")
                .bodyStyle()
                .opacity(0.8)
                .padding(.top, 1)
        }
        .padding(.horizontal)
    }
    
    var navigationLinks: some View {
        
        VStack (spacing: 15) {
            
            NavigationLink {
                PokerBankrollTrackerImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Poker Bankroll Tracker")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            NavigationLink {
                PokerbaseImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Pokerbase")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            NavigationLink {
                LeftPocketImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Left Pocket")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(25)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        .padding(.top, 40)
    }
}

struct PokerBankrollTrackerImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: String?
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Poker Bankroll Tracker Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("Please be sure to follow each step and read carefully. Poker Bankroll Tracker allows for exporting of session notes and you will need to account for how the text is formatted.")
                    .bodyStyle()
                    .opacity(0.8)
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    Text("1. Export CSV from Poker Bankroll Tracker.")
                        
                    
                    Text("2. Open the CSV on your computer. In the notes column, you'll need to __remove ALL COMMAS and SOFT RETURNS__. Text must be on one line.")
                    
                    Text("3. Export this new file to a folder in your iCloud Drive, using UTF-8 encoding.")
                    
                    Text("4. Tap the Import CSV Data button below.")
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
                .opacity(0.8)
                .lineSpacing(5)
                .padding(.vertical, 20)
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
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
                        
            do {
                let selectedURL = try result.get()
                let csvData = try Data(contentsOf: selectedURL)
                let csvImporter = CSVImporter()
                let importedSessions = try csvImporter.importCSVFromPokerBankrollTracker(data: csvData)
                
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

struct PokerbaseImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: String?
    @State private var stakes = "1/2"
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Pokerbase Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("Please be sure to follow each step and read carefully. At this time Pokerbase exports do not include tournament info, stakes, or notes. If your sessions were only one stake, you can select it from the picker below & it'll be applied to your entire import.")
                    .bodyStyle()
                    .opacity(0.8)
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    Text("1. Generate a report & include every column.")
                    
                    Text("2. Save the CSV file to a folder in your iCloud Drive using UTF-8 encoding.")
                    
                    Text("3. Choose from the game stakes below.")
                    
                    Text("4. Tap the Import CSV Data button below.")
                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
                .opacity(0.8)
                .lineSpacing(5)
                .padding(.top, 20)
            }
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                Text("Stakes")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Menu {
                    
                    Picker("Picker", selection: $stakes) {
                        Text("1/2").tag("1/2")
                        Text("2/2").tag("2/2")
                        Text("1/3").tag("1/3")
                        Text("2/3").tag("2/3")
                        Text("2/5").tag("2/5")
                        Text("5/5").tag("5/5")
                        Text("5/10").tag("5/10")
                        Text("10/10").tag("10/10")
                        Text("10/20").tag("10/20")
                        Text("20/40").tag("20/40")
                        Text("25/50").tag("25/50")
                    }
                    
                } label: {
                    
                    if stakes.isEmpty {
                        Text("Please select ›")
                            .bodyStyle()
                            .fixedSize()
                    } else {
                        
                        Text(stakes)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                    }
                }
                .foregroundColor(stakes.isEmpty ? .brandPrimary : .brandWhite)
                .buttonStyle(PlainButtonStyle())
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .padding(.top, 30)
            .padding(.horizontal)
            .padding(.trailing, 5)
            
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
                .padding(.bottom, 80)
                
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
                .padding(.bottom, 80)
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
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
                        
            do {
                let selectedURL = try result.get()
                let csvData = try Data(contentsOf: selectedURL)
                let csvImporter = CSVImporter()
                let importedSessions = try csvImporter.importCSVFromPokerbase(data: csvData, selectedStakes: stakes)
                
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

struct LeftPocketImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: String?
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Left Pocket Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("If you have backed up data from a previous Left Pocket CSV export you can import the data from this screen. Follow the steps below.")
                    .bodyStyle()
                    .opacity(0.8)
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    Text("1. Save the CSV file to your iCloud Drive.")
                    
                    Text("2. Do NOT change or modify the contents of the CSV file.")
                    
                    Text("3. Tap the Import CSV Data button below.")

                }
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
                .opacity(0.8)
                .lineSpacing(5)
                .padding(.vertical, 20)
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
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
                        
            do {
                let selectedURL = try result.get()
                let csvData = try Data(contentsOf: selectedURL)
                let csvImporter = CSVImporter()
                let importedSessions = try csvImporter.importCSVFromLeftPocket(data: csvData)
                
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
        LeftPocketImportView()
            .preferredColorScheme(.dark)
        PokerBankrollTrackerImportView()
            .preferredColorScheme(.dark)
        PokerbaseImportView()
            .preferredColorScheme(.dark)
        
    }
}
