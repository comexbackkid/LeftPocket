//
//  LiveSessionCounterViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/19/24.
//

import SwiftUI
import ActivityKit
import UIKit
import UserNotifications

class TimerViewModel: ObservableObject {
    
    private var timer: Timer?
    
    @Published var liveSessionStartTime: Date?
    @Published var liveSessionTimer: String = "00:00"
    @Published var activity: Activity<LiveSessionWidgetAttributes>? = nil
    @Published var reBuyAmount: String = ""
    @Published var initialBuyInAmount: String = ""
    @Published var totalRebuys: [Int] = []
    
    var totalBuyInForLiveSession: Int {
        (Int(initialBuyInAmount) ?? 0) + rebuyTotalForSession
        
    }
    
    var rebuyTotalForSession: Int {
        return totalRebuys.reduce(0,+)
    }
    
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
    
    enum UserNotificationContext: String {
        case twoHours, fourHours, eightHours
        
        var msgTitle: String {
            switch self {
            case .twoHours:
                "How's Your Session?"
            case .fourHours:
                "Just Checking In"
            case .eightHours:
                "This is a Long Session"
            }
        }
        
        var msgBody: String {
            switch self {
            case .twoHours:
                "You should stretch your legs, have some water, & consider if the game is still good."
            case .fourHours:
                "You've been playing four hours, how do you feel? Keep hydrated & take a break if you need it."
            case .eightHours:
                "You've been playing awhile, should you keep going? Make sure you're in the right heaadspace."
            }
        }
    }
    
    func addRebuy() {
        guard !reBuyAmount.isEmpty else { return }
        totalRebuys.append(Int(reBuyAmount) ?? 0)
        reBuyAmount = ""
    }
    
    // Push notification checking on the user
    func scheduleUserNotification() {
        let content = UNMutableNotificationContent()
        content.title = "How's Your Session?"
        content.body = "You should stretch your legs, have some water, & consider if the game is still good."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: true)
        let request = UNNotificationRequest(identifier: "liveSessionNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelUserNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["liveSessionNotification"])
    }
    
    func startSession() {
        let now = Date()
        liveSessionStartTime = now
        UserDefaults.standard.set(now, forKey: "liveSessionStartTime")
        
        // Start or restart the timer
        startUpdatingTimer()
        scheduleUserNotification()
        
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
        
        cancelUserNotifications()
    }
    
    func resetTimer() {
        timer?.invalidate()
        liveSessionStartTime = nil
        liveSessionTimer = "00:00"
        cancelUserNotifications()
        initialBuyInAmount = ""
        reBuyAmount = ""
        totalRebuys.removeAll()
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
        cancelUserNotifications()
        initialBuyInAmount = ""
        reBuyAmount = ""
        totalRebuys.removeAll()
    }
}
