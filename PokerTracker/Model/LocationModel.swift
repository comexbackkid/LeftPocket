//
//  LocationModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/26/21.
//

import SwiftUI

// MARK: OLD LOCATION MODEL

struct LocationModel: Decodable, Encodable, Hashable, Identifiable {
    var id: String { name }
    var name: String
    var localImage: String
    var imageURL: String
    var importedImage: Data?
}

// MARK: NEW LOCATION MODEL

struct LocationModel_v2: Decodable, Encodable, Hashable, Identifiable {
    var id: String
    var name: String
    var localImage: String?
    var importedImage: String?
    
    init(id: String = UUID().uuidString, name: String, localImage: String? = nil, importedImage: String? = nil) {
        self.id = id
        self.name = name
        self.localImage = localImage
        self.importedImage = importedImage
    }
}
