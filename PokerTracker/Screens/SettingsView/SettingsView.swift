//
//  SettingsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
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
                        destination: LocationsListView(viewModel: viewModel),
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
                        destination: HelpView(),
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
        .accentColor(Color("brandPrimary"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDarkMode: .constant(false), systemThemeEnabled: .constant(false))
            .environmentObject(SessionsListViewModel())
    }
}

struct LocationsListView: View {
    
    @ObservedObject var viewModel: SessionsListViewModel
    @State var addLocationIsShowing = false
    
    var body: some View {
        VStack (alignment: .leading) {

            List {
                Section (header: Text("CURRENT LOCATIONS"),
                         footer: Text("Add your own locations by clicking the + button in the upper right corner of the screen.")) {
                ForEach(viewModel.locations, id: \.self) { location in
                    Text(location.name)
                }
                .onDelete(perform: { indexSet in
                    viewModel.locations.remove(atOffsets: indexSet)
                })
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Locations")
            .navigationBarItems(trailing:
                                    Button(action: {
                                        addLocationIsShowing.toggle()
                                    }, label: {
                                        Image(systemName: "plus")
                                    }))
            .sheet(isPresented: $addLocationIsShowing, content: {
                NewLocationView(addLocationIsShowing: $addLocationIsShowing)
            })
        }
    }
}
