//
//  BestTimeOfDay.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/25/24.
//

import SwiftUI
import Charts

struct BestTimeOfDay: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @State private var highestEarningBucket: TimeBucket?
    @State private var rawSelectedBucketValue: Double?
    @State private var bucket: String?
    
    var selectedBucket: (bucket: TimeBucket, averageHourlyRate: Double)? {
        guard let rawSelectedBucketValue else { return nil }
        
        var total = 0.0
        
        return prepareChartData(sessions: viewModel.allSessions).first {
            total += $0.averageHourlyRate
            return rawSelectedBucketValue <= total
        }
    }
    
    var body: some View {
       
        VStack (spacing: 0) {
            
            ZStack {
                
                if let highestData = highestRateData(sessions: viewModel.allSessions) {
                    
                    VStack (spacing: 0) {
                        
                        Text("\(highestData.hourlyRate.axisShortHand(viewModel.userCurrency))")
                            .font(.custom("Asap-Bold", size: 28, relativeTo: .title2))
                        
                        Text("per Hour")
                            .font(.custom("Asap-Regular", size: 10, relativeTo: .caption2))
                            .opacity(0.6)
                            .offset(y: -2)
                    }
                }
                
                donutChart
            }
            
            if let highestData = highestRateData(sessions: viewModel.allSessions) {
                
                HStack {
                    Text("You perform the best between \(highestData.bucket.rawValue)")
                        .subHeadlineStyle()
                        .padding(.top, 6)
                    
                    Spacer()
                }
            }
        }
        .dynamicTypeSize(.medium)
    }
    
    var donutChart: some View {
        
        Chart {
            
            let highestBucket = highestRateBucket(sessions: viewModel.allSessions)
            let chartData = prepareChartData(sessions: viewModel.allSessions)
            
            ForEach(chartData, id: \.bucket) { data in
                SectorMark(
                    angle: .value("Type", data.averageHourlyRate),
                    innerRadius: .ratio(0.83),
                    angularInset: 3
                )
                .foregroundStyle(by: .value("Bucket", data.bucket.rawValue))
                .cornerRadius(25)
                .opacity(data.bucket == highestBucket ? 1.0 : 0.2)
            }
        }
        .chartAngleSelection(value: $rawSelectedBucketValue)
        .chartLegend(.hidden)
        .chartForegroundStyleScale([
            "12-4am": Color.donutChartOrange,
            "4-8am": Color.donutChartLightBlue,
            "8-12pm": Color.donutChartGreen,
            "12-4pm": Color.donutChartPurple,
            "4-8pm": Color.donutChartRed,
            "8-12am": Color.donutChartDarkBlue,
        ])
        
    }
    
    // Use the midpoint of the session duration to fit it into a given TimeBucket
    private func categorizeSession(_ session: PokerSession_v2) -> TimeBucket {
        let midPoint = Date(timeIntervalSince1970: (session.startTime.timeIntervalSince1970 + session.endTime.timeIntervalSince1970) / 2)
        return TimeBucket.bucket(for: midPoint)
    }
    
    // Places sessions into their respective TimeBuckets and then figures their average hourly rate in each TimeBucket
    private func prepareChartData(sessions: [PokerSession_v2]) -> [(bucket: TimeBucket, averageHourlyRate: Double)] {
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
    func highestRateData(sessions: [PokerSession_v2]) -> (bucket: TimeBucket, hourlyRate: Int)? {
        let data = prepareChartData(sessions: sessions)
        guard let highest = data.max(by: { $0.averageHourlyRate < $1.averageHourlyRate }) else { return nil }
        return (highest.bucket, Int(highest.averageHourlyRate))
    }

    // Simply finds the TimeBucket with the highest average hourly rate
    func highestRateBucket(sessions: [PokerSession_v2]) -> TimeBucket? {
        let data = prepareChartData(sessions: sessions)
        let highest = data.max { $0.averageHourlyRate < $1.averageHourlyRate }
        return highest?.bucket
    }
}

enum TimeBucket: String, CaseIterable, Plottable {
    case earlyMorning = "12-4am"
    case lateMorning = "4-8am"
    case earlyAfternoon = "8-12pm"
    case lateAfternoon = "12-4pm"
    case evening = "4-8pm"
    case night = "8-12am"
    
    var color: Color {
        switch self {
        case .earlyMorning:
            Color.donutChartOrange
        case .lateMorning:
            Color.donutChartLightBlue
        case .earlyAfternoon:
            Color.donutChartGreen
        case .lateAfternoon:
            Color.donutChartPurple
        case .evening:
            Color.donutChartRed
        case .night:
            Color.donutChartDarkBlue
        }
    }
    
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
    
    // Plottable conformance
    public var primitivePlottable: String {
        self.rawValue
    }
    
    public init?(primitivePlottable: String) {
        self.init(rawValue: primitivePlottable)
    }
}

#Preview {
    VStack {
        BestTimeOfDay()
            .environmentObject(SessionsListViewModel())
    }
    .padding()
    .frame(width: UIScreen.main.bounds.width * 0.43, height: 190)
    .cornerRadius(20)
}
