//
//  BestTimeOfDay.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/25/24.
//

import SwiftUI
import Charts

@available(iOS 17.0, *)
struct BestTimeOfDay: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State private var highestEarningBucket: TimeBucket?
    
    var body: some View {
       
        VStack {
            
            let highestBucket = highestRateBucket(sessions: viewModel.sessions)
            
            HStack {
                Text("Best Time of Day")
                    .cardTitleStyle()
                    
                Spacer()
                
            }
            .padding(.bottom)
            
            HStack {
 
                ZStack {
                    
                    if let highestData = highestRateData(sessions: viewModel.sessions) {
                        Text("$\(highestData.hourlyRate) / hr")
                            .captionStyle()
                            .offset(x: 30)
                    }
                    
                    Chart {
                        ForEach(prepareChartData(sessions: viewModel.sessions), id: \.bucket) { data in
                            SectorMark(
                                angle: .value("Type", data.totalHourlyRate),
                                innerRadius: .ratio(0.75),
                                angularInset: 3
                            )
                            .foregroundStyle(by: .value("Bucket", data.bucket.rawValue))
                            .cornerRadius(20)
                            .opacity(data.bucket == highestBucket ? 1.0 : 0.13)
                        }
                    }
                    .frame(maxWidth: 300, maxHeight: 140)
                    .chartLegend(position: .leading, alignment: .leading)
                    .chartForegroundStyleScale([
                        "12-4am": Color.lightBlue,
                        "4-8am": .pink,
                        "8-12pm": .mint,
                        "12-4pm": .indigo,
                        "4-8pm": .orange,
                        "8-12am": .teal,
                ])
                }
            }
        }
    }
    
    func categorizeSession(_ session: PokerSession) -> TimeBucket {
        let midPoint = Date(timeIntervalSince1970: (session.startTime.timeIntervalSince1970 + session.endTime.timeIntervalSince1970) / 2)
        return TimeBucket.bucket(for: midPoint)
    }
    
    private func prepareChartData(sessions: [PokerSession]) -> [(bucket: TimeBucket, totalHourlyRate: Int)] {
        var bucketTotals = [TimeBucket: Int]()
        for session in sessions {
            let bucket = categorizeSession(session)
            bucketTotals[bucket, default: 0] += session.hourlyRate
        }
        return bucketTotals.map { ($0.key, $0.value) }
    }
    
    // New
    func highestRateData(sessions: [PokerSession]) -> (bucket: TimeBucket, hourlyRate: Int)? {
        let data = prepareChartData(sessions: sessions)
        guard let highest = data.max(by: { $0.totalHourlyRate < $1.totalHourlyRate }) else { return nil }
        return (highest.bucket, highest.totalHourlyRate)
    }
    
    func highestRateBucket(sessions: [PokerSession]) -> TimeBucket? {
        let data = prepareChartData(sessions: sessions)
        let highest = data.max { $0.totalHourlyRate < $1.totalHourlyRate }
        return highest?.bucket
    }
}

enum TimeBucket: String, CaseIterable {
    case earlyMorning = "12-4am"
    case lateMorning = "4-8am"
    case earlyAfternoon = "8-12pm"
    case lateAfternoon = "12-4pm"
    case evening = "4-8pm"
    case night = "8-12am"
    
    static func bucket(for date: Date) -> TimeBucket {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 0..<4: return .earlyMorning
        case 4..<8: return .lateMorning
        case 8..<12: return .earlyAfternoon
        case 12..<16: return .lateAfternoon
        case 16..<20: return .evening
        case 20..<24: return .night
        default: return .earlyMorning
        }
    }
}

#Preview {
    VStack {
        BestTimeOfDay()
            .environmentObject(SessionsListViewModel())
//            .preferredColorScheme(.dark)
    }
    .padding()
}


