//
//  LiveActivityManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/22/24.
//

import Foundation
import SwiftUI
import ActivityKit

class LiveActivityManager {
    
    @discardableResult
    func startActivity(startTime: Date, elapsedTime: String) -> Activity<LiveSessionWidgetAttributes>? {
        
        var activity: Activity<LiveSessionWidgetAttributes>?
        let attributes = LiveSessionWidgetAttributes(eventDescription: "Live Session")
        
        do {
            let state = LiveSessionWidgetAttributes.TimerStatus(startTime: startTime, elapsedTime: elapsedTime)
            activity = try Activity<LiveSessionWidgetAttributes>.request(attributes: attributes, content: .init(state: state, staleDate: nil), pushType: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        return activity
    }
    
    func endActivity() {
        Task {
            for activity in Activity<LiveSessionWidgetAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}
