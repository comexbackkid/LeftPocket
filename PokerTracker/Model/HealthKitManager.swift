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
    
    func fetchSleepData() {
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -28, to: endDate)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (query, result, error) in
                guard error == nil else {
                    print("Error fetching sleep data: \(String(describing: error))")
                    return
                }
                
                var sleepMetrics: [SleepMetric] = []
                
                if let result = result {
                    let calendar = Calendar.current
                    
                    // Dictionary to store total sleep time for each day
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
                    
                    // Convert dictionary to SleepMetric array
                    for (date, totalSleepTime) in dailySleepTimes {
                        let sleepMetric = SleepMetric(date: date, value: totalSleepTime)
                        sleepMetrics.append(sleepMetric)
                    }
                    
                    // Sort sleep metrics by date
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
