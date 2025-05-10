////
////  LiveSessionNotificationPlan.swift
////  LeftPocket
////
////  Created by Christian Nachtrieb on 5/10/25.
////
//
//import Foundation
//import SwiftUI
//import UserNotifications
//import HealthKit
//
//public struct NotificationPlan {
//    public let identifier: String
//    public let timeInterval: TimeInterval
//    public let title: String
//    public let body: String
//}
//
//public enum NotificationPlanProvider {
//    
//    public static func plans(for moodLabel: HKStateOfMind.Label?) -> [NotificationPlan] {
//        guard let mood = moodLabel else {
//            return defaultPlans()
//        }
//        
//        switch mood {
//        case .drained:
//            return [
//                NotificationPlan(
//                    identifier: "tiredAfter1Hour",
//                    timeInterval: 3600,
//                    title: "Still Tired?",
//                    body:  "You’ve been playing an hour. Maybe grab a breath of fresh air?"
//                ),
//                NotificationPlan(
//                    identifier: "tiredAfter3Hours",
//                    timeInterval: 3 * 3600,
//                    title: "3-Hour Check-In",
//                    body:  "Three hours down—how’s your focus?"
//                ),
//                NotificationPlan(
//                    identifier: "tiredAfter4Hours",
//                    timeInterval: 4 * 3600,
//                    title: "Time to Evaluate",
//                    body:  "You started this session feeling tired. Is it still +EV to keep going?"
//                )
//            ]
//            
//        case .angry:
//            return [
//                NotificationPlan(
//                    identifier: "angryAfter1Hour",
//                    timeInterval: 3600,
//                    title: "How’s Your Mood?",
//                    body:  "It's been an hour, how's your mood?"
//                ),
//                NotificationPlan(
//                    identifier: "angryAfter3Hours",
//                    timeInterval: 3 * 3600,
//                    title: "3-Hour Check-In",
//                    body:  "Things must be going well. Remember you can only control what you can control."
//                ),
//                NotificationPlan(
//                    identifier: "angryAfter6Hours",
//                    timeInterval: 6 * 3600,
//                    title: "Six-Hour Mark",
//                    body:  "How's your mood now after 4 hours? Maybe a short break can help if you plan to continue."
//                )
//            ]
//            
//        default:
//            return defaultPlans()
//        }
//    }
//    
//    private static func defaultPlans() -> [NotificationPlan] {
//        return [
//            NotificationPlan(
//                identifier: "afterTwoHours",
//                timeInterval: 2 * 3600,
//                title: UserNotificationContext.twoHours.msgTitle,
//                body:  UserNotificationContext.twoHours.msgBody
//            ),
//            NotificationPlan(
//                identifier: "afterFiveHours",
//                timeInterval: 5 * 3600,
//                title: UserNotificationContext.fiveHours.msgTitle,
//                body:  UserNotificationContext.fiveHours.msgBody
//            ),
//            NotificationPlan(
//                identifier: "afterEightHours",
//                timeInterval: 8 * 3600,
//                title: UserNotificationContext.eightHours.msgTitle,
//                body:  UserNotificationContext.eightHours.msgBody
//            )
//        ]
//    }
//}
//
//enum UserNotificationContext: String {
//    case twoHours, fiveHours, eightHours
//    
//    var msgTitle: String {
//        switch self {
//        case .twoHours: "How's Your Session?"
//        case .fiveHours: "Just Checking In"
//        case .eightHours: "This is a Long Session"
//        }
//    }
//    
//    var msgBody: String {
//        switch self {
//        case .twoHours: "Maybe stretch your legs, have some water, & consider if the game's still good."
//        case .fiveHours: "You've been playing 5 hours, how do you feel? Take a break if you need it."
//        case .eightHours: "You've been playing awhile, should you keep going? Ensure you're in the right heaadspace."
//        }
//    }
//}
