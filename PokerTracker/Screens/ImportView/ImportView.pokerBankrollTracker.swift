//
//  ImportView.pokerBankrollTracker.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/20/25.
//

import SwiftUI
import Lottie
import MessageUI

struct PokerBankrollTrackerImportView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showFileImporter = false
    @State private var showAlertModal = false
    @State private var errorMessage: String?
    @State private var showImportError = false
    @State private var failedFileURL: URL? = nil
    @State private var showMailComposer = false
    @State private var showSuccessMessage: LocalizedStringResource = ""
    @State private var playbackMode = LottiePlaybackMode.paused(at: .progress(0))
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack {
                
                VStack (alignment: .leading) {
                    
                    Text("Poker Bankroll Tracker Import")
                        .subtitleStyle()
                        .bold()
                        .padding(.top, 10)
                    
                    Text("Please be sure to follow each step and read carefully. You'll need to lightly modify your file before import.")
                        .bodyStyle()
                        .padding(.top, 1)
                        .padding(.bottom, 10)
                    
                    helpButton
                    
                    instructions
                    
                }
                .padding(.horizontal)
                
                importButton
                
                HStack {
                    Spacer()
                }
            }
            .padding(.bottom, 80)
        }
        .sheet(isPresented: $showImportError, content: {
            AlertModal(alertTitle: "Uh oh!",
                       message: "We've hit a snag with the import. Please review the instructions and try again. Or, send in your file via email and we'll process it for you in under 2 hours.",
                       image: "exclamationmark.triangle",
                       imageColor: .orange,
                       buttonText: "Upload File via Email",
                       actionToPerform: {
                showImportError = false
                showMailComposer = true
            },
                       cancelButton: true)
            .presentationDetents([.height(400)])
            .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showMailComposer) {
            if MFMailComposeViewController.canSendMail() {
                MailView(
                    recipients: ["leftpocketpoker@gmail.com"],
                    subject: "CSV Import Failure – Poker Bankroll Tracker",
                    body: """
                            Hello,
                            
                            My Poker Bankroll Tracker CSV Import failed. Please find the attached file for processing.
                            
                            You can send the new file to this email address.
                            
                            """,
                    attachmentURL: failedFileURL
                    
                ) { result, error in
                    showMailComposer = false
                }
                
            } else {
                // Fallback: open a mailto: link so the user's default mail client appears
                VStack(spacing: 16) {
                    Text("Mail is not configured for sending directly from the app. Please attach CSV file manually after pressing the button below.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Compose in Your Mail App") {
                        // Construct a mailto: URL
                        let to = "leftpocketpoker@gmail.com"
                        let subject = "CSV Import Failure – Poker Bankroll Tracker"
                        if let mailtoURL = URL(string: "mailto:\(to)?subject=\(subject)") {
                            openURL(mailtoURL)
                        }
                        showMailComposer = false
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.brandPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .background(Color.brandBackground)
        .overlay {
            VStack {
                LottieView(animation: .named("Lottie-Confetti"))
                    .playbackMode(playbackMode)
                    .animationDidFinish { _ in
                        playbackMode = .paused
                    }
                
                Spacer()
            }
            .offset(y: -160)
            .allowsHitTesting(false)
        }
        .sensoryFeedback(.success, trigger: showAlertModal)
    }
    
    var helpButton: some View {
        Button {
            guard let url = URL(string: "https://iridescent-cheetah-aae.notion.site/Poker-Bankroll-Tracker-1dc9452cf3e580f9969aedbf22a31a42") else {
                return
            }
            
            openURL(url)
            
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "play.tv.fill")
                Text("Tap for Video Tutorial")
                    .bodyStyle()
            }
            .font(.callout.weight(.semibold))
            .foregroundColor(Color.brandPrimary)
            .underline()
        }
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                
                Image(systemName: "1.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Export CSV from Poker Bankroll Tracker.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "2.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Open the file as a spreadsheet on your computer or iPhone. The following columns must be cleared of data in order to process the file: sessionnote, notes, chipgraph, and updatetimes. DO NOT remove the columns entirely, just the contents in the cells.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "3.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Choose File > Export To… > CSV…")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "4.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Under \"Text Encoding,\" choose Unicode (UTF-8) from the menu.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "5.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Tap the Import CSV Data button below.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
        }
        .lineSpacing(5)
        .padding(.vertical, 30)
        .sheet(isPresented: $showAlertModal) {
            AlertModal(message: showSuccessMessage, image: "checkmark.circle", imageColor: .green)
                .presentationDetents([.height(280)])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                .presentationDragIndicator(.visible)
        }
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
                
                failedFileURL = selectedURL
                
                if selectedURL.startAccessingSecurityScopedResource() {
                    let csvData = try Data(contentsOf: selectedURL)
                    let csvImporter = CSVImporter()
                    let importedSessions = try csvImporter.importCSVFromPokerBankrollTracker(data: csvData)
                    
                    // Overwrite any current Sessions, if there are any, and set our array of Sessions to the imported data
                    vm.sessions += importedSessions
                    vm.sessions.sort(by: {$0.date > $1.date})
                    showSuccessMessage = "All sessions imported successfully."
                    showAlertModal = true
                    playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
                }
                
                selectedURL.stopAccessingSecurityScopedResource()
                
            } catch let error as URLError {
                // Handle URLError from the fileImporter
                errorMessage = "URL Error: \(error.localizedDescription)"
                showImportError = true
                print("URL Error: \(error)")
                
            } catch let error as CSVImporter.ImportError {
                // Handle specific CSV import errors from our class
                switch error {
                case .invalidData: errorMessage = "Error: Invalid Data"
                case .parsingFailed: errorMessage = "Error: Parsing Failed"
                case .saveFailed: errorMessage = "Error: Failed to Save Data"
                }
                showImportError = true
                print("CSV Import Error: \(error)")
                
            } catch {
                // Handle other errors
                errorMessage = error.localizedDescription
                showImportError = true
                print("Error importing file: \(error)")
            }
        })
    }
}

struct PokerBankrollTrackerImportView_Preview: PreviewProvider {
    static var previews: some View {
        PokerBankrollTrackerImportView()
            .preferredColorScheme(.dark)
    }
}
