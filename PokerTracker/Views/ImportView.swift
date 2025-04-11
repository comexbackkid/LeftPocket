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
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var bodyText: some View {
        
        VStack (alignment: .leading) {
            
            Text("Left Pocket supports data in CSV format from various bankroll trackers. These apps all handle their data differently, and you'll need to lightly modify the contents of their exported file on your computer before import.")
                .bodyStyle()
        }
        .padding(.horizontal)
    }
    
    var navigationLinks: some View {
        
        VStack (spacing: 15) {
            
//            NavigationLink {
//                PokerIncomeImportView()
//            } label: {
//                HStack {
//                    VStack (alignment: .leading) {
//                        HStack {
//                            
//                            Image(systemName: "tray.and.arrow.down.fill")
//                                .frame(width: 20)
//                                .fontWeight(.black)
//                                .padding(.trailing, 5)
//                                .foregroundColor(.secondary)
//                            
//                            Text("Poker Income")
//                                .bodyStyle()
//                                .bold()
//                            
//                            Spacer()
//                            
//                            Text("›")
//                                .font(.title2)
//                        }
//                    }
//                    Spacer()
//                }
//            }
//            .buttonStyle(PlainButtonStyle())
//            
//            Divider()
            
            NavigationLink {
                BinkPokerImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Bink Poker")
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
                PokerAnalyticsImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Poker Analytics")
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
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top, 40)
    }
}

struct BinkPokerImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: String?
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Bink Poker Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("Bink exports currently do not contain specific start & end times. For that reason, all Sessions will default to 12:00pm and end according to their duration.")
                    .bodyStyle()
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    HStack {
                        
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("After you've exported your CSV, begin by making sure the Notes column is cleared of any text.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Save & upload the CSV file to your iCloud Drive in UTF-8 format.")
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
                    let importedSessions = try csvImporter.importCSVFromBinkPoker(data: csvData)
                    
                    // Overwrite any current Sessions, if there are any, and set our array of Sessions to the imported data
                    vm.sessions += importedSessions
                    vm.sessions.sort(by: {$0.date > $1.date})
                    showSuccessMessage = "All sessions imported successfully."
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

struct PokerBankrollTrackerImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage = ""
    @State private var showAlertModal = false
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Poker Bankroll Tracker Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("Please be sure to follow each step and read carefully. Poker Bankroll Tracker allows for exporting of session notes, and you'll need to remove them from the CSV file prior to import.")
                    .bodyStyle()
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    HStack {
                        
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Export CSV from Poker Bankroll Tracker.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Open the CSV on your computer. In the notes column, __delete each cell__ containing any text of any kind.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Export this new file, & save it to your iCloud Drive, using UTF-8 encoding.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "4.circle.fill")
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
                    AlertModal(message: showSuccessMessage)
                        .presentationDetents([.height(210)])
                        .presentationBackground(.ultraThinMaterial)
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
                    let importedSessions = try csvImporter.importCSVFromPokerBankrollTracker(data: csvData)
                    
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
                case .invalidData: errorMessage = "Error: Invalid Data"
                case .parsingFailed: errorMessage = "Error: Parsing Failed"
                case .saveFailed: errorMessage = "Error: Failed to Save Data"
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
                
                Text("Please be sure to follow each step and read carefully. Unfortunately exports from Pokerbase do not include tournament info, or stakes info. If you only played one game stake, you can select it from the picker below & it'll be applied to your entire import.")
                    .bodyStyle()
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    HStack {
                        
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Generate a report & include every column.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Save the CSV file to a folder in your iCloud Drive using UTF-8 encoding.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Choose from the game stakes below.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "4.circle.fill")
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
        .padding(.horizontal)
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
                        
            do {
                let selectedURL = try result.get()
                
                if selectedURL.startAccessingSecurityScopedResource() {
                    let csvData = try Data(contentsOf: selectedURL)
                    let csvImporter = CSVImporter()
                    let importedSessions = try csvImporter.importCSVFromPokerbase(data: csvData, selectedStakes: stakes)
                    
                    // Overwrite any current Sessions, if there are any, and set our array of Sessions to the imported data
                    vm.sessions += importedSessions
                    vm.sessions.sort(by: {$0.date > $1.date})
                    showSuccessMessage = "All sessions imported successfully."
                }
                
                selectedURL.stopAccessingSecurityScopedResource()
                
            } catch let error as URLError {
                // Handle URLError from the fileImporter
                errorMessage = "URL Error: \(error.localizedDescription)"
                print("URL Error: \(error)")
                
            } catch let error as CSVImporter.ImportError {
                // Handle specific CSV import errors from our class
                switch error {
                case .invalidData: errorMessage = "Error: Invalid Data"
                case .parsingFailed: errorMessage = "Error: Parsing Failed"
                case .saveFailed: errorMessage = "Error: Failed to Save Data"
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
                    AlertModal(message: showSuccessMessage)
                        .presentationDetents([.height(210)])
                        .presentationBackground(.ultraThinMaterial)
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

struct PokerAnalyticsImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    @State private var showFileImporter = false
    @State private var showAlertModal = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage = ""
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Poker Analytics Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("Please be sure to follow each step and read carefully. Poker Analytics allows for exporting of session comments and you will need to account for how the text is formatted.")
                    .bodyStyle()
                    .padding(.top, 1)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    HStack {
                        
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("In Poker Analytics, from Settings navigate to Export Data. Choose Sessions (CSV).")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Open the CSV on your computer. In the Comment column, __delete each cell__ containing any text of any kind.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Export this new file to a folder in your iCloud Drive, using UTF-8 encoding.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        
                        Image(systemName: "4.circle.fill")
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
                    AlertModal(message: showSuccessMessage)
                        .presentationDetents([.height(210)])
                        .presentationBackground(.ultraThinMaterial)
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
        .padding(.horizontal)
        .padding(.bottom, 20)
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
                        
            do {
                let selectedURL = try result.get()
                
                if selectedURL.startAccessingSecurityScopedResource() {
                    let csvData = try Data(contentsOf: selectedURL)
                    let csvImporter = CSVImporter()
                    let importedSessions = try csvImporter.importCSVFromPokerAnalytics(data: csvData)
                    
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
                case .invalidData: errorMessage = "Error: Invalid Data"
                case .parsingFailed: errorMessage = "Error: Parsing Failed"
                case .saveFailed: errorMessage = "Error: Failed to Save Data"
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
        LeftPocketImportView()
            .preferredColorScheme(.dark)
    }
}
