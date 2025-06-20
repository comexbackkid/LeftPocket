//
//  MindfulnessAnalytics.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/18/24.
//

import SwiftUI
import Charts
import TipKit
import RevenueCat
import RevenueCatUI

struct MindfulnessAnalytics: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var hkManager: HealthKitManager
    @EnvironmentObject var subManager: SubscriptionManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showMeditationView = false
    @State private var showError = false
    @State private var showPaywall = false
    @State private var selectedMeditation: Meditation?
    @State private var selectedSession: PokerSession_v2?
    
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
                    
                    meditationPerformanceToolTip
                    
                    ToolTipView(image: "brain",
                                message: "\(moodPerformanceComparison())",
                                color: .donutChartPurple)
                    
                    meditationClasses
                    
                }
                .padding(.horizontal)
                
                recentMeditations
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
                .presentationDragIndicator(.visible)
        }
        .task {
            if !hkManager.isMindfulnessAuthorized {
                hkManager.requestAuthorization()
            }
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("Poker Mindfulness")
                .titleStyle()
            
            Spacer()
        }
        .padding(.horizontal)
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
    
    var meditationPerformanceToolTip: some View {
        
        Group {
            if !subManager.isSubscribed {
                ToolTipView(image: "chart.line.uptrend.xyaxis",
                            message: meditationPerformanceComparison(),
                            color: .indigo,
                            premium: true)
                .overlay {
                    if !subManager.isSubscribed {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Upgrade to Pro")
                                .calloutStyle()
                                .fontWeight(.black)
                        }
                        .padding(35)
                        .background(colorScheme == .dark ? Color.black.blur(radius: 25) : Color.white.blur(radius: 25))
                    }
                }
                .clipped()
                
            } else {
                ToolTipView(image: "chart.line.uptrend.xyaxis",
                            message: meditationPerformanceComparison(),
                            color: .indigo,
                            premium: false)
            }
        }
    }
    
    var meditationClasses: some View {
        
        VStack {
            VStack {
                HStack {
                    
                    Text("Start a Meditation")
                        .font(.custom("Asap-Black", size: 24))
                        .bold()
                        .padding(.top)
                        .padding(.bottom, 5)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Choose from our own curated ambient meditation tracks to start a new mindfulness session before you play.")
                        .bodyStyle()
                    
                    Spacer()
                }
                .padding(.bottom)
            }

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(Meditation.meditations) { meditation in
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        
                        if subManager.isSubscribed == true {
                            selectedMeditation = meditation
                            
                        } else if !subManager.isSubscribed && meditation.premium != true {
                            selectedMeditation = meditation
                            
                        } else {
                            showPaywall = true
                        }
                        
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
                    .overlay {
                        if meditation.premium == true && !subManager.isSubscribed == true {
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                            }
                            .padding(8)
                        }
                    }
                }
            }
        }
        .padding(.bottom)
        .fullScreenCover(item: $selectedMeditation) { meditation in
            MeditationView(passedMeditation: $selectedMeditation, meditation: meditation)
        }
        .fullScreenCover(isPresented: $showPaywall, content: {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                .dynamicTypeSize(.large)
                .overlay {
                    HStack {
                        Spacer()
                        VStack {
                            DismissButton()
                                .padding(.horizontal)
                                .onTapGesture {
                                    showPaywall = false
                            }
                            Spacer()
                        }
                    }
                }
        })
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }
    
    var recentMeditations: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Mindful Poker Sessions")
                    .font(.custom("Asap-Black", size: 24))
                    .bold()
                    .padding(.top)
                
                Spacer()
            }
            .padding(.horizontal)
            
            let matchedSessions = viewModel.allSessions.prefix(10).filter { session in
                hkManager.totalMindfulMinutesPerDay.keys.contains { isSameDay($0, session.date) }
            }
            
            if matchedSessions.isEmpty {
                Text("None found!")
                    .bodyStyle()
                    .padding(.top, 1)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
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
                            backgroundImage(session)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .overlay {
                                    backgroundImage(session)
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
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            selectedSession = session
                        }
                    }
                }
                .padding(.horizontal)
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
            .chartXScale(domain: startDate()...Date())
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic) {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), verticalSpacing: 10)
                        .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.33))
                    
                    AxisValueLabel {
                        if let value = value.as(Double.self), value != 0 {
                            Text("\(value, specifier: "%.0f")m")
                                .font(.custom("Asap-Light", size: 12, relativeTo: .caption2))
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
                    
                    // Put a check here, and if they DO have permission, but not logged a meditation
                    Text("Check permissions in iOS Settings.")
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(height: 290)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    var checkInButton: some View {
        
        Button(action: {  }) {
            PrimaryButton(title: "Log Your Mood")
        }
    }
    
    private func backgroundImage(_ session: PokerSession_v2) -> Image {
        
        if let localImage = session.location.localImage {
            return Image(localImage)
                
        } else if let importedImagePath = session.location.importedImage {
            if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                return Image(uiImage: uiImage)
                    
            } else {
                return Image("defaultlocation-header")
            }
            
        } else {
            return Image("defaultlocation-header")
        }
    }
    
    private func totalMindfulMinutes() -> Int { Int(round(hkManager.totalMindfulMinutesPerDay.values.reduce(0, +))) }

    private func sortedMindfulData() -> [(key: Date, value: Double)] { return hkManager.totalMindfulMinutesPerDay.sorted { $0.key < $1.key } }
    
    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func startDate() -> Date { Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date() }
    
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
        for session in viewModel.allSessions.filter({ $0.date.getYear() == Date().getYear() }) {
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
            
            return "On the year, your hourly rate is \(improvement.formatted(.number.precision(.fractionLength(0))))% \(improvement > 0 ? "greater" : "worse") on days you meditate. \(reasoning)"
            
        } else {
            
            return "No sessions logged on non-meditation days. More data is needed."
        }
    }
    
    private func moodPerformanceComparison() -> String {
        var profitOnGoodMoodDays = 0
        var sessionsOnGoodMoodDays = 0
        
        var profitOnBadMoodDays = 0
        var sessionsOnBadMoodDays = 0
        var reasoning = ""
        
        for session in viewModel.allSessions.filter({ $0.date.getYear() == Date().getYear() }) {
            let mood = session.moodLabel
            let isBadMood = (mood == .angry || mood == .drained)
            
            if isBadMood {
                profitOnBadMoodDays += session.profit
                sessionsOnBadMoodDays += 1
                
            } else {
                // If mood is nil or not angry/drained, count as "good mood"
                profitOnGoodMoodDays += session.profit
                sessionsOnGoodMoodDays += 1
            }
        }
        
        if sessionsOnGoodMoodDays == 0 {
            if sessionsOnBadMoodDays == 0 {
                return "No mood data is available to compare performances yet."
            }
            
            return "More mood data is needed to compare results across your poker sessions.."
        }
        
        let avgProfitGood = Double(profitOnGoodMoodDays) / Double(sessionsOnGoodMoodDays)
        let avgProfitBad  = sessionsOnBadMoodDays > 0 ? Double(profitOnBadMoodDays) / Double(sessionsOnBadMoodDays) : 0
        
        if avgProfitBad != 0 {
            let diff = avgProfitGood - avgProfitBad
            let pct = (diff / abs(avgProfitBad)) * 100
            
            if pct < 0 {
                reasoning = "This could be due to a small sample size or variance."
            }
            
            return "You're making \(pct.formatted(.number.precision(.fractionLength(0))))% \(pct > 0 ? "more" : "less") per session on days you’re not angry or tired. \(reasoning)"
            
        } else {
            return "More mood data is needed to compare results across your poker sessions."
        }
    }
    
}

#Preview {
    NavigationStack {
        MindfulnessAnalytics()
            .environmentObject(SessionsListViewModel())
            .environmentObject(HealthKitManager())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
    }
}
