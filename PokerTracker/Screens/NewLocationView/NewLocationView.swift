//
//  NewLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/29/21.
//

import SwiftUI

struct NewLocationView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @StateObject var newLocationViewModel = NewLocationViewModel()
    @Binding var addLocationIsShowing: Bool
    
    var body: some View {
        
        NavigationView {
            Form {
                
                Section (header: Text("Information"),
                         footer: Text("Enter the name of the casino or card room, followed by a link to an image associated with the location.")) {
                   
                    TextField("Location Name", text: $newLocationViewModel.locationName)
                        .submitLabel(.next)
                    
                    TextField("Paste Image URL (Optional)", text: $newLocationViewModel.imageURL)
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
                    
                    Button(role: .cancel) {
                        addLocationIsShowing.toggle()
                    } label: {
                        Text("Cancel")
                    }
                    .tint(.red)
                }
            }
            .navigationBarTitle(Text("Add Location"))
        }
        .accentColor(.brandPrimary)
    }
    
    func saveLocation() {
        vm.addLocation(name: newLocationViewModel.locationName,
                                          localImage: "",
                                          imageURL: newLocationViewModel.imageURL)
    }
}

struct NewLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NewLocationView(addLocationIsShowing: .constant(true))
            .environmentObject(SessionsListViewModel())
    }
}
