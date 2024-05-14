//
//  HealthKitManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/1/24.
//

import SwiftUI
import Foundation
import HealthKit


//@Observable class HealthKitManager {
//    
//    let store = HKHealthStore()
//    let types: Set = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
//    
//    var sleepData: [SleepMetric] = []
//    
//    func fetchSleepData() async throws -> [SleepMetric] {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: .now)
//        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
//        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)
//        
//        // I don't know if I need this
//        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
//        
//        // Create a predicate for sleep samples
//        let stagePredicate = HKCategoryValueSleepAnalysis.predicateForSamples(.equalTo, value: .asleepUnspecified)
//        
//        // Alternate predicate I don't understand
//        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//        
//        // Query predicate. I think this is where we need to set the timeframe? Not sure yet.
//        let queryPredicate = HKSamplePredicate.sample(type: HKCategoryType(.sleepAnalysis), predicate: stagePredicate)
////        let sleepQuery = HKSampleQueryDescriptor(predicates: [queryPredicate], sortDescriptors: [])
//        
//        // Execute the query and await results
//        return try await withCheckedThrowingContinuation { continuation in
//            let query = HKSampleQuery(sampleType: sleepType, 
//                                      predicate: datePredicate,
//                                      limit: HKObjectQueryNoLimit,
//                                      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, results, error in
//                
//                if let error = error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//                
//                guard let samples = results as? [HKCategorySample] else {
//                    continuation.resume(throwing: NSError(domain: "HealthKitError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to cast samples to HKCategorySample"]))
//                    return
//                }
//                
//                let sleepMetrics = samples.map { sample -> SleepMetric in
//                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
//                    let hours = duration / 3600 // Convert seconds to hours
//                    
//                    return SleepMetric(date: sample.endDate, value: hours)
//                }
//                
//                continuation.resume(returning: sleepMetrics)
//                self.sleepData = sleepMetrics
//            }
//            
//            store.execute(query)
//        }
        
//        do {
//            let sleepSamples = try await sleepQuery.result(for: store)
//            sleepData = sleepSamples.map({
//                .init(date: $0.endDate, value: $0.sampleType.maximumAllowedDuration)
//            })
//        } catch {
//            // Error Handling
//        }
//    }

//}
    
////    static let shared = HealthKitManager()
////    private var healthStore: HKHealthStore?
//    
//    var healthStore: HKHealthStore?
//    
//    init() {
//        if HKHealthStore.isHealthDataAvailable() {
//            healthStore = HKHealthStore()
//        }
//    }
//    
//    func requestAuthorization() async {
//        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
//        
//        let typesToRead: Set<HKObjectType> = [sleepType]
//        let typesToShare: Set<HKSampleType> = []
//        
//        do {
//            try await healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead)
//        } catch {
//            // Handle error
//        }
//    }
//    
////    init() {
////        if HKHealthStore.isHealthDataAvailable() {
////            healthStore = HKHealthStore()
////        }
////    }
////    
////    func requestAuthorization() async throws {
////        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
////            throw HealthKitError.dataTypeNotAvailable
////        }
////        
////        let typesToRead: Set<HKObjectType> = [sleepType]
////        let typesToShare: Set<HKSampleType> = []
////        
////        do {
////            try await healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead)
////        } catch {
////            throw error // Propagate the error up to the caller.
////        }
////    }
//    
//    func fetchSleepData(for date: Date) async throws -> Double {
//        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
//            throw HealthKitError.dataTypeNotAvailable
//        }
//        
//        // Get the start of the given date and the start of the previous day
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: date)
//        let startOfPreviousDay = calendar.date(byAdding: .day, value: -1, to: startOfDay)!
//        
//        // Predicate from start of previous day to start of the given day
//        let predicate = HKQuery.predicateForSamples(withStart: startOfPreviousDay, end: startOfDay, options: .strictStartDate)
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//                guard let samples = results as? [HKCategorySample] else {
//                    continuation.resume(returning: 0)
//                    return
//                }
//                let totalSleepSeconds = samples.reduce(0) { accum, sample in
//                    accum + sample.endDate.timeIntervalSince(sample.startDate)
//                }
//                let totalSleepHours = totalSleepSeconds / 3600
//                continuation.resume(returning: totalSleepHours)
//            }
//            
//            healthStore?.execute(query)
//        }
//    }
//
//    enum HealthKitError: Error {
//        case dataTypeNotAvailable
//    }
//}
