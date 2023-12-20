//
//  SettingsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var isDarkMode: Bool
    @Binding var systemThemeEnabled: Bool
    
    var body: some View {
        
        NavigationView {
            
            Form {

                displaySection
                
                generalSection
                
                contactSection
                
            }
            .navigationTitle("Settings")
        }
        .accentColor(.brandPrimary)
    }
    
    var displaySection: some View {
        
        Section(header: Text("Display"),
                footer: Text("Using System Display will override Dark Mode and use current device preferences.")) {
            Toggle(isOn: $isDarkMode, label: {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.yellow)
                    Text("Dark Mode")
                }
            })
                .onChange(of: isDarkMode, perform: { _ in
                    SystemThemeManager
                        .shared
                        .handleTheme(darkMode: isDarkMode,
                                     system: systemThemeEnabled)
                })
            
            Toggle(isOn: $systemThemeEnabled, label: {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                    Text("Use System Display")
                }
            })
                .onChange(of: systemThemeEnabled, perform: { _ in
                    SystemThemeManager
                        .shared
                        .handleTheme(darkMode: isDarkMode,
                                     system: systemThemeEnabled)
                })
        }
    }
    
    var generalSection: some View {
        
        Section(header: Text("General")) {
            NavigationLink(
                destination: LocationsListView(),
                label: {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    Text("Locations")
                })
            
            NavigationLink(
                destination: HelpView(),
                label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.purple)
                    Text("Help")
                })
            
            Link(destination: URL(string: "https://apps.apple.com/us/app/left-pocket/id1601858981")!,
                 label: {
                HStack {
                    Image(systemName: "hand.thumbsup")
                        .foregroundColor(.orange)
                    Text("Leave a Review")
                }
            })
                .buttonStyle(PlainButtonStyle())
        }
    }
    
    var contactSection: some View {
        
        Section(header: Text("Contact")) {
            Link(destination: URL(string: "https://twitter.com/chrisnachtrieb")!,
                 label: {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                    Text("Contact Support")
                }
            })
                .buttonStyle(PlainButtonStyle())
        }
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDarkMode: .constant(false), systemThemeEnabled: .constant(false))
            .environmentObject(SessionsListViewModel())
    }
}
