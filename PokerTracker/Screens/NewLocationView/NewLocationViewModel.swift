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
}
