//
//  ViewModifiers.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct AccountingView: ViewModifier {
    
    let total: Int
    
    func body(content: Content) -> some View {
        content
            .foregroundColor( total > 0 ? .green : total < 0 ? .red : Color(.systemGray))
    }
}
