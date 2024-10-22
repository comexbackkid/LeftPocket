//
//  MeditationModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/21/24.
//

import Foundation
import SwiftUI

struct Meditation: Codable, Hashable, Identifiable {
    
    var id = UUID()
    let title: String
    let background: String
    let track: String
    let duration: TimeInterval
    
    static let meditations: [Meditation] = [forest, city]
    
    static let forest = Meditation(title: "Forest Ambiance", background: "meditation-forest", track: "forest", duration: 177)
    static let city = Meditation(title: "City Sounds", background: "meditation-city", track: "city", duration: 177)
}
