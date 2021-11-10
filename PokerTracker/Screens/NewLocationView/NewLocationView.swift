//
//  NewLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/29/21.
//

import SwiftUI

struct NewLocationView: View {
    
    @StateObject var viewModel = NewLocationViewModel()
    @Binding var addLocationIsShowing: Bool
    
    var body: some View {
        
        NavigationView {
            Form {
                Section (header: Text("Location Info"),
                         footer: Text("Enter the name of the venue or card room, followed by a link to an image associated with the location.")) {
                    TextField("Location Name", text: $viewModel.locationName)
                    TextField("Paste Image URL", text: $viewModel.imageLocation)
                }
                Section {
                    Button(action: {}, label: {
                        Text("Save Location")
                    })
                }
            }
            .navigationBarTitle(Text("Add New Location"))
        }
    }
}

struct NewLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NewLocationView(addLocationIsShowing: .constant(true))
    }
}
