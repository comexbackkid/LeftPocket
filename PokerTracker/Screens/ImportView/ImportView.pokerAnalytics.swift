//
//  ImportView.pokerAnalytics.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/20/25.
//

import SwiftUI
import Lottie

struct PokerAnalyticsImportView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showFileImporter = false
    @State private var showAlertModal = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: LocalizedStringResource = ""
    @State private var playbackMode = LottiePlaybackMode.paused(at: .progress(0))
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack {
                
                VStack (alignment: .leading) {
                    
                    Text("Poker Analytics 6 Import")
                        .subtitleStyle()
                        .bold()
                        .padding(.top, 10)
                    
                    Text("Please be sure to follow each step and read carefully. Poker Analytics allows for exporting of session comments and you will need to account for how the text is formatted.")
                        .bodyStyle()
                        .padding(.top, 1)
                        .padding(.bottom, 10)
                    
                    helpButton
                    
                    instructions
                    
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
            }
            .padding(.bottom)
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
                
                Text("In Poker Analytics, from Settings navigate to Export Data. Choose Sessions (CSV).")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "2.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Save this new file to a folder in your iCloud Drive.")
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
        .padding(.vertical, 30)
        .sheet(isPresented: $showAlertModal) {
            AlertModal(message: showSuccessMessage, image: "checkmark.circle", imageColor: .green)
                .presentationDetents([.height(280)])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                .presentationDragIndicator(.visible)
        }
    }
    
    var helpButton: some View {
        Button {
            guard let url = URL(string: "https://iridescent-cheetah-aae.notion.site/Poker-Analytics-1dc9452cf3e580a5b5daca1a018b023b") else {
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
                    let importedSessions = try csvImporter.importCSVFromPokerAnalytics(data: csvData)
                    
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

struct PokerAnalyticsImportView_Preview: PreviewProvider {
    static var previews: some View {
        PokerAnalyticsImportView()
            .preferredColorScheme(.dark)
    }
}
