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
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("Display")) {
                    Toggle(isOn: $isDarkMode, label: {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.yellow)
                        Text("Dark Mode")
                        
                    })
                }
                
                Section(header: Text("General")) {
                    NavigationLink(
                        destination: LocationsListView(viewModel: SessionsListViewModel()),
                        label: {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.red)
                            Text("Locations")
                        })
                    
                    NavigationLink(
                        destination: Text("Destination"),
                        label: {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                            Text("Import Data")
                        })
                    
                    NavigationLink(
                        destination: Text("Destination"),
                        label: {
                            Image(systemName: "hand.thumbsup")
                                .foregroundColor(.orange)
                            Text("Leave a Review")
                        })
                }
                
                Section {
                    Label(
                        title: { Text("Tweet @chrisnachtrieb for Support") },
                        icon: { Image(systemName: "link") }
)
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
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.uniqueLocations, id: \.self) { location in
                    Text(location)
                }
            }
            .navigationTitle("Locations")
        }
    }
}
