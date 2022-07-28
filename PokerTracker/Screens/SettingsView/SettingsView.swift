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
                Section(header: Text("Display"),
                        footer: Text("Using System Display will override Dark Mode and use current device preferences.")) {
                    Toggle(isOn: $isDarkMode, label: {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.yellow)
                        Text("Dark Mode")
                    })
                        .onChange(of: isDarkMode, perform: { _ in
                            SystemThemeManager
                                .shared
                                .handleTheme(darkMode: isDarkMode,
                                             system: systemThemeEnabled)
                        })
                    
                    Toggle(isOn: $systemThemeEnabled, label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                        Text("Use System Display")
                    })
                        .onChange(of: systemThemeEnabled, perform: { _ in
                            SystemThemeManager
                                .shared
                                .handleTheme(darkMode: isDarkMode,
                                             system: systemThemeEnabled)
                        })
                }
                
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
            .navigationTitle("Settings")
        }
        .accentColor(.brandPrimary)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDarkMode: .constant(false), systemThemeEnabled: .constant(false))
            .environmentObject(SessionsListViewModel())
    }
}
