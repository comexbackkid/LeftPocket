//
//  NewLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/29/21.
//

import SwiftUI

struct NewLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: SessionsListViewModel
    @StateObject var newLocationViewModel = NewLocationViewModel()
    @Binding var addLocationIsShowing: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                HStack {
                    Text("New Location")
                        .titleStyle()
                        .padding(.horizontal)
                    
                    Spacer()
                }
                
                Form {
                    
                    Section (header: Text("Information"),
                             footer: Text("Enter the name of the casino or card room, followed by a link to an image associated with the location.")) {
                       
                        TextField("Location Name", text: $newLocationViewModel.locationName)
                            .font(.custom("Asap-Regular", size: 17))
                            .submitLabel(.next)
                        
                        TextField("Paste Image URL (Optional)", text: $newLocationViewModel.imageURL)
                            .font(.custom("Asap-Regular", size: 17))
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    
                    Section {
                        
                        Button(action: {
                            saveLocation()
                            addLocationIsShowing.toggle()
                        }, label: {
                            Text("Save Location")
                                .bodyStyle()
                        })
                        
                        Button(role: .cancel) {
                            addLocationIsShowing.toggle()
                        } label: {
                            Text("Cancel")
                                .bodyStyle()
                        }
                        .tint(.red)
                    }
                }
                .scrollDisabled(true)
                .navigationBarTitle(Text(""))
            }
            .background(colorScheme == .light ? Color(.systemGray6) : .black)
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
            .preferredColorScheme(.dark)
    }
}
