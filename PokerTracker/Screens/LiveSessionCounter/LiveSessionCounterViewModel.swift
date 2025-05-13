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
    
    struct NotificationPlan {
        let identifier: String
        let timeInterval: TimeInterval
        let title: String
        let body: String
    }
    
    private enum NotificationPlanProvider {
        static func plans(for mood: HKStateOfMind.Label?) -> [NotificationPlan] {
            guard let mood = mood else {
                return defaultPlans()
            }
            
            switch mood {
            case .drained:
                return [
                    NotificationPlan(
                        identifier: "tiredAfter1Hour",
                        timeInterval: 1 * 3600,
                        title: "Are You Still Tired?",
                        body:  "You’ve been playing an hour. Maybe grab a breath of fresh air?"
                    ),
                    NotificationPlan(
                        identifier: "tiredAfter3Hours",
                        timeInterval: 3 * 3600,
                        title: "Checking In",
                        body:  "Three hours down... how’s your focus, still good?"
                    ),
                    NotificationPlan(
                        identifier: "tiredAfter4Hours",
                        timeInterval: 4 * 3600,
                        title: "Time to Evaluate",
                        body:  "You started this session feeling tired. Consider if it's wise to keep playing."
                    )
                ]
                
            case .angry:
                return [
                    NotificationPlan(
                        identifier: "angryAfter1Hour",
                        timeInterval: 1 * 3600,
                        title: "Take a Walk",
                        body:  "It's proven that taking regular walks can help with stress reduction and enhanced mood."
                    ),
                    NotificationPlan(
                        identifier: "angryAfter3Hours",
                        timeInterval: 3 * 3600,
                        title: "How's Your Mood?",
                        body:  "Things must be going well. Remember, you can only control what you can control."
                    ),
                    NotificationPlan(
                        identifier: "angryAfter6Hours",
                        timeInterval: 6 * 3600,
                        title: "Time to Evaluate",
                        body:  "How's your mood now after 4 hours? Maybe a short break can help if you plan to continue."
                    )
                ]
                
            default:
                return defaultPlans()
            }
        }
        
        private static func defaultPlans() -> [NotificationPlan] {
            [NotificationPlan(
                identifier: "afterTwoHours",
                timeInterval: 2 * 3600,
                title: UserNotificationContext.twoHours.msgTitle,
                body:  UserNotificationContext.twoHours.msgBody
            ),
             NotificationPlan(
                identifier: "afterFiveHours",
                timeInterval: 5 * 3600,
                title: UserNotificationContext.fiveHours.msgTitle,
                body:  UserNotificationContext.fiveHours.msgBody
             ),
             NotificationPlan(
                identifier: "afterEightHours",
                timeInterval: 8 * 3600,
                title: UserNotificationContext.eightHours.msgTitle,
                body:  UserNotificationContext.eightHours.msgBody
             )]
        }
    }
    
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
    
    var moodLabel: HKStateOfMind.Label? {
        guard let raw = moodLabelRaw else { return nil }
        return HKStateOfMind.Label(rawValue: raw)
    }
    
    var totalBuyInForLiveSession: Int { (Int(initialBuyInAmount) ?? 0) + rebuyTotalForSession }
    var rebuyTotalForSession: Int { return totalRebuys.reduce(0,+) }
    var isCounting: Bool { UserDefaults.standard.object(forKey: "liveSessionStartTime") != nil }
    
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
        
        let plans = NotificationPlanProvider.plans(for: moodLabel)
        
        plans.forEach { plan in
            let content = UNMutableNotificationContent()
            content.title = plan.title
            content.body  = plan.body
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: plan.timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: plan.identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func cancelUserNotifications() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [
                "afterTwoHours",
                "afterFiveHours",
                "afterEightHours",
                "tiredAfter1Hour",
                "tiredAfter3Hours",
                "tiredAfter4Hours",
                "angryAfter1Hour",
                "angryAfter3Hours",
                "angryAfter6Hours"
                ]
            )
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
            
            UserDefaults.standard.set(false, forKey: "isPaused")
            UserDefaults.standard.set(totalPausedTime, forKey: "totalPausedTime")
            UserDefaults.standard.removeObject(forKey: "pauseStartTime")
            
        } else {
            pauseStartTime = Date()
            isPaused = true
            timer?.invalidate()
            
            UserDefaults.standard.set(true, forKey: "isPaused")
            UserDefaults.standard.set(totalPausedTime, forKey: "totalPausedTime")
            UserDefaults.standard.set(pauseStartTime, forKey: "pauseStartTime")
        }
    }
    
    func stopTimer() {
        if isPaused, let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
        }
        
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
        case .twoHours: "How's Your Session?"
        case .fiveHours: "Just Checking In"
        case .eightHours: "This is a Long Session"
        }
    }
    
    var msgBody: String {
        switch self {
        case .twoHours: "Maybe stretch your legs, have some water, & consider if the game's still good."
        case .fiveHours: "You've been playing 5 hours, how do you feel? Take a break if you need it."
        case .eightHours: "You've been playing awhile, should you keep going? Ensure you're in the right heaadspace."
        }
    }
}
