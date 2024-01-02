//
//  NewLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/29/21.
//

import SwiftUI
import PhotosUI

struct NewLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: SessionsListViewModel
    @StateObject var newLocationViewModel = NewLocationViewModel()
    @Binding var addLocationIsShowing: Bool
    
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    
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
                             footer: Text("Enter the name of the Location, followed by the link to an image for its thumbnail & Detail header. It's recommended to upload an image to Imgur.com first, and then create a hyperlink from there. If no image link is given, a default graphic will be provided.")) {
                       
                        TextField("Location Name", text: $newLocationViewModel.locationName)
                            .font(.custom("Asap-Regular", size: 17))
                            .submitLabel(.next)
                        
                        TextField("Paste Image URL (Optional)", text: $newLocationViewModel.imageURL)
                            .font(.custom("Asap-Regular", size: 17))
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                        
                        // Want to add ability for user to import a photo, instead of using a URL from the web
                        // How do we handle the image file? Might need to adjust the LocationModel struct, add a new var "importedImage:"
                        PhotosPicker("Import Header Photo", selection: $photoPickerItem, matching: .images)
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
            .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemGray6))
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
