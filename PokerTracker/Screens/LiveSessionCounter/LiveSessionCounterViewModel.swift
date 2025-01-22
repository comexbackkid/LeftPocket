//
//  LiveSessionCounterViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/19/24.
//

import SwiftUI
import UIKit
import UserNotifications
import Combine

class TimerViewModel: ObservableObject {
    
    private var timer: Timer?

    @Published var liveSessionStartTime: Date?
    @Published var liveSessionTimer: String = "00:00"
    @Published var reBuyAmount: String = ""
    @Published var initialBuyInAmount: String = ""
    @Published var totalRebuys: [Int] = []
    
    var totalBuyInForLiveSession: Int {
        (Int(initialBuyInAmount) ?? 0) + rebuyTotalForSession
    }
    
    var rebuyTotalForSession: Int {
        return totalRebuys.reduce(0,+)
    }
    
    var isCounting: Bool {
        UserDefaults.standard.object(forKey: "liveSessionStartTime") != nil
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fileAccessAvailable), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResume), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        loadTimerData()
    }
    
    func loadTimerData() {
        // Attempt to recover liveSessionStartTime from UserDefaults
        guard let startTime = UserDefaults.standard.object(forKey: "liveSessionStartTime") as? Date else {
            print("No Live Session start time found.")
            return
        }
        liveSessionStartTime = startTime
        updateElapsedTime()
        startUpdatingTimer()
        initialBuyInAmount = UserDefaults.standard.string(forKey: "initialBuyInAmount") ?? ""
        totalRebuys = UserDefaults.standard.array(forKey: "totalRebuys") as? [Int] ?? []
    }
    
    @objc func fileAccessAvailable() {
        loadTimerData()
    }
    
    func scheduleUserNotification() {
        // First Push Notification to be sent after two hours of playing
        let contentAfterTwoHours = UNMutableNotificationContent()
        contentAfterTwoHours.title = UserNotificationContext.twoHours.msgTitle
        contentAfterTwoHours.body = UserNotificationContext.twoHours.msgBody
        contentAfterTwoHours.sound = UNNotificationSound.default
        let triggerAfterTwoHours = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)
        let requestAfterTwoHours = UNNotificationRequest(identifier: "liveSessionNotificationAfterTwoHours", content: contentAfterTwoHours, trigger: triggerAfterTwoHours)
        UNUserNotificationCenter.current().add(requestAfterTwoHours)
        
        // Second Push Notification after five hours of playing
        let contentAfterFiveHours = UNMutableNotificationContent()
        contentAfterFiveHours.title = UserNotificationContext.fiveHours.msgTitle
        contentAfterFiveHours.body = UserNotificationContext.fiveHours.msgBody
        contentAfterFiveHours.sound = UNNotificationSound.default
        let triggerAfterFiveHours = UNTimeIntervalNotificationTrigger(timeInterval: 18000, repeats: false)
        let requestAfterFiveHours = UNNotificationRequest(identifier: "liveSessionNotificationAfterFiveHours", content: contentAfterFiveHours, trigger: triggerAfterFiveHours)
        UNUserNotificationCenter.current().add(requestAfterFiveHours)
    }
    
    func cancelUserNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["liveSessionNotificationAfterTwoHours", "liveSessionNotificationAfterFiveHours"])
    }
    
    func startSession() {
        let now = Date()
        liveSessionStartTime = now
        UserDefaults.standard.set(now, forKey: "liveSessionStartTime")
        UserDefaults.standard.set(initialBuyInAmount, forKey: "initialBuyInAmount")
        UserDefaults.standard.set(totalRebuys, forKey: "totalRebuys")
        startUpdatingTimer()
        scheduleUserNotification()
    }
    
    func startUpdatingTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }
    
    func updateElapsedTime() {
        guard let startTime = liveSessionStartTime else {
            liveSessionTimer = "00:00"
            print("Error retrieving Live Session Start Time.")
            return
        }
        let elapsedTime = Date().timeIntervalSince(startTime)
        liveSessionTimer = formatTimeInterval(elapsedTime)
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        UserDefaults.standard.removeObject(forKey: "liveSessionStartTime")
        UserDefaults.standard.removeObject(forKey: "initialBuyInAmount")
        UserDefaults.standard.removeObject(forKey: "totalRebuys")
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
        UserDefaults.standard.removeObject(forKey: "initialBuyInAmount")
        UserDefaults.standard.removeObject(forKey: "totalRebuys")
    }
    
    func addRebuy() {
        
        // Add rebuy amount to variable, then write that amount to UserDefaults
        // That way, if the app is quit or terminates we can recover the rebuy and initial buy in entries
        totalRebuys.append(Int(reBuyAmount) ?? 0)
        UserDefaults.standard.setValue(initialBuyInAmount, forKey: "initialBuyInAmount")
        UserDefaults.standard.setValue(totalRebuys, forKey: "totalRebuys")
        reBuyAmount = ""
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

            return String(format: "%02d:%02d", hours, minutes)
        } else {

            let seconds = Int(interval) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        cancelUserNotifications()
        initialBuyInAmount = ""
        reBuyAmount = ""
        totalRebuys.removeAll()
    }
}

enum UserNotificationContext: String {
    case twoHours, fiveHours, eightHours
    
    var msgTitle: String {
        switch self {
        case .twoHours:
            "How's Your Session?"
        case .fiveHours:
            "Just Checking In"
        case .eightHours:
            "This is a Long Session"
        }
    }
    
    var msgBody: String {
        switch self {
        case .twoHours:
            "Maybe stretch your legs, have some water, & consider if the game's still good."
        case .fiveHours:
            "You've been playing 5 hours, how do you feel? Take a break if you need it."
        case .eightHours:
            "You've been playing awhile, should you keep going? Make sure you're in the right heaadspace."
        }
    }
}
