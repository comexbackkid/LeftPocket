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

// TODO: TASKS

// 1. Kill imageURL. This is from ages ago when we were using async image to download a link to an image
// 2. importedImage needs to be of type String, not Data, simply point to file where imported image is saved to after user imports
// 3. Why did I make these properties all variables? We probably do want the ability to change the image / name of it in the future, so maybe we want that
// 4. Maybe we should make both image properties optional, and then how do we handle the default-location image? We already have one. Do it in the views?
// 5. Are we handling Location IDs the best way? Check to see if initialiaztion here makes sense with ID

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
