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
    
    var image: Image? {
        Image(systemName: "hand.tap")
    }
}

struct AddSessionTip: Tip {
    
    static let sessionCount = Event(id: "clickedAddSessionButton")
    
    var title: Text {
        Text("Add a Session")
    }
    
    var message: Text? {
        Text("Tap here to start logging your poker sessions and hand notes.")
    }
    
    var image: Image? {
        Image(systemName: "hand.point.up.left")
    }
    
    // Only show this tip when the user has never pressed the Add Session Button
    var rules: [Rule] {
        
        #Rule(Self.sessionCount) { event in
            event.donations.count == 0
        }
    }
}

struct FilterSessionsTip: Tip {
    
    static let sessionCount = Event(id: "addedSession")
    static let pressedFilter = Event(id: "filteredSessionList")
    
    var title: Text {
        Text("Filter Sessions")
    }
    
    var message: Text? {
        Text("Tap here to filter by Cash games, or Tournaments.")
    }
    
    var image: Image? {
        Image(systemName: "square.stack.3d.down.right")
    }
    
    // After the user saves two Sessions, show the Tip
    // Dismissed by user, or as soon as they click the Filter button in the toolbar, tip won't show up.
    var rules: [Rule] {
        
        #Rule(Self.sessionCount) { event in
            event.donations.count >= 2
        }
        
        #Rule(Self.pressedFilter) { event in
            event.donations.count == 0
        }
    }
}

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
