//
//  AppGroup.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/10/22.
//

import Foundation
import WidgetKit


public func writeBankrollToUserDefaults(bankroll: Int, lastSessionAmount: Int) {
    UserDefaults(suiteName: "group.bankrollData")!.set(bankroll, forKey: "bankrollTotal")
    UserDefaults(suiteName: "group.bankrollData")!.set(lastSessionAmount, forKey: "lastSessionAmount")
    WidgetCenter.shared.reloadAllTimelines()
}
