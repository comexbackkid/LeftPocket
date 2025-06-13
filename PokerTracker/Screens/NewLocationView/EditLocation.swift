//
//  EditLocation.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/12/25.
//

import SwiftUI
import PhotosUI

struct EditLocation: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var name: String
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var photoError: Error?
    @State private var selectedImage: UIImage?
    
    let location: LocationModel_v2
    
    init(location: LocationModel_v2) {
        self.location = location
        _name = State(initialValue: location.name)
        
        if let imported = location.importedImage {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imageURL = docs.appendingPathComponent("LocationImages").appendingPathComponent(imported)
            _selectedImage = State(initialValue: UIImage(contentsOfFile: imageURL.path))
            
        } else if let local = location.localImage {
            _selectedImage = State(initialValue: UIImage(named: local))
            
        } else {
            _selectedImage = State(initialValue: UIImage(named: "defaultlocation-header"))
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack (alignment: .leading) {
                    
                    title
                    
                    description
                    
                    locationInformation
                    
                    buttons
                }
                .navigationBarHidden(true)
            }
            .background(Color.brandBackground)
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .accentColor(.brandPrimary)
        .errorAlert(error: $photoError)
        .onChange(of: photoPickerItem) { _, newItem in
            Task { await loadPhoto(newItem) }
        }
    }
    
    private func loadPhoto(_ item: PhotosPickerItem?) async {
        
        guard let item else { return }
        do {
            let data = try await item.loadTransferable(type: Data.self)
            if let data, let ui = UIImage(data: data) {
                selectedImage = ui
            }
            
            
        } catch {
            photoError = error
        }
    }
    
    private func saveChanges() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDir = docs.appendingPathComponent("LocationImages")
        
        var newImported = location.importedImage
        
        if photoPickerItem != nil, let ui = selectedImage, let jpeg = ui.jpegData(compressionQuality: 0.8) {
            
            let baseName: String
            if let old = location.importedImage {
                baseName = (old as NSString).deletingPathExtension
                
            } else {
                baseName = location.id
            }
            
            if let old = location.importedImage {
                let oldPath = imagesDir.appendingPathComponent(old).path
                FileManager.deleteImage(atPath: oldPath)
            }
            
            do {
                newImported = try FileManager.saveImage(jpeg, withName: baseName)
                
            } catch {
                photoError = error
                return
            }
        }
        
        let updated = LocationModel_v2(id: location.id, name: name, localImage: nil, importedImage: newImported)
        vm.updateLocation(updated)
        dismiss()
    }
    
    var title: some View {
        
        HStack {
            Text("Edit Location")
                .titleStyle()
                .padding(.top, 30)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var description: some View {
        
        Text("Tap the pencil button below to change the Location's photo to a new one.")
            .bodyStyle()
            .padding(.horizontal)
            .padding(.bottom, 40)
    }
    
    var locationInformation: some View {
        
        HStack (alignment: .top) {
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .centerCropped()
                    .frame(width: 140, height: 100)
                    .clipShape(.rect(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 4))
                    .overlay {
                        VStack {
                            HStack {
                                Spacer()
                                
                                PhotosPicker(selection: $photoPickerItem) {
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .fontWeight(.black)
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.brandPrimary)
                                        .padding(7)
                                        .background(.white)
                                        .clipShape(.circle)
                                        .offset(x: 10, y: -10)
                                        .shadow(radius: 5)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, 25)
                
            } else {
                Image("defaultlocation-header")
                    .centerCropped()
                    .frame(width: 140, height: 100)
                    .clipShape(.rect(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 4))
                    .overlay {
                        VStack {
                            HStack {
                                Spacer()
                                
                                PhotosPicker(selection: $photoPickerItem) {
                                    Image(systemName: "pencil")
                                        .resizable()
                                        .fontWeight(.black)
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.brandBackground)
                                        .padding(7)
                                        .background(.white)
                                        .clipShape(.circle)
                                        .offset(x: 10, y: -10)
                                        .shadow(radius: 5)
                                        .onTapGesture {
                                            let impact = UIImpactFeedbackGenerator(style: .soft)
                                            impact.impactOccurred()
                                        }
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, 25)
            }
            
            VStack (alignment: .leading, spacing: 3) {
                
                Text("Location Name")
                    .calloutStyle()
                    .opacity(0.75)
                
                Text(location.name)
                    .cardTitleStyle()
                
            }
            .padding(.horizontal)
        }
    }
    
    var buttons: some View {
        
        VStack (alignment: .center) {
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                saveChanges()
                
            } label: {
                PrimaryButton(title: "Save Changes")
                    .padding(.horizontal)
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                dismiss()
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
        }
    }
}

extension SessionsListViewModel {
    
    func updateLocation(_ updated: LocationModel_v2) {
        guard let idx = locations.firstIndex(where: { $0.id == updated.id }) else {
            return
        }
        
        locations[idx] = updated
    }
}


#Preview {
    EditLocation(location: MockData.mockLocation)
}
