//
//  LiveSessionCounterViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/19/24.
//

import Foundation
import SwiftUI

class TimerViewModel: ObservableObject {
    
    private var timer: Timer?
    
    @Published var liveSessionStartTime: Date?
    @Published var liveSessionTimer: String = "00:00:00"
    
    func startSession() {
        
        liveSessionStartTime = Date()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }
    
    func updateElapsedTime() {
        guard let startTime = liveSessionStartTime else {
            liveSessionTimer = "00:00:00"
            return
        }
        let elapsedTime = Date().timeIntervalSince(startTime)
        liveSessionTimer = formatTimeInterval(elapsedTime)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func resetTimer() {
        timer?.invalidate()
        liveSessionStartTime = nil
        liveSessionTimer = "00:00:00"
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    deinit {
        timer?.invalidate()
    }
}
