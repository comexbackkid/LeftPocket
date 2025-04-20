//
//  ImportView.binkPoker.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/20/25.
//

import SwiftUI
import Lottie

struct BinkPokerImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showFileImporter = false
    @State private var showAlertModal = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage = ""
    @State private var playbackMode = LottiePlaybackMode.paused(at: .progress(0))
    
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
                .padding(.horizontal)
            }
            
            HStack {
                Spacer()
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
                
                Text("After you've exported your CSV, begin by making sure the Notes column is cleared of any text.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "2.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Save & upload the CSV file to your iCloud Drive in UTF-8 format.")
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
                .presentationBackground(.ultraThinMaterial)
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
                
                if selectedURL.startAccessingSecurityScopedResource() {
                    let csvData = try Data(contentsOf: selectedURL)
                    let csvImporter = CSVImporter()
                    let importedSessions = try csvImporter.importCSVFromBinkPoker(data: csvData)
                    
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

struct BinkPoker_Previews: PreviewProvider {
    static var previews: some View {
        BinkPokerImportView()
            .preferredColorScheme(.dark)
    }
}
