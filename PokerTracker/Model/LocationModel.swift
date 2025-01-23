//
//  LocationModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/26/21.
//

import SwiftUI

struct LocationModel: Decodable, Encodable, Hashable, Identifiable {
    var id: String { name }
    var name: String
    var localImage: String
    var imageURL: String
    var importedImage: Data?
}

// MARK: TASKS

// 1. Kill imageURL. This is from ages ago when we were using async image to download a link to an image
// 2. importedImage needs to be of type String, not Data, simply point to file where imported image is saved to after user imports
