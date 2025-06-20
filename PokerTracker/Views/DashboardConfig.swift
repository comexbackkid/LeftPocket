//
//  DashboardConfig.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/5/24.
//

import SwiftUI

struct DashboardConfig: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var playerProfit: Bool = false
    @State private var bbPerHr: Bool = false
    @State private var hourlyRate: Bool = false
    @State private var profitPerSession: Bool = false
    @State private var hoursPlayed: Bool = false
    @State private var winRatio: Bool = false
    @State private var meditationCard: Bool = false
    @State private var showAlertModal = false

    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack (alignment: .leading) {
                    
                    screenTitle
                    
                    instructions
                    
                    statsList
                    
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        saveDashboardConfig()
                        
                    } label: {
                        PrimaryButton(title: "Save Layout")
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.brandBackground)
        }
    }
    
    var screenTitle: some View {
        
        Text("Dashboard Layout")
            .titleStyle()
            .padding(.horizontal)
            
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Customize the layout of your Dashboard. Note: The percentage change displayed for each metric reflects the increase or decrease from the previous year.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var statsList: some View {
        
        VStack (spacing: 12) {
            
            HStack {
                Text("Player Profit")
                Spacer()
                Button {
                    playerProfit.toggle()
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(playerProfit ? .green : .secondary)
                        .symbolEffect(.bounce, value: playerProfit)
                }
            }
            
            Divider()
            
            HStack {
                Text("Hours Played")
                Spacer()
                Button {
                    hoursPlayed.toggle()
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(hoursPlayed ? .green : .secondary)
                        .symbolEffect(.bounce, value: hoursPlayed)
                }
            }
            
            Divider()
            
            HStack {
                Text("BB / Hr")
                Spacer()
                Button {
                    bbPerHr.toggle()
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(bbPerHr ? .green : .secondary)
                        .symbolEffect(.bounce, value: bbPerHr)
                }
            }
            
            Divider()
            
            HStack {
                Text("Hourly Rate")
                Spacer()
                Button {
                    hourlyRate.toggle()
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(hourlyRate ? .green : .secondary)
                        .symbolEffect(.bounce, value: hourlyRate)
                }
            }
            
            Divider()
            
            HStack {
                Text("Profit Per Session")
                Spacer()
                Button {
                    profitPerSession.toggle()
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(profitPerSession ? .green : .secondary)
                        .symbolEffect(.bounce, value: profitPerSession)
                }
            }
            
            Divider()
            
            HStack {
                Text("Win Ratio")
                Spacer()
                Button {
                    winRatio.toggle()
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(winRatio ? .green : .secondary)
                        .symbolEffect(.bounce, value: winRatio)
                }
            }
            
            Divider()
            
            HStack {
                Text("Meditation Card")
                Spacer()
                Button {
                    meditationCard.toggle()
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(meditationCard ? .green : .secondary)
                        .symbolEffect(.bounce, value: meditationCard)
                }
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .background(Color.brandBackground)
        .padding(.trailing, 40)
        .padding(.leading)
        .padding(.vertical, 20)
        .onAppear {
            loadDashboardConfig()
        }
        .sheet(isPresented: $showAlertModal, content: {
            AlertModal(message: "Dashboard layout saved successfully.", image: "checkmark.circle", imageColor: .green)
                .presentationDetents([.height(280)])
                .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                .presentationDragIndicator(.visible)
        })
    }
    
    private func saveDashboardConfig() {
        
        let defaults = UserDefaults.standard
        defaults.set(playerProfit, forKey: "dashboardPlayerProfit")
        defaults.set(bbPerHr, forKey: "dashboardBbPerHr")
        defaults.set(hourlyRate, forKey: "dashboardHourlyRate")
        defaults.set(profitPerSession, forKey: "dashboardProfitPerSession")
        defaults.set(winRatio, forKey: "dashboardWinRatio")
        defaults.set(hoursPlayed, forKey: "dashboardHoursPlayed")
        defaults.set(meditationCard, forKey: "dashboardMeditationCard")
        
        showAlertModal = true
    }
    
    private func loadDashboardConfig() {
        
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "dashboardPlayerProfit") == nil {
            self.playerProfit = true
        } else {
            self.playerProfit = defaults.bool(forKey: "dashboardPlayerProfit")
        }
        
        self.bbPerHr = defaults.bool(forKey: "dashboardBbPerHr")
        self.hourlyRate = defaults.bool(forKey: "dashboardHourlyRate")
        self.profitPerSession = defaults.bool(forKey: "dashboardProfitPerSession")
        self.winRatio = defaults.bool(forKey: "dashboardWinRatio")
        
        if defaults.object(forKey: "dashboardMeditationCard") == nil {
            self.meditationCard = true
        } else {
            self.meditationCard = defaults.bool(forKey: "dashboardMeditationCard")
        }
        
        if defaults.object(forKey: "dashboardHoursPlayed") == nil {
            self.hoursPlayed = true
        } else {
            self.hoursPlayed = defaults.bool(forKey: "dashboardHoursPlayed")
        }
    }
}

#Preview {
    DashboardConfig()
        .preferredColorScheme(.dark)
//        .environment(\.locale, Locale(identifier: "PT"))
}
