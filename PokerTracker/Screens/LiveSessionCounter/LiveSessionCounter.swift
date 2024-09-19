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
    @State private var rebuyConfirmationSound = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var location: LocationModel?
    
    var body: some View {
        
        HStack (spacing: 12) {
            
            locationImage
            
            liveSessionText
            
            Spacer()
            
            Text(timerViewModel.liveSessionTimer)
                .font(.custom("Asap-Regular", size: 26))
                .offset(x: 4)
            
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
        .padding(.horizontal, 2)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .contextMenu {
            Button {
                showSessionDefaultsView = true
            } label: {
                HStack {
                    Text("Update Session Details")
                    Image(systemName: "suit.club.fill")
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
                playSound()
            }
        }, content: {
            LiveSessionRebuyModal(timerViewModel: timerViewModel, rebuyConfirmationSound: $rebuyConfirmationSound)
                .presentationDetents([.height(350), .large])
                .presentationBackground(.ultraThinMaterial)
        })
        .padding(.horizontal)
        .onAppear { loadUserDefaults() }
        .sheet(isPresented: $showSessionDefaultsView, onDismiss: { loadUserDefaults() }, content: {
            SessionDefaultsView(isPresentedAsSheet: .constant(true))
        })
    }
    
    var locationImage: some View {
        
        VStack {
            if let location {
                if location.localImage != "" {
                    
                    Image(location.localImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(.rect(cornerRadius: 7))
                } else {
                    
                    if location.importedImage != nil {
                        
                        if let photoData = location.importedImage, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(.rect(cornerRadius: 7))
                        }
                    }
                    
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
            
            Text("Live Session at")
                .font(.custom("Asap-Regular", size: 19, relativeTo: .callout))
                .bold()
            
            if let location {
                Text(location.name)
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
        
        guard
            let encodedLocation = defaults.object(forKey: "locationDefault") as? Data,
            let decodedLocation = try? JSONDecoder().decode(LocationModel.self, from: encodedLocation)
                
        else { return }
        
        location = decodedLocation
    }
    
    private func playSound() {
            
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
