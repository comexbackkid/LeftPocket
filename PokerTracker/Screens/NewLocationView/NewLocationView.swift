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
    @State private var photoError: Error?
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack (alignment: .leading) {
                    
                    title
                    
                    description
                    
                    locationFields
                    
                    buttons
                    
                    Spacer()

                }
                .navigationBarHidden(true)
                .alert(item: $newLocationViewModel.alertItem) { alertItem in
                    Alert(title: alertItem.title,
                          message: alertItem.message,
                          dismissButton: alertItem.dismissButton)
                }
            }
            .background(Color.brandBackground)
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .accentColor(.brandPrimary)
        .errorAlert(error: $photoError)
        .task(id: photoPickerItem) {
            do {
                guard let photoPickerItem else { return }
                newLocationViewModel.importedImage = try await photoPickerItem.loadTransferable(type: Data.self)
      
            } catch {
                photoError = error
                photoPickerItem = nil
            }
        }
    }
    
    var title: some View {
        
        HStack {
            Text("New Location")
                .titleStyle()
                .padding(.top, 30)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var description: some View {
        
        Text("Enter the name of the location, and import a photo from your photo library. If you don't choose an image, a default graphic will be provided. ")
            .bodyStyle()
            .padding(.horizontal)
            .padding(.bottom, 40)
    }
    
    var buttons: some View {
        
        VStack {
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                newLocationViewModel.saveUserLocation(viewModel: vm)
                addLocationIsShowing = newLocationViewModel.presentation ?? true
                
            } label: {
                PrimaryButton(title: "Save Location")
            }
            .tint(Color.brandPrimary)
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                addLocationIsShowing.toggle()
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
        }
        .padding(.horizontal)
    }
    
    var locationFields: some View {
        
        // Location Name
        VStack {
            
            HStack {
                Image(systemName: "textformat.alt")
                    .font(.headline).frame(width: 25)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 10)
                
                TextField("Location Name", text: $newLocationViewModel.locationName)
                    .font(.custom("Asap-Regular", size: 17))
                    .submitLabel(.next)
                
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Photo Selection
            HStack {
                Image(systemName: newLocationViewModel.importedImage != nil ? "checkmark.circle.fill" : "photo")
                    .font(.headline).frame(width: 25)
                    .foregroundColor(newLocationViewModel.importedImage != nil ? .green : .secondary)
                    .padding(.trailing, 10)
                
                PhotosPicker(newLocationViewModel.importedImage != nil ? "Image Added!" : "Tap to Add Image", selection: $photoPickerItem)
                    .font(.custom("Asap-Regular", size: 17))
                    .foregroundColor(newLocationViewModel.importedImage != nil ? .primary : .brandPrimary)
                
                Spacer()
                    
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}

extension View {
    @ViewBuilder func errorAlert(error: Binding<Error?>) -> some View {
        let isPresented: Binding<Bool> = Binding<Bool>(get: { error.wrappedValue != nil }, set: { newValue in if newValue { error.wrappedValue = nil} })
        
        self
            .alert(error.wrappedValue?.localizedDescription ?? "A problem has occurred", isPresented: isPresented, actions: {
                Button("OK") { }
            })
    }
}

struct NewLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NewLocationView(addLocationIsShowing: .constant(true))
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
//            .environment(\.locale, Locale(identifier: "PT"))
    }
}
