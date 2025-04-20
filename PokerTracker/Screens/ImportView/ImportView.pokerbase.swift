//
//  ImportView.pokerbase.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/20/25.
//

import SwiftUI
import Lottie

struct PokerbaseImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showFileImporter = false
    @State private var showAlertModal = false
    @State private var errorMessage: String?
    @State private var showSuccessMessage: String = ""
    @State private var stakes = "1/2"
    @State private var playbackMode = LottiePlaybackMode.paused(at: .progress(0))
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                Text("Pokerbase Import")
                    .subtitleStyle()
                    .bold()
                    .padding(.top, 10)
                
                Text("Please be sure to follow each step and read carefully. Unfortunately exports from Pokerbase do not include tournament info, or stakes info. If you only played one game stake, you can select it from the picker below and it'll be applied to your entire import.")
                    .bodyStyle()
                    .padding(.top, 1)
                
                instructions
            }
            .padding(.horizontal)
            
            stakesPicker
            
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
                
                Text("Generate a report and include every column.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "2.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Save the CSV file to a folder in your iCloud Drive using UTF-8 encoding.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "3.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .top)
                    .foregroundColor(Color.brandPrimary)
                
                Text("Choose from the game stakes below.")
                    .calloutStyle()
                    .padding(.leading, 6)
            }
            
            HStack {
                
                Image(systemName: "4.circle.fill")
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
        .padding(.top, 20)
    }
    
    var stakesPicker: some View {
        
        HStack {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.systemGray3))
                .frame(width: 30)
            
            Text("Choose Stakes")
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
                    let importedSessions = try csvImporter.importCSVFromPokerbase(data: csvData, selectedStakes: stakes)
                    
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

struct PokerbaseImportView_Preview: PreviewProvider {
    static var previews: some View {
        PokerbaseImportView()
            .preferredColorScheme(.dark)
    }
}
