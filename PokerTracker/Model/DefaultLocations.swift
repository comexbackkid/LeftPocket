//
//  DefaultLocations.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/22/21.
//

import Foundation

struct DefaultLocations {
    
    static let allLocations = [
        
        LocationModel(name: "Encore Boston Harbor", localImage: "encore-header2", imageURL: ""),
        LocationModel(name: "The Lodge Card Club", localImage: "thelodge-header", imageURL: ""),
        LocationModel(name: "Bellagio Hotel & Casino", localImage: "bellagio-header", imageURL: ""),
        LocationModel(name: "Hustler Casino", localImage: "hustlercasino-header", imageURL: ""),
    ]
    
    // MARK: MIGRATION CODE
    
    static let defaultLocations = [
        LocationModel_v2(name: "Encore Boston Harbor", localImage: "encore-header2"),
        LocationModel_v2(name: "The Lodge Card Club", localImage: "thelodge-header"),
        LocationModel_v2(name: "Bellagio Hotel & Casino", localImage: "bellagio-header"),
        LocationModel_v2(name: "Hustler Casino", localImage: "hustlercasino-header")
    ]
}
