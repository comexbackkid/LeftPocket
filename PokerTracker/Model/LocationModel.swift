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
}
