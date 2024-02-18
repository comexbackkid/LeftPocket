//
//  EditLocationView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/26/22.
//

import SwiftUI

struct EditLocationView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedLocation: LocationModel
    let initialLocation: LocationModel
    
    init(location: Binding<LocationModel>) {
        initialLocation = location.wrappedValue
        _selectedLocation = location
    }
    
    var body: some View {
        
        Form {
            
            Section (header: Text("Information"),
                     footer: Text("Edit the name or Image URL to update this Location. Copy & paste the image's link directly from your mobile web browser.")) {
                
                TextField("", text: $selectedLocation.name)
                    .font(.custom("Asap-Regular", size: 17))
                    .submitLabel(.next)
                
                TextField("Paste Image URL (Optional)", text: $selectedLocation.imageURL)
                    .font(.custom("Asap-Regular", size: 17))
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }
            
            Section {
                Button(action: {
                    viewModel.saveLocations()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Save Changes")
                        .bodyStyle()
                })
                
                Button {
                    selectedLocation = initialLocation
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .bodyStyle()
                }
                .tint(.red)
            }
        }
        .accentColor(.brandPrimary)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Edit Location")
    }
}

struct EditLocationView_Previews: PreviewProvider {
    static var previews: some View {
        EditLocationView(location: .constant(MockData.mockLocation))
    }
}
