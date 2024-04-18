//
//  Tips.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/4/24.
//

import SwiftUI
import TipKit

@available(iOS 17.0, *)
struct DeleteLocationTip: Tip {
    
    var title: Text {
        Text("Delete Location")
    }
    
    var message: Text? {
        Text("Long press on a Location's thumbnail to delete it. To add your own, tap the Plus button above.")
    }
    
    var image: Image? {
        Image(systemName: "mappin.and.ellipse")
    }
}

@available(iOS 17.0, *)
struct AddSessionTip: Tip {
    
    static let sessionCount = Event(id: "clickedAddSessionButton")
    
    @Parameter
    static var newUser: Bool = true
    
    var title: Text {
        Text("Add a Session")
    }
    
    var message: Text? {
        Text("Tap here to log a poker session. Long press to activate a live session.")
    }
    
    var image: Image? {
        Image(systemName: "suit.club.fill")
    }
    
    // Show this tip when the user has never pressed the Add Session Button.
    // Also checking user status, if they are NOT a new user then we don't show the tip because they know what they're doing.
    var rules: [Rule] {
        
        #Rule(Self.sessionCount) { event in
            event.donations.count == 0
        }
        
        #Rule(Self.$newUser) {
            $0 == true
        }
    }
}

@available(iOS 17.0, *)
struct FilterSessionsTip: Tip {
    
    static let sessionCount = Event(id: "addedSession")
    
    var title: Text {
        Text("Filter Sessions")
    }
    
    var message: Text? {
        Text("Use these menu buttons to filter your sessions by cash games, tournaments, & more.")
    }
    
    var image: Image? {
        Image(systemName: "slider.horizontal.3")
    }
    
    // After the user saves two Sessions, show the Tip
    // Dismissed by user, or as soon as they click the Filter button in the toolbar, tip won't show up.
    var rules: [Rule] {
        
        #Rule(Self.sessionCount) { event in
            event.donations.count >= 2
        }
    }
}

@available(iOS 17.0, *)
struct NewSessionDetailsTip: Tip {
    
    var title: Text {
        Text("Enter Session Details")
    }
    
    var message: Text? {
        Text("Record details from your session. Add locations right from this screen.")
    }
    
    var image: Image? {
        Image(systemName: "pencil")
    }
}

@available(iOS 17.0, *)
struct ChartTip: Tip {
    
    var title: Text {
        Text("Enhanced Charts")
    }
    
    var message: Text? {
        Text("Tap & hold on charts to interact & view more detailed info. Tap the X to dismiss this message.")
    }
    
    var image: Image? {
        Image(systemName: "chart.line.uptrend.xyaxis")
    }
}

@available(iOS 17.0, *)
public struct TipKitConfig {
        
    public static var storeLocation: Tips.ConfigurationOption.DatastoreLocation {
        var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        url = url.appending(path: "tipstore")
        return .url(url)
    }
    
    // Showing tips as soon as they are elligible
    public static var displayFrequency: Tips.ConfigurationOption.DisplayFrequency {
        .immediate
    }
}
