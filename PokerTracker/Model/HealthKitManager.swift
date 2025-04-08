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
    let types: Set = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, HKObjectType.categoryType(forIdentifier: .mindfulSession)!]
    let typesToShare: Set = [HKObjectType.categoryType(forIdentifier: .mindfulSession)!]
    
    @Published var sleepData: [SleepMetric] = []
    @Published var mindfulMinutes: Double = 0.0
    @Published var totalMindfulMinutesPerDay: [Date: Double] = [:]
    @Published var totalMindfulMinutesThisWeek: Int = 0
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
            store.getRequestStatusForAuthorization(toShare: typesToShare, read: types) { (status, error) in
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
        store.requestAuthorization(toShare: typesToShare, read: types) { (success, error) in
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
        let startDate = Calendar.current.date(byAdding: .day, value: -60, to: endDate)!
//        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: endDate))!
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
    
    @MainActor
    func fetchDailyMindfulMinutesData() async throws -> [Date: Double] {
        guard store.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .mindfulSession)!) == .sharingAuthorized else {
            throw HKError.mindfulMinutesNotDetermined
        }
        
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] (query, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                var dailyMinutes: [Date: Double] = [:]
                let calendar = Calendar.current
                
                // Process each mindful session
                result?.forEach { sample in
                    if let categorySample = sample as? HKCategorySample {
                        let date = calendar.startOfDay(for: categorySample.startDate)
                        let minutes = categorySample.endDate.timeIntervalSince(categorySample.startDate) / 60
                        
                        // Accumulate minutes for each date
                        dailyMinutes[date, default: 0.0] += minutes
                    }
                }
                
                DispatchQueue.main.async {
                    self?.mindfulMinutes = dailyMinutes.values.reduce(0, +)
                    self?.totalMindfulMinutesPerDay = dailyMinutes
                }
                
                continuation.resume(returning: dailyMinutes)
            }
            
            store.execute(query)
        }
    }
    
    func saveMindfulMinutes(_ seconds: Int) {
        
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-(TimeInterval(seconds)))
        let sample = HKCategorySample(type: HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
                                      value: 0,
                                      start: startDate,
                                      end: endDate)
        
        store.save(sample) { success, error in
            
            if let error = error {
                self.errorMsg = error.localizedDescription
            }
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
    case mindfulMinutesNotDetermined
    case sharingDenied
    case noData
    case unableToQuerySleepData
    case unableToCompleteRequest
    
    var description: String {
            switch self {
            case .authNotDetermined:
                return "An error occurred. HealthKit authorization could not be determined. You may need to allow access from the iOS Health app settings."
            case .mindfulMinutesNotDetermined:
                return" An error occurred. HealthKit authorization could not be determined. You may need to allow access from the iOS Health app settings."
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
