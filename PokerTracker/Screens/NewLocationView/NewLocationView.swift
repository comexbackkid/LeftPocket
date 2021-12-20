//
//  NewLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/29/21.
//

import SwiftUI

struct NewLocationView: View {
    
    @EnvironmentObject var sessionsListViewModel: SessionsListViewModel
    @StateObject var viewModel = NewLocationViewModel()
    @Binding var addLocationIsShowing: Bool
    
    var body: some View {
        
        NavigationView {
            Form {
                Section (header: Text("Information"),
                         footer: Text("Enter the name of the casino or card room, followed by a link to an image associated with the location.")) {
                    TextField("Location Name", text: $viewModel.locationName)
                    TextField("Paste Image URL (Optional)", text: $viewModel.imageURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                Section {
                    Button(action: {
                        saveLocation()
                        addLocationIsShowing.toggle()
                    }, label: {
                        Text("Save Location")
                    })
                }
            }
            .navigationBarTitle(Text("New Location"))
        }
        .accentColor(.brandPrimary)
    }
    
    func saveLocation() {
        sessionsListViewModel.addLocation(name: viewModel.locationName,
                                          localImage: "",
                                          imageURL: viewModel.imageURL)
    }
}

struct NewLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NewLocationView(addLocationIsShowing: .constant(true))
            .environmentObject(SessionsListViewModel())
    }
}
