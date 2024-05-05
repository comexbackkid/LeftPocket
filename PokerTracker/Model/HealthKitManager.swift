//
//  HealthKitManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/1/24.
//

//import Foundation
//import HealthKit
//
//class HealthKitManager {
//    
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
