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
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    @State private var showRebuyModal = false
    @State private var rebuyConfirmationSound = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        
        HStack (spacing: 10) {
            
            Image(systemName: "timer")
                .foregroundStyle(.secondary)
                .font(.title3)
                .fontWeight(.medium)
            
            Text(timerViewModel.liveSessionTimer)
                .font(.custom("Asap-Regular", size: 21))
            
            Image(systemName: "dollarsign.arrow.circlepath")
                .foregroundColor(.brandPrimary)
                .fontWeight(.medium)
                .font(.title2)
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    showRebuyModal = true
                }
        }
        .padding()
        .background(.thickMaterial.opacity(0.97))
        .cornerRadius(20)
        .onDisappear {
            timerViewModel.stopTimer()
        }
        .sheet(isPresented: $showRebuyModal, onDismiss: {
            if rebuyConfirmationSound {
                playSound()
            }
        }, content: {
            LiveSessionRebuyModal(rebuyConfirmationSound: $rebuyConfirmationSound)
                .presentationDetents([.height(350), .large])
                .presentationBackground(.ultraThinMaterial)
        })
    }
    
    func playSound() {
            
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
    LiveSessionCounter()
        .environmentObject(TimerViewModel())
        .preferredColorScheme(.dark)
}
