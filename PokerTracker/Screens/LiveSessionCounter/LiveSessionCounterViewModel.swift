//
//  LiveSessionCounterViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/19/24.
//

import SwiftUI
import ActivityKit
import UIKit

class TimerViewModel: ObservableObject {
    
    private var timer: Timer?
    
    @Published var liveSessionStartTime: Date?
    @Published var liveSessionTimer: String = "00:00"
    @Published var activity: Activity<LiveSessionWidgetAttributes>? = nil
    
    init() {
        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResume), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        // Attempt to recover liveSessionStartTime from UserDefaults
        if let startTime = UserDefaults.standard.object(forKey: "liveSessionStartTime") as? Date {
            liveSessionStartTime = startTime
            // Ensure the UI is updated based on the recovered start time
            updateElapsedTime()
            startUpdatingTimer()
        }
    }
    
    func startSession() {
        let now = Date()
        liveSessionStartTime = now
        UserDefaults.standard.set(now, forKey: "liveSessionStartTime")
        
        // Start or restart the timer
        startUpdatingTimer()
        
        // Activity Kit addition
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            
            let attributes = LiveSessionWidgetAttributes(eventDescription: "Live Session")
            let state = LiveSessionWidgetAttributes.TimerStatus(startTime: Date(), elapsedTime: self.liveSessionTimer)
            
            do {
                activity = try Activity<LiveSessionWidgetAttributes>.request(attributes: attributes, 
                                                                             content: .init(state: state, staleDate: nil),
                                                                             pushType: nil)
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func startUpdatingTimer() {
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }
    
    func updateElapsedTime() {
        guard let startTime = liveSessionStartTime else {
            liveSessionTimer = "00:00"
            return
        }
        let elapsedTime = Date().timeIntervalSince(startTime)
        liveSessionTimer = formatTimeInterval(elapsedTime)
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        UserDefaults.standard.removeObject(forKey: "liveSessionStartTime")
        
        // End Activity
        Task {
            await Activity<LiveSessionWidgetAttributes>.activities.first?.end(activity?.content, dismissalPolicy: .immediate)
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        liveSessionStartTime = nil
        liveSessionTimer = "00:00"
        UserDefaults.standard.removeObject(forKey: "liveSessionStartTime")
    }
    
    // Called when the app enters the foreground
    @objc private func appDidResume() {
        updateElapsedTime()
    }
    
    // Called when the app is about to become inactive
    @objc private func appWillResignActive() {
        // This method would be useful if you need to handle app becoming inactive
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            // Format as "HH:MM" if there's one or more hours
            return String(format: "%02d:%02d", hours, minutes)
        } else {
            // Format as "MM:SS" if less than an hour
            let seconds = Int(interval) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    deinit {
        timer?.invalidate()
        // Unregister from all notifications
        NotificationCenter.default.removeObserver(self)
    }
}
