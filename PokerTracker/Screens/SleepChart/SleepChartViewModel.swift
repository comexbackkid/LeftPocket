//
//  SleepChartViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/1/24.
//

//import Foundation
//import SwiftUI
//
//struct SessionChartData: Identifiable {
//    let id: UUID
//    let session: PokerSession
//    let sleepHours: Double
//}
//
//@MainActor
//class SleepChartViewModel: ObservableObject {
//    
//    @ObservedObject var vm = SessionsListViewModel()
//    
//    @Published var sessionDataPoints: [SessionChartData] = []
//    
//    private var healthKitManager = HealthKitManager()
//
//    func loadRecentSessionsData() async {
//        let sortedSessions = vm.sessions.sorted { $0.date > $1.date }
//        let recentSessions = Array(sortedSessions.prefix(5))
//        
//        var dataPoints: [SessionChartData] = []
//
//        for session in recentSessions {
//            do {
//                let sleepHours = try await healthKitManager.fetchSleepData(for: session.date)
//                let sessionData = SessionChartData(id: session.id, session: session, sleepHours: sleepHours)
//                dataPoints.append(sessionData)
//            } catch {
//                print("Error fetching sleep data for session on \(session.date): \(error)")
//            }
//        }
//
//        self.sessionDataPoints = dataPoints
//    }
//}
