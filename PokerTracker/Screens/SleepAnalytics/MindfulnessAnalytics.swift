//
//  MindfulnessAnalytics.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/18/24.
//

import SwiftUI
import Charts

struct MindfulnessAnalytics: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var hkManager: HealthKitManager
    @Environment(\.colorScheme) var colorScheme
    
    let dailyMindfulMinutes: [Date: Double]
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                title
                
                instructions
                
                VStack (spacing: 22) {
                    
                    ToolTipView(image: "figure.mind.and.body",
                                message: "You've logged about \(totalMindfulMinutes()) mindfulness minutes the last 30 days",
                                color: .mint)

                    meditationChart
                    
                    ToolTipView(image: "chart.line.uptrend.xyaxis",
                                message: "On days you meditate you see a spike of about 47% in your profit",
                                color: .indigo)
                    
                    recentMeditations
                    
                    checkInButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Image(systemName: "plus")
                    .foregroundColor(.brandPrimary)
            }
        }
        .background(Color.brandBackground)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Poker Mindfulness")
                .titleStyle()
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, -37)
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                Text("Improve your focus, attention, & mood before you hit the tables. Develop a pre-game mindfulness routine to help boost your results.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var recentMeditations: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Recent Meditations")
                    .font(.custom("Asap-Black", size: 24))
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.sessions.prefix(10).filter { session in
                        dailyMindfulMinutes.keys.contains { isSameDay($0, session.date) }
                    }, id: \.id) { session in
                        ZStack {
                            VStack {
                                Text(session.location.name)
                                    .cardTitleStyle()
                                Text("\(session.date.dateStyle())")
                                    .captionStyle()
                            }
                            
                            VStack {
                                Spacer()
                                HStack {
                                    if let minutes = dailyMindfulMinutes.first(where: { isSameDay($0.key, session.date) })?.value {
                                        Image(systemName: "figure.mind.and.body")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 19, height: 19)
                                        Text("\(minutes, specifier: "%.0f") min")
                                            .headlineStyle()
                                    }
                                    Spacer()
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 15, height: 15)
                                    Text(session.profit.axisShortHand(viewModel.userCurrency))
                                        .headlineStyle()
                                }
                                .opacity(0.8)
                            }
                            .padding(10)
                        }
                        .frame(width: 300, height: 200)
                        .background(
                            Image(backgroundImage(session))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .overlay {
                                    Image(backgroundImage(session))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .blur(radius: 5, opaque: true)
                                        .mask(
                                            LinearGradient(gradient: Gradient(stops: [
                                                Gradient.Stop(color: Color(white: 0, opacity: 0), location: 0.25),
                                                Gradient.Stop(color: Color(white: 0, opacity: 1), location: 0.65),
                                            ]), startPoint: .top, endPoint: .bottom)
                                        )
                                }
                                .overlay(
                                    LinearGradient(gradient: Gradient(stops: [
                                        Gradient.Stop(color: Color(white: 0, opacity: 0), location: 0.4),
                                        Gradient.Stop(color: Color(white: 0, opacity: 0.8), location: 1),
                                    ]), startPoint: .top, endPoint: .bottom)
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 5)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    var meditationChart: some View {
        
        VStack {
            
            VStack (alignment: .leading, spacing: 3) {
                HStack {
                    Text("Daily Meditation")
                        .cardTitleStyle()
                    
                    Spacer()
                }
                
                Text("Avg " + averageMeditationTime() + " mins")
                    .subHeadlineStyle()
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 40)
            
            Chart {
                ForEach(sortedMindfulData(), id: \.key) { date, minutes in
                    BarMark(
                        x: .value("Date", date),
                        y: .value("Minutes", minutes),
                        width: 7
                    )
                    .foregroundStyle(Color.cyan.gradient)
                }
            }
            .chartXScale(domain: startDate()...Date(), range: .plotDimension(padding: 10))
            .chartXAxis {
                AxisMarks(values: .automatic) {
                    AxisValueLabel(format: .dateTime.month(.twoDigits).day(), verticalSpacing: 10)
                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    
                    AxisValueLabel {
                        if let value = value.as(Double.self), value != 0 {
                            Text("\(value, specifier: "%.0f")m")
                                .captionStyle()
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
        }
        .overlay {
            if sortedMindfulData().isEmpty {
                VStack {
                    
                    Text("No mindfulness data to display.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                    
                    Text("Check permissions in iOS Settings, or log minutes here.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 290)
        .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    var checkInButton: some View {
        
        PrimaryButton(title: "Mood Check-In")
    }
    
    private func backgroundImage(_ session: PokerSession) -> String {
        
        guard !session.location.localImage.isEmpty else { return "defaultlocation-header" }
        
        return session.location.localImage
    }
    
    private func totalMindfulMinutes() -> Int {
        Int(round(dailyMindfulMinutes.values.reduce(0, +)))
    }

    private func sortedMindfulData() -> [(key: Date, value: Double)] {
        return dailyMindfulMinutes.sorted { $0.key < $1.key }
    }
    
    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"  // e.g., "Oct 15"
        return formatter.string(from: date)
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func startDate() -> Date {
        Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    }
    
    private func averageMeditationTime() -> String {
        guard !dailyMindfulMinutes.isEmpty else { return "0.00" }

        let totalMinutes = dailyMindfulMinutes.values.reduce(0, +)
        let daysWithData = dailyMindfulMinutes.count

        let average = totalMinutes / Double(daysWithData)
        return String(format: "%.2f", average)
    }
}

#Preview {
    NavigationStack {
        MindfulnessAnalytics(dailyMindfulMinutes: [Date():4,
                                                   Date().modifyDays(days: -1): 5,
                                                   Date().modifyDays(days: -4): 3,
                                                   Date().modifyDays(days: -5): 5,
                                                   Date().modifyDays(days: -9): 4,
                                                   Date().modifyDays(days: -18): 2])
            .environmentObject(SessionsListViewModel())
            .environmentObject(HealthKitManager())
            .preferredColorScheme(.dark)
    }

}
