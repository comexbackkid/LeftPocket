//
//  WidgetBundle.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 3/20/24.
//

import Foundation
import WidgetKit
import SwiftUI
import ActivityKit

@main
struct LeftPocketWidgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        
        LeftPocketWidget()
        LeftPocketLiveSessionTimer()
    }
}
