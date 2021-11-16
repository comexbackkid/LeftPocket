//
//  LocationModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/26/21.
//

import SwiftUI

struct LocationModel: Decodable, Encodable, Hashable {
    var id = UUID()
    var name: String
    var imageURL: String
}
