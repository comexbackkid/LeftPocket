//
//  SettingsViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/26/21.
//

import Foundation

class SettingsViewModel: ObservableObject {

    private var locations = [LocationModel]()
    
    func createDummyData() {
        self.locations.append(LocationModel(name: "Encore Boston Harbor", imageURL: "encore-header"))
        self.locations.append(LocationModel(name: "Chaser's Poker Room", imageURL: "chasers-header"))
        self.locations.append(LocationModel(name: "Boston Billiards Club", imageURL: "boston-billiards-header"))
        self.locations.append(LocationModel(name: "The Brook", imageURL: "brook-header"))
        self.locations.append(LocationModel(name: "Foxwoods Resort & Casino", imageURL: "foxwoods-header"))
        self.saveLocations()
    }
    
    func getLocations() -> [LocationModel]{
        if self.locations.count == 0 {
            createDummyData()
            return self.locations
        } else {
            guard
                let data = UserDefaults.standard.data(forKey: "locations_list"), // locations-list
                let locationsData = try? JSONDecoder().decode([LocationModel].self, from: data)
            else { return [LocationModel]() }
            
            self.locations = locationsData
            return self.locations
        }
    }
    
    func saveLocations(){
        if let encodedData = try? JSONEncoder().encode(self.locations){
            UserDefaults.standard.set(encodedData, forKey: "locations_list")
        }
    }
}
