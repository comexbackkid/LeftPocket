//
//  QuickActionTypes.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/17/24.
//

import Foundation
import UIKit

enum QuickAction: String {
    
    case addNewSession = "AddNewSession"
    case enterTransaction = "EnterTransaction"
    case viewAllSessions = "ViewAllSessions"
    
}

enum QA: Equatable {
    
    case addNewSession
    case enterTransaction
    case viewAllSessions
    
    init?(shortcutItem: UIApplicationShortcutItem) {
        
        guard let action = QuickAction(rawValue: shortcutItem.type) else {
            return nil
        }
        
        switch action {
        case .addNewSession:
            self = .addNewSession
        case .enterTransaction:
            self = .enterTransaction
        case .viewAllSessions:
            self = .viewAllSessions
        }
    }
}

class QAService: ObservableObject {
    
    static let shared = QAService()
    @Published var action: QA?
    
}
