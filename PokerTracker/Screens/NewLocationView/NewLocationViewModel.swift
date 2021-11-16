//
//  NewLocationViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/5/21.
//

import SwiftUI

final class NewLocationViewModel: ObservableObject {
    
    @Published var locationName: String = ""
    @Published var imageLocation: String = ""
}
