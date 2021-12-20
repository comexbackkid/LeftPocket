//
//  NewLocationViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/5/21.
//

import SwiftUI

final class NewLocationViewModel: ObservableObject {
    
    // This will store any NEW location with a proper URL.
    // Our Location Model will need to include imageLocation (for our pre-loaded locations) and imageURL.
    // Any new Location that gets added will default to having a blank imageLocation.
    // In our DetailView, have it check to see if imageLocation is blank. If it is, pull AysncImage using imageURL.
    // Vice Versa, if imageURL is blank, have it display the imageLocation info which is stored locally.
    
    @Published var locationName: String = ""
    @Published var imageLocation: String = ""
    @Published var imageURL: String = ""
}
