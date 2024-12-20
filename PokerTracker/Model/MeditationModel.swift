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
    
    static let meditations: [Meditation] = [forest, city, snow, beach]
    
    static let forest = Meditation(title: "Forest Ambiance", background: "meditation-forest", track: "forest", duration: 275)
    static let city = Meditation(title: "City Rain", background: "meditation-city", track: "city", duration: 176)
    static let snow = Meditation(title: "Winter Cabin", background: "meditation-snow", track: "snow", duration: 205)
    static let beach = Meditation(title: "Beach Escape", background: "meditation-beach", track: "beach", duration: 178)
}
