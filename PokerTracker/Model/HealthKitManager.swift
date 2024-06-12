//
//  HealthKitManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/1/24.
//

import SwiftUI
import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    
    let store = HKHealthStore()
    let types: Set = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
    
    @Published var sleepData: [SleepMetric] = []
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var errorMsg: String?
    
    func checkAuthorizationStatus() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.authorizationStatus = .notDetermined
            }
            return
        }
        
        await withCheckedContinuation { continuation in
            store.getRequestStatusForAuthorization(toShare: [], read: types) { (status, error) in
                DispatchQueue.main.async {
                    switch status {
                    case .unnecessary:
                        self.authorizationStatus = .sharingAuthorized
                    case .shouldRequest:
                        self.authorizationStatus = .notDetermined
                    case .unknown:
                        self.authorizationStatus = .sharingDenied
                    @unknown default:
                        self.authorizationStatus = .sharingDenied
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    func requestAuthorization() {
        store.requestAuthorization(toShare: [], read: types) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.authorizationStatus = .sharingAuthorized
                } else {
                    self.authorizationStatus = .sharingDenied
                }
            }
        }
    }
    
    // Need to have multiple points where we catch and throw errors, and then later handle them in the UI
    // Research the authorizationStatus, Sean Allen pointed out that if sharing is allowed, it doesn't have anything to do with FETCHING data...?
    @MainActor
    func fetchSleepData() async throws {
        guard store.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!) != .notDetermined else {
            throw HKError.authNotDetermined
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -28, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (query, result, error) in
            guard error == nil else {
                self?.errorMsg = error?.localizedDescription
//                print("Error fetching sleep data: \(String(describing: error))")
                return
            }
            
            var sleepMetrics: [SleepMetric] = []
            
            if let result = result {
                let calendar = Calendar.current
                
                var dailySleepTimes: [Date: Double] = [:]
                
                for sample in result {
                    if let categorySample = sample as? HKCategorySample {
                        if HKCategoryValueSleepAnalysis.allAsleepValues.map({$0.rawValue}).contains(categorySample.value) {
                            
                            let adjustedStartDate = self?.adjustedDateForGrouping(date: categorySample.startDate, calendar: calendar) ?? categorySample.startDate
                            let sleepTime = categorySample.endDate.timeIntervalSince(categorySample.startDate) / 3600
                            
                            // Add sleep time to the next day
                            let nextDay = calendar.date(byAdding: .day, value: 1, to: adjustedStartDate)!
                            if let existingSleepTime = dailySleepTimes[nextDay] {
                                dailySleepTimes[nextDay] = existingSleepTime + sleepTime
                            } else {
                                dailySleepTimes[nextDay] = sleepTime
                            }
                        }
                    }
                }
                
                for (date, totalSleepTime) in dailySleepTimes {
                    let sleepMetric = SleepMetric(date: date, value: totalSleepTime)
                    sleepMetrics.append(sleepMetric)
                }
                
                sleepMetrics.sort { $0.date < $1.date }
            }
            
            DispatchQueue.main.async {
                self?.sleepData = sleepMetrics
            }
        }
        
        store.execute(query)
    }
    
    private func adjustedDateForGrouping(date: Date, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        // Adjust the date if the hour is before 6 PM
        if let hour = components.hour, hour < 18 {
            components.day! -= 1
        }
        
        components.hour = 18
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components) ?? date
    }
}

extension HKCategoryValueSleepAnalysis {
    static var allAsleepValues: Set<HKCategoryValueSleepAnalysis> {
        return [.asleepUnspecified, .asleepCore, .asleepDeep, .asleepREM]
    }
    
    static func predicateForSamples(equalTo values: Set<HKCategoryValueSleepAnalysis>) -> NSPredicate {
        return NSPredicate(format: "value IN %@", values.map { $0.rawValue })
    }
}

enum HKError: Error {
    case authNotDetermined
    case sharingDenied
    case noData
    case unableToCompleteRequest
    
    var description: String {
            switch self {
            case .authNotDetermined:
                return "An error occured. HealthKit authorization could not be determined."
            case .sharingDenied:
                return "An error occured. HealthKit authorization was denied."
            case .noData:
                return "An error occured. HealthKit returned no sleep data."
            case .unableToCompleteRequest:
                return "An error occured. Unable to complete request."
            }
        }
}
