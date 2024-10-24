//
//  MeditationView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/20/24.
//

import SwiftUI
import AVFoundation
import TipKit

struct MeditationView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var hkManager: HealthKitManager
    
    @State private var player: AVAudioPlayer?
    @State private var value: Double = 0.0
    @State private var isPlaying = false
    @State private var isEditing = false
    @State private var isLooping = false
    @State private var isSessionCompleted = false
    
    let audioManager = AudioManager()
    let meditation: Meditation
    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
            titleSection
            
            Spacer()

            playerControls
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image(meditation.background).resizable().aspectRatio(contentMode: .fill))
        .ignoresSafeArea()
        .onAppear {
            audioManager.setupAudioPlayer(track: meditation.track)
            audioManager.onFinish = {
                stopPlaybackAndReset()
                isSessionCompleted = true
            }
        }
        .onDisappear {
            Task {
                try? await hkManager.fetchDailyMindfulMinutesData()
            }
        }
        .onReceive(timer) { _ in
            guard let player = audioManager.player, player.isPlaying, !isEditing else { return }
            value = player.currentTime
        }
        .overlay {
            if #available(iOS 17.0, *) {
                
                let meditationTip = MeditationTip()
                
                VStack {

                    TipView(meditationTip)
                        .tipViewStyle(CustomTipViewStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
    }
    
    var titleSection: some View {
        
        VStack (spacing: 0) {
            
            Text(meditation.title)
                .font(.custom("Asap-Black", size: 34))
                .bold()
                .foregroundStyle(.white)
            
            Text("Runtime \(formattedDuration)")
                .calloutStyle()
                .foregroundStyle(.white.opacity(0.65))
        }
    }
    
    var playerControls: some View {
        
        VStack {
            
            HStack {
                
                Image(systemName: "repeat")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .fontWeight(isLooping ? .heavy : .regular)
                    .foregroundStyle(isLooping ? Color.brandPrimary : .white)
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        toggleLoop()
                    }
                
                Spacer()
                
                Image(systemName: "gobackward.15")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.white)
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        seek(by: -15)
                    }
                
                Spacer()
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    togglePlayPause()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.white)
                        .animation(.none, value: isPlaying)
                }
                
                Spacer()
                
                Image(systemName: "goforward.15")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.white)
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        seek(by: 15)
                    }
                
                Spacer()
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    if isSessionCompleted { hkManager.saveMindfulMinutes(Int(meditation.duration)) }
                    dismiss()
                } label: {
                    Image(systemName: "stop.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                }
            }
            .padding(.bottom, 30)
            .padding(.horizontal, 30)
            
            Slider(value: $value, in: 0...meditation.duration, onEditingChanged: { editing in
                isEditing = editing
                if !editing {
                    audioManager.player?.currentTime = value
                }
            })
            .padding(.horizontal, 30)
            .accentColor(.white)

            HStack {
                Text(timeString(from: value))
                Spacer()
                Text(formattedDuration)
            }
            .font(.custom("Asap-Regular", size: 14, relativeTo: .callout))
            .foregroundStyle(.white)
            .padding(.horizontal, 30)
            .padding(.top, 2)
        }
        .padding(.bottom, 100)
    }
    
    var formattedDuration: String {
        let minutes = Int(meditation.duration) / 60
        let seconds = Int(meditation.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func togglePlayPause() {
        
        guard let player = audioManager.player else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
            
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    private func stopPlaybackAndReset() {
        audioManager.player?.stop()
        audioManager.player?.currentTime = 0
        value = 0
        isPlaying = false
    }
    
    private func seek(by seconds: TimeInterval) {
        
        guard let player = audioManager.player else { return }
        let newTime = player.currentTime + seconds
        player.currentTime = max(0, min(newTime, meditation.duration))
        value = player.currentTime
    }
    
    private func toggleLoop() {
        
        guard let player = audioManager.player else { return }
        
        player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
        isLooping = player.numberOfLoops != 0
    }
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

}

#Preview {
    MeditationView(meditation: Meditation.beach)
        .environmentObject(HealthKitManager())
        .preferredColorScheme(.dark)
}
