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
        Text("Manage Locations")
    }
    
    var message: Text? {
        Text("To add a location, press the \(Image(systemName: "plus")) above. Tap & hold a thumbnail to delete. If you've imported data, be sure location names match.")
    }
    
    var image: Image? {
        Image(systemName: "mappin.and.ellipse")
    }
}

@available(iOS 17.0, *)
struct MonthlyReportTip: Tip {
    
    var title: Text {
        Text("Columns Legend")
    }
    
    var message: Text? {
        Text("The \(Image(systemName: "dollarsign")) column is your net profit, \(Image(systemName: "gauge.high")) hourly rate, and \(Image(systemName: "clock")) your total hours.")
    }
    
    var image: Image? {
        Image(systemName: "chart.bar.xaxis")
    }
}

@available(iOS 17.0, *)
struct NewSessionViewTip: Tip {
    
    var title: Text {
        Text("Add Session Details")
    }
    
    var message: Text? {
        Text("Enter details from your Session here. You can add Locations & Stakes from the dropdown menus below.")
    }
    
    var image: Image? {
        Image(systemName: "pencil.line")
    }
}

@available(iOS 17.0, *)
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

@available(iOS 17.0, *)
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

@available(iOS 17.0, *)
struct FilterSessionsTip: Tip {
    
    static let sessionCount = Event(id: "addedSession")
    
    var title: Text {
        Text("Filter Sessions")
    }
    
    var message: Text? {
        Text("Tap \(Image(systemName: "slider.horizontal.3")) above to filter Sessions by location, game type, stakes, etc. View transactions by pressing the \(Image(systemName: "creditcard.fill")) button.")
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

@available(iOS 17.0, *)
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

@available(iOS 17.0, *)
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
                configuration.message.font(.subheadline)
                    .foregroundColor(.secondary)
                    
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
    }
}