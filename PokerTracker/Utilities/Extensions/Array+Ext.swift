//
//  Array+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/26/21.
//

import Foundation

// Allowing us to remove duplicates from an Array.
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}

// Helping with a bug for Locations that were deleted, & subsequently added back later creating duplicate search filters results.
extension Sequence where Element == LocationModel {
    func uniquedByName() -> [LocationModel] {
        var set = Set<String>()
        return filter { set.insert($0.name).inserted }
    }
}
