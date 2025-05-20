//
//  HealthKitErrors.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/8/25.
//

import Foundation

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
