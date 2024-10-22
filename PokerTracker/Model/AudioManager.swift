//
//  AudioManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/21/24.
//

import Foundation
import AVKit

final class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    var player: AVAudioPlayer?
    var onFinish: (() -> Void)?
    
    func setupAudioPlayer(track: String) {
        
        guard let url = Bundle.main.url(forResource: track, withExtension: "wav") else {
            print("Audio file not found")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
}
