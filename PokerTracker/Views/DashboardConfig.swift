//
//  DashboardConfig.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/5/24.
//

import SwiftUI

struct DashboardConfig: View {
    
    @State private var playerProfit: Bool = false
    @State private var bbPerHr: Bool = false
    @State private var hourlyRate: Bool = false
    @State private var profitPerSession: Bool = false
    @State private var hoursPlayed: Bool = false
    @State private var winRatio: Bool = false
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
                }
            }
            .background(Color.brandBackground)
        }
    }
    
    var screenTitle: some View {
        
        Text("Dashboard Layout")
            .titleStyle()
            .padding(.top, -38)
            .padding(.horizontal)
            
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Choose which of your important player metrics you'd like pinned to the Dashboard view of Left Pocket.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var statsList: some View {
        
        VStack (spacing: 15) {
            
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
            AlertModal(message: "Dashboard layout saved successfully.")
                .presentationDetents([.height(210)])
                .presentationBackground(.ultraThinMaterial)
            
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
        
        showAlertModal = true
    }
    
    private func loadDashboardConfig() {
        
        let defaults = UserDefaults.standard
        
        self.playerProfit = defaults.bool(forKey: "dashboardPlayerProfit")
        self.bbPerHr = defaults.bool(forKey: "dashboardBbPerHr")
        self.hourlyRate = defaults.bool(forKey: "dashboardHourlyRate")
        self.profitPerSession = defaults.bool(forKey: "dashboardProfitPerSession")
        self.winRatio = defaults.bool(forKey: "dashboardWinRatio")
        self.hoursPlayed = defaults.bool(forKey: "dashboardHoursPlayed")
    }
}

#Preview {
    DashboardConfig()
        .preferredColorScheme(.dark)
}
