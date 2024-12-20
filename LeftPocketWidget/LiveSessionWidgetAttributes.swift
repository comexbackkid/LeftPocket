//
//  LiveSessionWidgetAttributes.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/20/24.
//

import SwiftUI
import ActivityKit

struct LiveSessionWidgetAttributes: ActivityAttributes {
    
    public typealias TimerStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        
        var startTime: Date
        var elapsedTime: String
    }
    
    let eventDescription: String
}
