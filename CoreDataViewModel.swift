//
//  CoreDataViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/19/21.
//

import Foundation
import CoreData

class CoreDataViewModel: ObservableObject {
    
    @Published var savedSessions: [SessionEntity] = []
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "SessionsContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("ERROR LOADING DATA. \(error)")
            }
        }
    }
    
    func fetchSessions() {
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        
        do {
            savedSessions = try container.viewContext.fetch(request)
        } catch let error {
            print("ERROR FETCHING. \(error)")
        }
    }
    
    func addSession() {
        
    }
}


