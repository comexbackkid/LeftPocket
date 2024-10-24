//
//  MindfulnessAnalytics.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/18/24.
//

import SwiftUI
import Charts
import TipKit

struct MindfulnessAnalytics: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var hkManager: HealthKitManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showMeditationView = false
    @State private var showError = false
    @State private var selectedMeditation: Meditation?
    @State private var selectedSession: PokerSession?
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                title
                
                instructions
                
                VStack (spacing: 22) {
                    
                    ToolTipView(image: "figure.mind.and.body",
                                message: "You've logged about \(totalMindfulMinutes()) mindfulness minutes the last 30 days.",
                                color: .mint)

                    meditationChart
                    
                    ToolTipView(image: "chart.line.uptrend.xyaxis",
                                message: meditationPerformanceComparison(),
                                color: .indigo)
                    
                    meditationClasses
                    
                    checkInButton
                    
                    recentMeditations
                }
            }
        }
        .onChange(of: hkManager.errorMsg, perform: { _ in
            showError = true
        })
        .alert(isPresented: $showError) {
            Alert(title: Text("Uh oh!"),
                  message: Text(hkManager.errorMsg ?? "An unknown error occurred."),
                  dismissButton: .default(Text("Ok")))
        }
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedSession) { session in
            SessionDetailView(activeSheet: .constant(.recentSession), pokerSession: session)
        }
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
    
    var meditationClasses: some View {
        
        VStack {
            VStack {
                HStack {
                    
                    Text("Start a Meditation")
                        .font(.custom("Asap-Black", size: 24))
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 5)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Choose from our own curated meditation sounds to prepare for a new mindfulness session. Find a quiet place to begin.")
                        .bodyStyle()
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(Meditation.meditations) { meditation in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        selectedMeditation = meditation
                    } label: {
                        Text(meditation.title)
                            .font(.custom("Asap-Bold", size: 18, relativeTo: .title2))
                            .foregroundStyle(Color.white)
                            .frame(width: 170, height: 100)
                            .multilineTextAlignment(.center)
                            .background(Image(meditation.background).resizable().aspectRatio(contentMode: .fill))
                            .clipped()
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.9)
        }
        .padding(.bottom)
        .fullScreenCover(item: $selectedMeditation) { meditation in
            MeditationView(meditation: meditation)
        }
    }
    
    var recentMeditations: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Tagged Sessions")
                    .font(.custom("Asap-Black", size: 24))
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
            }
            
            let matchedSessions = viewModel.sessions.prefix(10).filter { session in
                hkManager.totalMindfulMinutesPerDay.keys.contains { isSameDay($0, session.date) }
            }
            
            if matchedSessions.isEmpty {
                Text("No matched sessions found!")
                    .bodyStyle()
                    .padding(.leading)
                    .padding(.top, 1)
                    .foregroundStyle(.secondary)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(matchedSessions, id: \.id) { session in
                        ZStack {
                            VStack {
                                Text(session.location.name)
                                    .cardTitleStyle()
                                    .foregroundStyle(Color.white)
                                Text("\(session.date.dateStyle())")
                                    .captionStyle()
                                    .foregroundStyle(Color.white)
                            }
                            
                            VStack {
                                Spacer()
                                HStack {
                                    if let minutes = hkManager.totalMindfulMinutesPerDay.first(where: { isSameDay($0.key, session.date) })?.value {
                                        Image(systemName: "figure.mind.and.body")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 19, height: 19)
                                            .foregroundStyle(Color.white)
                                        
                                        Text("\(minutes, specifier: "%.0f") min")
                                            .headlineStyle()
                                            .foregroundStyle(Color.white)
                                    }
                                    Spacer()
                                    
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(Color.white)
                                    
                                    Text(session.profit.axisShortHand(viewModel.userCurrency))
                                        .headlineStyle()
                                        .foregroundStyle(Color.white)
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
                        .onTapGesture {
                            selectedSession = session
                        }
                    }
                }
            }
            .padding(.bottom, 60)
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
//            .chartXScale(domain: startDate()...Date(), range: .plotDimension(padding: 10))
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
                        .padding(.bottom, 10)
                    
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
        
        Button(action: {  }) {
            PrimaryButton(title: "Log Your Mood")
        }
    }
    
    private func backgroundImage(_ session: PokerSession) -> String {
        
        guard !session.location.localImage.isEmpty else { return "defaultlocation-header" }
        
        return session.location.localImage
    }
    
    private func totalMindfulMinutes() -> Int {
        Int(round(hkManager.totalMindfulMinutesPerDay.values.reduce(0, +)))
    }

    private func sortedMindfulData() -> [(key: Date, value: Double)] {
        return hkManager.totalMindfulMinutesPerDay.sorted { $0.key < $1.key }
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
        guard !hkManager.totalMindfulMinutesPerDay.isEmpty else { return "0.00" }

        let totalMinutes = hkManager.totalMindfulMinutesPerDay.values.reduce(0, +)
        let daysWithData = hkManager.totalMindfulMinutesPerDay.count

        let average = totalMinutes / Double(daysWithData)
        return String(format: "%.2f", average)
    }
    
    private func meditationPerformanceComparison() -> String {
        
        // Convert meditation data into a dictionary with the date as the key
        let meditationDates = Set(hkManager.totalMindfulMinutesPerDay.keys.map { Calendar.current.startOfDay(for: $0) })

        var hourlyRateWithMeditation = 0.0
        var countWithMeditation = 0
        var hourlyRateWithoutMeditation = 0.0
        var countWithoutMeditation = 0
        var reasoning = ""

        // Iterate through poker sessions and categorize based on meditation
        for session in viewModel.sessions {
            let sessionDate = Calendar.current.startOfDay(for: session.date)

            if meditationDates.contains(sessionDate) {
                hourlyRateWithMeditation += Double(session.hourlyRate)
                countWithMeditation += 1
            } else {
                hourlyRateWithoutMeditation += Double(session.hourlyRate)
                countWithoutMeditation += 1
            }
        }

        // Handle cases where no data is available
        if countWithMeditation == 0 {
            if countWithoutMeditation == 0 {
                return "No data available to compare performances yet."
            }
            return "Bummer! No sessions were played on days you've meditated."
        }

        // Calculate average hourly rates
        let avgHourlyRateWithMeditation = hourlyRateWithMeditation / Double(countWithMeditation)
        let avgHourlyRateWithoutMeditation = countWithoutMeditation > 0 ? hourlyRateWithoutMeditation / Double(countWithoutMeditation) : 0

        // Calculate percentage improvement
        if avgHourlyRateWithoutMeditation != 0 {
            
            let improvement = ((avgHourlyRateWithMeditation - avgHourlyRateWithoutMeditation) / abs(avgHourlyRateWithoutMeditation)) * 100
            if improvement < 0 {
                reasoning = "This could be due to a small sample size. Keep at it!"
            }
            
            return "Your hourly rate is \(improvement.formatted(.number.precision(.fractionLength(0))))% \(improvement > 0 ? "greater" : "worse") on days you meditate. \(reasoning)"
            
        } else {
            
            return "No sessions logged on non-meditation days. More data is needed."
        }
    }
}

#Preview {
    NavigationStack {
        MindfulnessAnalytics()
//        MindfulnessAnalytics(dailyMindfulMinutes: [Date():4,
//                                                   Date().modifyDays(days: -1): 5,
//                                                   Date().modifyDays(days: -4): 3,
//                                                   Date().modifyDays(days: -5): 5,
//                                                   Date().modifyDays(days: -9): 4,
//                                                   Date().modifyDays(days: -10): 4,
//                                                   Date().modifyDays(days: -12): 3,
//                                                   Date().modifyDays(days: -18): 2])
            .environmentObject(SessionsListViewModel())
            .environmentObject(HealthKitManager())
            .preferredColorScheme(.dark)
    }
}
