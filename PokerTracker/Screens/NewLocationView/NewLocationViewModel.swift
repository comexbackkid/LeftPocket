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
    
    func saveUserLocation(viewModel: SessionsListViewModel) {
        guard !locationName.isEmpty else {
            alertItem = AlertContext.inValidLocationName
            return
        }
        
        let capitalizedName = locationName.capitalized
        var imagePath: String?
        
        if let importedImage {
            do {
                imagePath = try FileManager.saveImage(importedImage, withName: UUID().uuidString)
                
            } catch {
                alertItem = AlertItem(title: Text("Error"), message: Text("Failed to save image."), dismissButton: .default(Text("OK")))
                return
            }
        }
        
        viewModel.addNewLocation(name: capitalizedName, importedImage: imagePath)
        self.presentation = false
    }
}

extension FileManager {
    
    // Saves the image to FileManager instead, and capture the path for reference later
    static func saveImage(_ imageData: Data, withName name: String) throws -> String {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDirectory = documentsURL.appendingPathComponent("LocationImages")
        
        // Ensure the directory exists
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        let imageURL = imagesDirectory.appendingPathComponent("\(name).jpg")
        try imageData.write(to: imageURL, options: .atomic)
            
        return "\(name).jpg"
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
