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
        Text("Manage Locations")
    }
    
    var message: Text? {
        Text("To add a location, press the \(Image(systemName: "plus")) above. Tap & hold a thumbnail to delete. If you've imported data, be sure location names match.")
    }
    
    var image: Image? {
        Image(systemName: "mappin.and.ellipse")
    }
}

struct MonthlyReportTip: Tip {
    
    var title: Text {
        Text("Using this Table")
    }
    
    var message: Text? {
        Text("From left to right is your Net Profit \(Image(systemName: "dollarsign")), Hourly Rate \(Image(systemName: "gauge.high")), & Total Hours \(Image(systemName: "clock")) for each month.")
    }
    
    var image: Image? {
        Image(systemName: "chart.bar.xaxis")
    }
}

struct ChartsTip: Tip {
    
    var title: Text {
        Text("Player Data")
    }
    
    var message: Text? {
        Text("Use this screen to track your performance. Tap & hold charts for additional info.")
    }
    
    var image: Image? {
        Image(systemName: "lightbulb")
    }
}

struct NewSessionViewTip: Tip {
    
    var title: Text {
        Text("Add Session Details")
    }
    
    var message: Text? {
        Text("Enter details from your Session. Set your own Session Defaults from the Settings \(Image(systemName: "gearshape.fill")) screen.")
    }
    
    var image: Image? {
        Image(systemName: "pencil.line")
    }
    
    var actions: [Action] {
        Action(id: "add-first-location", title: "Add My First Location")
    }
}

struct MeditationTip: Tip {
    
    var title: Text {
        Text("Using Meditations")
    }
    
    var message: Text? {
        Text("Start your mindfulness practice here. Press the Stop button to end early & dismiss this screen.")
    }
    
    var image: Image? {
        Image(systemName: "figure.mind.and.body")
    }
}

struct SessionsListTip: Tip {
    
    @Parameter
    static var shouldShow: Bool = true
    
    var title: Text {
        Text("Edit Sessions")
    }
    
    var message: Text? {
        Text("Swipe left on a Session in the list to either modify or delete it.")
    }
    
    var image: Image? {
        Image(systemName: "hand.draw")
    }
    
    var rules: [Rule] {
        
        #Rule(Self.$shouldShow) {
            $0 == true
        }
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
        Text("Tap the \(Image(systemName: "cross.fill")) button to start a Live Session, log a completed one, or enter a Transaction.")
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

struct FilterSessionsTip: Tip {
    
    static let sessionCount = Event(id: "addedSession")
    
    var title: Text {
        Text("Filter Sessions")
    }
    
    var message: Text? {
        Text("Tap \(Image(systemName: "slider.horizontal.3")) to filter by location, game type, stakes, etc. View transactions by pressing the \(Image(systemName: "creditcard.fill")) button.")
    }
    
    var image: Image? {
        Image(systemName: "slider.horizontal.3")
    }
    
    // After the user saves two Sessions, show the Tip
    // Dismissed by user, or as soon as they click the Filter button in the toolbar, tip won't show up.
    var rules: [Rule] {
        
        #Rule(Self.sessionCount) { event in
            event.donations.count >= 4
        }
    }
}

struct SettingsTip: Tip {
    
    var title: Text {
        Text("Did You Know?")
    }
    
    var message: Text? {
        Text("In Settings \(Image(systemName: "gearshape.fill")) you can toggle push notifications, import & export data, set your Session Defaults, & more.")
    }
    
    var image: Image? {
        Image(systemName: "text.magnifyingglass")
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

struct CustomTipViewStyle: TipViewStyle {
    func makeBody(configuration: TipViewStyle.Configuration) -> some View {
        HStack (alignment: .top, spacing: 10) {
            configuration.image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(.brandPrimary)
            
            VStack (alignment: .leading, spacing: 5) {
                configuration.title.font(.headline)
                configuration.message.font(.subheadline).foregroundColor(.secondary)
                
                if !configuration.actions.isEmpty {
                    
                    Divider().padding(.vertical, 8)
                    
                    ForEach(configuration.actions, id: \.id) { action in
                        Button {
                            action.handler()
                        } label: {
                            action.label()
                                .font(.subheadline)
                                .bold()
                                .tint(.brandPrimary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .overlay {
            HStack {
                
                Spacer()
                
                VStack {
                    
                    Button {
                        configuration.tip.invalidate(reason: .tipClosed)
                    } label: {
                        Image(systemName: "xmark").scaledToFit()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding()
        }
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
    }
}
