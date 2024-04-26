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
                    .padding(.bottom, 10)
                    
                Spacer()
                
            }
            .padding(.bottom)
            
            HStack (alignment: .top, spacing: 2) {
                
                Chart {
                    ForEach(prepareChartData(sessions: viewModel.sessions), id: \.bucket) { data in
                        SectorMark(
                            angle: .value("Type", data.averageHourlyRate),
                            innerRadius: .ratio(0.75),
                            angularInset: 3
                        )
                        .foregroundStyle(by: .value("Bucket", data.bucket.rawValue))
                        .cornerRadius(25)
                        .opacity(data.bucket == highestBucket ? 1.0 : 0.3)
                    }
                }
                .frame(maxHeight: 150)
                .frame(width: 220)
                .chartLegend(position: .leading, alignment: .leading)
                .chartForegroundStyleScale([
                    "12-4am": Color.donutChartOrange,
                    "4-8am": Color.donutChartBlack,
                    "8-12pm": Color.donutChartRed,
                    "12-4pm": Color.donutChartGreen,
                    "4-8pm": Color.donutChartPink,
                    "8-12am": Color.donutChartDarkGreen,
                ])
                
                if let highestData = highestRateData(sessions: viewModel.sessions) {
                    Text("On average, you earn $\(highestData.hourlyRate) / hr between \(highestData.bucket.rawValue).")
                        .calloutStyle()
                        .lineSpacing(2)
                        .padding(.leading, 5)
                }
            }
        }
        .dynamicTypeSize(.medium)
    }
    
    // Use the midpoint of the session duration to fit it into a given TimeBucket
    func categorizeSession(_ session: PokerSession) -> TimeBucket {
        let midPoint = Date(timeIntervalSince1970: (session.startTime.timeIntervalSince1970 + session.endTime.timeIntervalSince1970) / 2)
        return TimeBucket.bucket(for: midPoint)
    }
    
    // Places sessions into their respective TimeBuckets and then figures their average hourly rate in each TimeBucket
    private func prepareChartData(sessions: [PokerSession]) -> [(bucket: TimeBucket, averageHourlyRate: Double)] {
        var bucketTotals = [TimeBucket: (totalHourlyRate: Int, count: Int)]()

        for session in sessions {
            let bucket = categorizeSession(session)
            let existing = bucketTotals[bucket, default: (totalHourlyRate: 0, count: 0)]
            bucketTotals[bucket] = (totalHourlyRate: existing.totalHourlyRate + session.hourlyRate, count: existing.count + 1)
        }

        // Check to ensure non-zero division and filter out negative averages
        return bucketTotals.compactMap { bucket, data in
            let average = data.count > 0 ? Double(data.totalHourlyRate) / Double(data.count) : 0.0
            // Only include buckets where the average hourly rate is non-negative
            guard average >= 0 else { return nil }
            return (bucket: bucket, averageHourlyRate: average)
        }
    }
    
    // Returns tuple with the TimeBucket that has the highest average hourly rate along with what that rate is
    func highestRateData(sessions: [PokerSession]) -> (bucket: TimeBucket, hourlyRate: Int)? {
        let data = prepareChartData(sessions: sessions)
        guard let highest = data.max(by: { $0.averageHourlyRate < $1.averageHourlyRate }) else { return nil }
        return (highest.bucket, Int(highest.averageHourlyRate))
    }

    // Simply finds the TimeBucket with the highest average hourly rate
    func highestRateBucket(sessions: [PokerSession]) -> TimeBucket? {
        let data = prepareChartData(sessions: sessions)
        let highest = data.max { $0.averageHourlyRate < $1.averageHourlyRate }
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

@available(iOS 17.0, *)
#Preview {
    VStack {
        BestTimeOfDay()
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
    .padding()
    .frame(height: 220)
}


