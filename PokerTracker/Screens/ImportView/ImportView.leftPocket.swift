//
//  ImportView.leftPocket.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/20/25.
//

import SwiftUI
import Lottie
import MessageUI

struct LeftPocketImportView: View {
    
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
            
            VStack (alignment: .leading) {
                
                Text("Left Pocket Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("If you have backed up data from a previous Left Pocket CSV export you can import the data from this screen. Follow the steps below.")
                    .bodyStyle()
                    .padding(.top, 1)
                
                instructions
                
            }
            .padding(.horizontal)
            
            importButton
            
            HStack {
                Spacer()
            }
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
                    subject: "CSV Import Failure – Left Pocket",
                    body: """
                            Hello,
                            
                            My Left Pocket CSV Import failed. Please find the attached file for processing.
                            
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
                        let subject = "CSV Import Failure – Left Pocket"
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
    
    var instructions: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                
                Image(systemName: "1.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("If you're importing a CSV that contains Sessions with notes, you'll need to either remove all commas from the notes column, or just delete the cell contents.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "2.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Save or upload the CSV file to your iCloud Drive in UTF-8 format.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "3.circle.fill")
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
        .padding(.vertical, 20)
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
                    let importedSessions = try csvImporter.importCSVFromLeftPocket(data: csvData)
                    
                    // Overwrite any current Sessions, if there are any, and set our array of Sessions to the imported data
                    vm.sessions += importedSessions
                    vm.sessions.sort(by: {$0.date > $1.date})
                    showSuccessMessage = "All sessions imported successfully."
                    showAlertModal = true
                    playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
                }
                
                selectedURL.stopAccessingSecurityScopedResource()
                
            } catch let error as URLError {
                errorMessage = "URL Error: \(error.localizedDescription)"
                showImportError = true
                print("URL Error: \(error)")
                
            } catch let error as CSVImporter.ImportError {
                switch error {
                case .invalidData: errorMessage = "Error: Invalid Data. Contact Support for assistance."
                case .parsingFailed: errorMessage = "Error: Parsing Failed. Ensure correct number of columns & formatting in each cell. Contact Support for assistance."
                case .saveFailed: errorMessage = "Error: Failed to Save Data. Contact Support for assistance."
                }
                showImportError = true
                print("CSV Import Error: \(error)")
                
            } catch {
                errorMessage = error.localizedDescription
                showImportError = true
                print("Error importing file: \(error)")
            }
        })
    }
}

struct LeftPocketImportView_Preview: PreviewProvider {
    static var previews: some View {
        LeftPocketImportView()
            .preferredColorScheme(.dark)
    }
}
