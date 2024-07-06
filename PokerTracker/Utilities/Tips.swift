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
        Text("To add your own location, tap the \(Image(systemName: "plus")) button above. Tap & hold a thumbnail to delete.")
    }
    
    var image: Image? {
        Image(systemName: "mappin.and.ellipse")
    }
}

@available(iOS 17.0, *)
struct MonthlyReportTip: Tip {
    
    var title: Text {
        Text("Reading the Metrics")
    }
    
    var message: Text? {
        Text("The \(Image(systemName: "trophy.fill")) column is your net profit, \(Image(systemName: "gauge.high")) your hourly, & \(Image(systemName: "clock")) your total hours for the month.")
    }
    
    var image: Image? {
        Image(systemName: "hand.point.down.fill")
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
        Text("Tap the \(Image(systemName: "plus")) button to log a completed session or start a live session.")
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
        Text("Tap \(Image(systemName: "slider.horizontal.3")) above to filter sessions by location, game type, stakes, etc.")
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
struct SettingsTip: Tip {
    
    var title: Text {
        Text("Did You Know?")
    }
    
    var message: Text? {
        Text("In Settings \(Image(systemName: "gearshape.fill")) you can enable push notifications, import & export data, and set custom session defaults.")
    }
    
    var image: Image? {
        Image(systemName: "text.magnifyingglass")
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
        Text("Tap & hold on charts to interact & view more detailed information.")
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
