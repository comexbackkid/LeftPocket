//
//  Array+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/26/21.
//

import Foundation

// Allowing us to remove duplicates from an Array. Being used in ProfityByMonth view
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
