//
//  Animations+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/8/21.
//

import SwiftUI

extension Animation {
    static func customBarChartAnimation(index: Int) -> Animation {
        Animation.easeInOut(duration: 1)
            .delay(0.8 * Double(index))
    }
}
