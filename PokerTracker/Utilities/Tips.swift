//
//  Tips.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/4/24.
//

import SwiftUI
import TipKit

struct DeleteLocationTip: Tip {
    
    var title: Text {
        Text("Delete Location")
    }
    
    var message: Text? {
        Text("Long press on a Location's thumbnail if you want to delete it.")
    }
}

struct AddSessionTip: Tip {
    
    static let sessionCount = Event(id: "clickedAddSessionButton")
    
    @Parameter
    static var newUser: Bool = true
    
    var title: Text {
        Text("Add a Session")
    }
    
    var message: Text? {
        Text("Tap here to log a poker sessions. Long press to activate a live session.")
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

struct FilterSessionsTip: Tip {
    
    static let sessionCount = Event(id: "addedSession")
    
    var title: Text {
        Text("Filter Sessions")
    }
    
    var message: Text? {
        Text("Tap here to filter by Cash games, or Tournaments.")
    }
    
    // After the user saves two Sessions, show the Tip
    // Dismissed by user, or as soon as they click the Filter button in the toolbar, tip won't show up.
    var rules: [Rule] {
        
        #Rule(Self.sessionCount) { event in
            event.donations.count >= 2
        }
    }
}

//struct ChartTip: Tip {
//    
//    var title: Text {
//        Text("Enhanced Charts")
//    }
//    
//    var message: Text? {
//        Text("Tap & hold on charts to view more detailed info.")
//    }
//}

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
