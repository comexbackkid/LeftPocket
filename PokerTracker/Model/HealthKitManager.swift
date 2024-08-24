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
                    
                    if error != nil {
                        self.errorMsg = error?.localizedDescription
                    }
                    
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
    
    @MainActor
    func fetchSleepData() async throws {
            guard store.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!) != .sharingAuthorized else {
                throw HKError.authNotDetermined
            }
            
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -59, to: endDate)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            return try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (query, result, error) in
                    if error != nil {
                        continuation.resume(throwing: HKError.unableToQuerySleepData)
                        return
                    }
                    
                    var asleepSleepMetrics: [SleepMetric] = []
                    var inBedSleepMetrics: [SleepMetric] = []
                    
                    if let result = result {
                        let calendar = Calendar.current
                        
                        var dailyAsleepTimes: [Date: Double] = [:]
                        var dailyInBedTimes: [Date: Double] = [:]
                        
                        for sample in result {
                            if let categorySample = sample as? HKCategorySample {
                                let adjustedStartDate = self?.adjustedDateForGrouping(date: categorySample.startDate, calendar: calendar) ?? categorySample.startDate
                                let sleepTime = categorySample.endDate.timeIntervalSince(categorySample.startDate) / 3600
                                
                                // Add sleep time to the next day
                                let nextDay = calendar.date(byAdding: .day, value: 1, to: adjustedStartDate)!
                                
                                // We're checking if the user has actual sleep data. If no, we default to using "In Bed" numbers generated from the Health App.
                                if HKCategoryValueSleepAnalysis.allAsleepValues.map({ $0.rawValue }).contains(categorySample.value) {
                                    if let existingSleepTime = dailyAsleepTimes[nextDay] {
                                        dailyAsleepTimes[nextDay] = existingSleepTime + sleepTime
                                    } else {
                                        dailyAsleepTimes[nextDay] = sleepTime
                                    }
                                } else if categorySample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                                    if let existingSleepTime = dailyInBedTimes[nextDay] {
                                        dailyInBedTimes[nextDay] = existingSleepTime + sleepTime
                                    } else {
                                        dailyInBedTimes[nextDay] = sleepTime
                                    }
                                }
                            }
                        }
                        
                        // Combine asleep and inBed data
                        for (date, inBedTime) in dailyInBedTimes {
                            if dailyAsleepTimes[date] == nil {
                                dailyAsleepTimes[date] = inBedTime
                            }
                        }
                        
                        for (date, totalSleepTime) in dailyAsleepTimes {
                            let sleepMetric = SleepMetric(date: date, value: totalSleepTime)
                            asleepSleepMetrics.append(sleepMetric)
                        }
                    }
                    
                    var finalSleepMetrics = asleepSleepMetrics.isEmpty ? inBedSleepMetrics : asleepSleepMetrics
                    finalSleepMetrics.sort { $0.date < $1.date }
                    
                    // Filter out the first day
                    if finalSleepMetrics.count > 1 {
                        finalSleepMetrics.removeFirst()
                    }
                    
                    DispatchQueue.main.async {
                        self?.sleepData = finalSleepMetrics
                    }
                    
                    continuation.resume()
                }
                
                store.execute(query)
            }
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
    case unableToQuerySleepData
    case unableToCompleteRequest
    
    var description: String {
            switch self {
            case .authNotDetermined:
                return "An error occurred. HealthKit authorization could not be determined."
            case .sharingDenied:
                return "An error occurred. HealthKit authorization was denied."
            case .noData:
                return "An error occurred. HealthKit returned no sleep data."
            case .unableToQuerySleepData:
                return "An error occurred. Unable to query sleep data from device."
            case .unableToCompleteRequest:
                return "An error occurred. Unable to complete request."
            }
        }
}
