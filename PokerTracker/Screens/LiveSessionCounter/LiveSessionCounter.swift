//
//  LiveSessionCounter.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/19/24.
//

import SwiftUI
import AVKit

struct LiveSessionCounter: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var timerViewModel: TimerViewModel
    
    @State private var showRebuyModal = false
    @State private var showSessionDefaultsView = false
    @State private var showNewNoteView = false
    @State private var rebuyConfirmationSound = false
    @State private var noteConfirmationSound = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var location: LocationModel_v2?
    @State private var sessionType: SessionType?
    @State private var sessionDefaultCounter = 0
    
    var body: some View {
        
        HStack (spacing: 10) {
            
            locationImage
            
            liveSessionText
            
            Spacer()
            
            Text(timerViewModel.liveSessionTimer)
                .font(.custom("Asap-Regular", size: 26))
            
            Image(systemName: "dollarsign.arrow.circlepath")
                .foregroundColor(.brandPrimary)
                .fontWeight(.medium)
                .font(.title)
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    showRebuyModal = true
                }
        }
        .dynamicTypeSize(.medium)
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .sheet(isPresented: $showNewNoteView, onDismiss: {
            if noteConfirmationSound {
                playNoteSound()
            }
        }, content: {
            LiveSessionNote(noteConfirmationSound: $noteConfirmationSound, timerViewModel: timerViewModel)
        })
        .contextMenu {
            
            let totalBuyInForLiveSession = timerViewModel.totalBuyInForLiveSession
            
            Menu {
                ForEach(Array(timerViewModel.totalRebuys.enumerated()), id: \.offset) { index, rebuy in
                    if rebuy == Int(timerViewModel.initialBuyInAmount) {
                        Text("Rebuy for $\(rebuy)")
                    } else {
                        Text("Topped off $\(rebuy)")
                    }
                }
                
            } label: {
                Text("In the Game For $\(totalBuyInForLiveSession)")
                    .foregroundStyle(.red)
            }
            
            Divider()
            
            Button {
                showSessionDefaultsView = true
                
            } label: {
                HStack {
                    Text("Update Session Details")
                    Image(systemName: "suit.club.fill")
                }
            }
            
            Button {
                showNewNoteView = true
                
            } label: {
                HStack {
                    Text("Add Note")
                    Image(systemName: "pencil.line")
                }
            }
            
            Button {
                showRebuyModal = true
                
            } label: {
                HStack {
                    Text("Add Rebuy")
                    Image(systemName: "dollarsign.arrow.circlepath")
                }
            }
        }
        .sheet(isPresented: $showRebuyModal, onDismiss: {
            if rebuyConfirmationSound {
                playRebuySound()
            }
        }, content: {
            LiveSessionRebuyModal(timerViewModel: timerViewModel, rebuyConfirmationSound: $rebuyConfirmationSound)
                .presentationDetents([.height(360), .large])
                .presentationBackground(.ultraThinMaterial)
        })
        .padding(.horizontal)
        .onAppear { loadUserDefaults() }
        .sheet(isPresented: $showSessionDefaultsView, onDismiss: {
            sessionDefaultCounter += 1
            loadUserDefaults()
        }, content: {
            SessionDefaultsView(isPresentedAsSheet: .constant(true))
        })
    }
    
    var locationImage: some View {
        
        VStack {
            
            if let location {
                if let localImage = location.localImage {
                    Image(localImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(.rect(cornerRadius: 7))
                    
                } else if let importedImagePath = location.importedImage {
                    if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(.rect(cornerRadius: 7))
                        
                    } else {
                        Image("defaultlocation-header")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(.rect(cornerRadius: 7))
                    }
                    
                } else {
                    Image("defaultlocation-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(.rect(cornerRadius: 7))
                }

            } else {
                Image("defaultlocation-header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(.rect(cornerRadius: 7))
            }
        }
    }
    
    var liveSessionText: some View {
        
        VStack (alignment: .leading) {
            
            switch sessionType {
            case .cash:
                Text("Live Cash Session at")
                    .font(.custom("Asap-Regular", size: 19))
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            case .tournament:
                Text("Live Tournament at")
                    .font(.custom("Asap-Regular", size: 19))
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            case nil:
                Text("Live Session at")
                    .font(.custom("Asap-Regular", size: 19))
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            
            if let location {
                Text(location.name.isEmpty ? "Location Not Selected" : location.name)
                    .captionStyle()
                    .lineLimit(1)
                
            } else {
                Text("Location Not Selected")
                    .captionStyle()
                    .lineLimit(1)
            }
        }
    }
    
    private func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
        // Load Location
        if let encodedLocation = defaults.object(forKey: "locationDefault") as? Data,
           let decodedLocation = try? JSONDecoder().decode(LocationModel_v2.self, from: encodedLocation) {
            location = decodedLocation
        } else {
            location = LocationModel_v2(name: "")
            print("No default location found.")
        }
        
        // Load Session Type
        if let encodedSessionType = defaults.object(forKey: "sessionTypeDefault") as? Data,
           let decodedSessionType = try? JSONDecoder().decode(SessionType.self, from: encodedSessionType) {
            sessionType = decodedSessionType
        } else {
            sessionType = nil
        }
        
        // Load AskLiveSessionEachTime
        let askLiveSessionEachTime = defaults.bool(forKey: "askLiveSessionEachTime")
        if askLiveSessionEachTime && sessionDefaultCounter == 0 {
            showSessionDefaultsView = true
        }
    }
    
    private func playNoteSound() {
        
        guard let url = Bundle.main.url(forResource: "handwriting", withExtension: ".mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
        } catch {
            print("Error loading sound: \(error.localizedDescription)")
        }
    }
    
    private func playRebuySound() {
            
        guard let url = Bundle.main.url(forResource: "rebuy-sfx", withExtension: ".wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
        } catch {
            print("Error loading sound: \(error.localizedDescription)")
        }
    }
}

#Preview {
    LiveSessionCounter(timerViewModel: TimerViewModel())
        .preferredColorScheme(.dark)
}
