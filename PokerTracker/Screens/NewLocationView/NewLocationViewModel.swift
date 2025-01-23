//
//  NewLocationViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/5/21.
//

import SwiftUI

final class NewLocationViewModel: ObservableObject {
    
    @Published var locationName: String = ""
    @Published var imageLocation: String = ""
    @Published var imageURL: String = ""
    @Published var importedImage: Data?
    @Published var presentation: Bool?
    @Published var alertItem: AlertItem?
    
    var isValidForm: Bool {
        
        guard !locationName.isEmpty else {
            
            alertItem = AlertContext.inValidLocationName
            return false
            
        }
        
        return true
    }
    
    func saveLocation(viewModel: SessionsListViewModel) {
        
        guard self.isValidForm else { return }
        viewModel.addLocation(name: locationName, localImage: "", imageURL: imageURL, importedImage: importedImage)
        
        self.presentation = false
    }
    
    // MARK: MIGRATION CODE
    
    func saveUserLocation(viewModel: SessionsListViewModel) {
        guard !locationName.isEmpty else {
            alertItem = AlertItem(title: Text("Error"), message: Text("Please enter a Location name."), dismissButton: .default(Text("OK")))
            return
        }
        
        var imagePath: String?
        
        if let importedImage {
            do {
                imagePath = try FileManager.saveImage(importedImage, withName: UUID().uuidString)
            } catch {
                alertItem = AlertItem(title: Text("Error"), message: Text("Failed to save image."), dismissButton: .default(Text("OK")))
                return
            }
        }
        
        // Is this fine? If we're making importedImage optional anyway, if the value is nil nothing should crash and we default to a default location image on the view
        let newLocation = Location(name: locationName, importedImage: imagePath)
        
        // TODO: Add function to to save the Location to our "var Locations" in SessionsListViewModel
    }
}

extension FileManager {
    // Saves the image to FileManager instead, and capture the path for reference later
    static func saveImage(_ imageData: Data, withName name: String) throws -> String {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = documentsURL.appendingPathComponent("\(name).jpg")
        
        try imageData.write(to: imageURL, options: .atomic)
        return imageURL.path
    }
    
    // Run when deleting a Location
    static func deleteImage(atPath path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("Error deleting image: \(error)")
        }
    }
}
