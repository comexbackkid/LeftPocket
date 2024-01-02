//
//  NewLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/29/21.
//

import SwiftUI
import PhotosUI

extension View {
    @ViewBuilder func errorAlert(error: Binding<Error?>) -> some View {
        let isPresented: Binding<Bool> = Binding<Bool>(get: { error.wrappedValue != nil }, set: { newValue in if newValue { error.wrappedValue = nil} })
        
       self
            .alert(error.wrappedValue?.localizedDescription ?? "A problem has occurred", isPresented: isPresented, actions: {
                Button("OK") { }
            })
    }
}

struct NewLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: SessionsListViewModel
    @StateObject var newLocationViewModel = NewLocationViewModel()
    @Binding var addLocationIsShowing: Bool
    
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var photoError: Error?
    
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
                             footer: Text("Enter the name of the Location, and import a photo of your choice for the Location header. If you don't import an image, a default graphic will be provided.")) {
                       
                        TextField("Location Name", text: $newLocationViewModel.locationName)
                            .font(.custom("Asap-Regular", size: 17))
                            .submitLabel(.next)
                        
                        PhotosPicker(selection: $photoPickerItem) {
                            Label(
                                title: { Text("Import Header Photo").font(.custom("Asap-Regular", size: 17)) },
                                icon: { Image(systemName: selectedImageData != nil ? "checkmark.circle.fill" : "photo")
                                    .foregroundColor(selectedImageData != nil ? .green : .brandPrimary)}
                            )
                        }
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
        .errorAlert(error: $photoError)
        .task(id: photoPickerItem) {
            
            do {
                guard let photoPickerItem else { return }
                selectedImageData = try await photoPickerItem.loadTransferable(type: Data.self)
      
            } catch {
                photoError = error
                photoPickerItem = nil
            }
        }
    }
    
    func saveLocation() {
        vm.addLocation(name: newLocationViewModel.locationName,
                       localImage: "",
                       imageURL: newLocationViewModel.imageURL,
                       importedImage: selectedImageData)
    }
}

struct NewLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NewLocationView(addLocationIsShowing: .constant(true))
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
