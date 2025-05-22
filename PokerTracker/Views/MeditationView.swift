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
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var hkManager: HealthKitManager
    @Binding var passedMeditation: Meditation?
    @State private var player: AVAudioPlayer?
    @State private var value: Double = 0.0
    @State private var isPlaying = false
    @State private var isEditing = false
    @State private var isLooping = false
    @State private var isPressed = false
    @State private var isSessionCompleted = false
    let audioManager = AudioManager()
    let meditation: Meditation
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                Spacer()
                
                Spacer()
                
                Spacer()
                
                Spacer()
                
                titleSection
                
                Spacer()
                
                playerControls
                
            }
            .navigationDestination(isPresented: $isSessionCompleted) {
                MindfulnessCompleted(passedMeditation: $passedMeditation, meditation: meditation)
                    .navigationBarBackButtonHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Image(meditation.background).resizable().aspectRatio(contentMode: .fill))
            .ignoresSafeArea()
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                audioManager.setupAudioPlayer(track: meditation.track)
                audioManager.onFinish = {
                    stopPlaybackAndReset()
                    isSessionCompleted = true
                    if isSessionCompleted { hkManager.saveMindfulMinutes(Int(meditation.duration)) }
                }
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
                Task {
                    try? await hkManager.fetchDailyMindfulMinutesData()
                }
            }
            .onReceive(timer) { _ in
                guard let player = audioManager.player, player.isPlaying, !isEditing else { return }
                value = player.currentTime
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    audioManager.setupAudioPlayer(track: meditation.track)
                } else if newPhase == .background || newPhase == .inactive {
                    stopPlaybackAndReset()
                }
            }
            .overlay {
                if !MeditationTip().shouldDisplay {
                    dismissButton
                }
            }
            .overlay {
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
            
            Text(LocalizedStringResource(stringLiteral: meditation.title))
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
            
            if !hkManager.isMindfulnessAuthorized {
                Text("Health permissions denied. Update from iOS Settings.")
                    .captionStyle()
                    .padding(.bottom)
                    .padding(.horizontal, 30)
            }
            
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
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    seek(by: -15)
                    
                } label: {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(hkManager.isMindfulnessAuthorized ? .white : .gray.opacity(0.8))
                }
                .allowsHitTesting(hkManager.isMindfulnessAuthorized ? true : false)
                
                Spacer()
                
                Button {
//                    let impact = UIImpactFeedbackGenerator(style: .medium)
//                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                        isPressed = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                            isPressed = false
                        }
                    }
                    
                    togglePlayPause()
                    
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(hkManager.isMindfulnessAuthorized ? .white : .gray.opacity(0.8))
                        .scaleEffect(isPressed ? 0.7 : 1.0)
                        .animation(.none, value: isPlaying)
                }
                .allowsHitTesting(hkManager.isMindfulnessAuthorized ? true : false)
                .sensoryFeedback(.success, trigger: isPlaying)
                
                Spacer()
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    seek(by: 15)
                    
                } label: {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(hkManager.isMindfulnessAuthorized ? .white : .gray.opacity(0.8))
                }
                .allowsHitTesting(hkManager.isMindfulnessAuthorized ? true : false)

                Spacer()
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    stopPlaybackAndReset()
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
    
    var dismissButton: some View {
        
        VStack {
            HStack {
                Spacer()
                DismissButton()
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                    .onTapGesture {
                        dismiss()
                    }
            }
            Spacer()
        }
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
    MeditationView(passedMeditation: .constant(.forest), meditation: Meditation.forest)
        .environmentObject(HealthKitManager())
        .preferredColorScheme(.dark)
//        .environment(\.locale, Locale(identifier: "PT"))
}
