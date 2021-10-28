//
//  SettingsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsViewModel()
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Binding var isDarkMode: Bool
    
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
                    
                    Toggle(isOn: .constant(true), label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                        Text("Use System Display")
                    })
                }
                    
                Section(header: Text("General")) {
                    NavigationLink(
                        destination: LocationsListView(viewModel: settings),
                        label: {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.red)
                            Text("Locations")
                        })
                    
                    NavigationLink(
                        destination: Text("Import & Export your CSV here!"),
                        label: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.green)
                            Text("Manage Data")
                        })
                    
                    NavigationLink(
                        destination: Text("Leave a review!"),
                        label: {
                            Image(systemName: "hand.thumbsup")
                                .foregroundColor(.orange)
                            Text("Leave a Review")
                        })
                    
                    NavigationLink(
                        destination: Text("Help"),
                        label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.purple)
                            Text("Help")
                        })
                }
                
                Section(header: Text("About")) {
                    HStack {
                            Text("Version")
                            Spacer()
                            Text("0.1")
                        }
                }
                
                Section(header: Text("Contact")) {
                    Link(destination: URL(string: "https://twitter.com/chrisnachtrieb")!, label: {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.blue)
                            Text("For Support, Tweet @chrisnachtrieb")
                        }
                        
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDarkMode: .constant(false))
    }
}

struct LocationsListView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.getLocations(), id: \.self) { location in
                    Text(location.name)
                }
            }
            .navigationTitle("Locations")
        }
    }
}
