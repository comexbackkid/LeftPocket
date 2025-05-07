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
import HealthKit

class TimerViewModel: ObservableObject {
    
    private var timer: Timer?

    @Published var liveSessionStartTime: Date?
    @Published var liveSessionTimer: String = "00:00"
    @Published var reBuyAmount: String = ""
    @Published var initialBuyInAmount: String = ""
    @Published var totalRebuys: [Int] = []
    @Published var notes: [String] = []
    @Published var isPaused: Bool = false
    @Published var pauseStartTime: Date?
    @Published var totalPausedTime: TimeInterval = 0
    @Published var moodLabelRaw: Int?
    
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
        guard let startTime = UserDefaults.standard.object(forKey: "liveSessionStartTime") as? Date else {
            print("No Live Session start time found.")
            return
        }
        
        liveSessionStartTime = startTime
        totalPausedTime = UserDefaults.standard.double(forKey: "totalPausedTime")
        isPaused = UserDefaults.standard.bool(forKey: "isPaused")
        
        if isPaused {
            if let pauseStart = UserDefaults.standard.object(forKey: "pauseStartTime") as? Date {
                pauseStartTime = pauseStart
            }
        }
        
        updateElapsedTime()
        
        if !isPaused {
            startUpdatingTimer()
        }
        
        initialBuyInAmount = UserDefaults.standard.string(forKey: "initialBuyInAmount") ?? ""
        totalRebuys = UserDefaults.standard.array(forKey: "totalRebuys") as? [Int] ?? []
        notes = UserDefaults.standard.stringArray(forKey: "liveSessionNotes") ?? []
    }
    
    @objc func fileAccessAvailable() {
        loadTimerData()
    }
    
    func scheduleStandardUserNotifications() {
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
        
        // Second Push Notification after eight hours of playing
        let contentAfterEightHours = UNMutableNotificationContent()
        contentAfterEightHours.title = UserNotificationContext.fiveHours.msgTitle
        contentAfterEightHours.body = UserNotificationContext.fiveHours.msgBody
        contentAfterEightHours.sound = UNNotificationSound.default
        let triggerAfterEightHours = UNTimeIntervalNotificationTrigger(timeInterval: 28800, repeats: false)
        let requestAfterEightHours = UNNotificationRequest(identifier: "liveSessionNotificationAfterEightHours", content: contentAfterEightHours, trigger: triggerAfterEightHours)
        UNUserNotificationCenter.current().add(requestAfterEightHours)
    }
    
    func cancelUserNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["liveSessionNotificationAfterTwoHours", "liveSessionNotificationAfterFiveHours", "liveSessionNotificationAfterEightHours"])
    }
    
    func startSession() {
        let now = Date()
        liveSessionStartTime = now
        isPaused = false
        totalPausedTime = 0
        pauseStartTime = nil
        UserDefaults.standard.set(now, forKey: "liveSessionStartTime")
        UserDefaults.standard.set(false, forKey: "isPaused")
        UserDefaults.standard.set(0, forKey: "totalPausedTime")
        UserDefaults.standard.set(nil, forKey: "pauseStartTime")
        UserDefaults.standard.set(initialBuyInAmount, forKey: "initialBuyInAmount")
        UserDefaults.standard.set(totalRebuys, forKey: "totalRebuys")
        UserDefaults.standard.set(notes, forKey: "liveSessionNotes")
        startUpdatingTimer()
        scheduleStandardUserNotifications()
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
        
        let currentPauseTime = pauseStartTime != nil ? Date().timeIntervalSince(pauseStartTime!) : 0
        let totalPaused = totalPausedTime + currentPauseTime
        let elapsedTime = Date().timeIntervalSince(startTime) - totalPaused
        
        liveSessionTimer = formatTimeInterval(elapsedTime)
    }
    
    func togglePause() {
        if isPaused {
            if let pauseStart = pauseStartTime {
                totalPausedTime += Date().timeIntervalSince(pauseStart)
                pauseStartTime = nil
            }
            
            isPaused = false
            startUpdatingTimer()
            
        } else {
            pauseStartTime = Date()
            isPaused = true
            timer?.invalidate()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        UserDefaults.standard.removeObject(forKey: "liveSessionStartTime")
        UserDefaults.standard.removeObject(forKey: "initialBuyInAmount")
        UserDefaults.standard.removeObject(forKey: "totalRebuys")
        UserDefaults.standard.removeObject(forKey: "liveSessionNotes")
        UserDefaults.standard.removeObject(forKey: "isPaused")
        UserDefaults.standard.removeObject(forKey: "totalPausedTime")
        UserDefaults.standard.removeObject(forKey: "pauseStartTime")
        cancelUserNotifications()
    }
    
    func resetTimer() {
        timer?.invalidate()
        liveSessionStartTime = nil
        liveSessionTimer = "00:00"
        cancelUserNotifications()
        initialBuyInAmount = ""
        reBuyAmount = ""
        isPaused = false
        pauseStartTime = nil
        notes = []
        moodLabelRaw = nil
        totalRebuys.removeAll()
        UserDefaults.standard.removeObject(forKey: "liveSessionStartTime")
        UserDefaults.standard.removeObject(forKey: "initialBuyInAmount")
        UserDefaults.standard.removeObject(forKey: "totalRebuys")
        UserDefaults.standard.removeObject(forKey: "liveSessionNotes")
    }
    
    func addInitialBuyIn(_ amount: String, mood: Int? = nil) {
        initialBuyInAmount = amount
        UserDefaults.standard.setValue(initialBuyInAmount, forKey: "initialBuyInAmount")
        if let mood = mood {
            moodLabelRaw = mood
        }
    }
    
    func addRebuy() {
        /// Add rebuy amount to variable, then write that amount to UserDefaults
        /// That way, if the app is quit or terminates we can recover the rebuy and initial buy in entries
        totalRebuys.append(Int(reBuyAmount) ?? 0)
        UserDefaults.standard.setValue(totalRebuys, forKey: "totalRebuys")
        reBuyAmount = ""
    }
    
    func addNote(_ note: String) {
        if !notes.isEmpty {
            notes.append("\n" + note)
        } else {
            notes.append(note)
        }
        UserDefaults.standard.setValue(notes, forKey: "liveSessionNotes")
    }
    
    // Called when the app enters the foreground
    @objc private func appDidResume() {
        if !isPaused {
            updateElapsedTime()
        }
    }
    
    // Called when the app is about to become inactive
    @objc private func appWillResignActive() {
        if isPaused {
            // Save the current pause state
            UserDefaults.standard.set(isPaused, forKey: "isPaused")
            UserDefaults.standard.set(totalPausedTime, forKey: "totalPausedTime")
            if let pauseStart = pauseStartTime {
                UserDefaults.standard.set(pauseStart, forKey: "pauseStartTime")
            }
        }
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
        notes = []
        isPaused = false
        pauseStartTime = nil
        moodLabelRaw = nil
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
            "You've been playing awhile, should you keep going? Ensure you're in the right heaadspace."
        }
    }
}
