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
    
    var body: some View {
        
        NavigationStack {
            
            VStack (alignment: .leading) {
                
                screenTitle
                
                instructions
                
                List {
                    
                    HStack {
                        Text("Player Profit")
                        Spacer()
                        Button {
                            playerProfit.toggle()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(playerProfit ? .green : .secondary)
                        }
                    }
                    .padding(8)
                    
                    HStack {
                        Text("BB / Hr")
                        Spacer()
                        Button {
                            bbPerHr.toggle()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(bbPerHr ? .green : .secondary)
                        }
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        Button {
                            hourlyRate.toggle()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(hourlyRate ? .green : .secondary)
                        }
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Profit Per Session")
                        Spacer()
                        Button {
                            profitPerSession.toggle()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(profitPerSession ? .green : .secondary)
                        }
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Win Ratio")
                        Spacer()
                        Button {
                            winRatio.toggle()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(winRatio ? .green : .secondary)
                        }
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Hours Played")
                        Spacer()
                        Button {
                            hoursPlayed.toggle()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(hoursPlayed ? .green : .secondary)
                        }
                    }
                    .padding(8)
                }
                .scrollDisabled(true)
                .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                .background(Color.brandBackground)
                .scrollContentBackground(.hidden)
            }
            .background(Color.brandBackground)
        }
    }
    
    var screenTitle: some View {
        
        Text("Dashboard Config")
            .titleStyle()
            .padding(.top, -38)
            .padding(.horizontal)
            .listRowBackground(Color.brandBackground)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Choose which of your player metrics you'd like pinned to the Dashboard view of Left Pocket.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    private func saveDashboardConfig() {
        
        let defaults = UserDefaults.standard
        defaults.set(playerProfit, forKey: "dashboardPlayerProfit")
        defaults.set(bbPerHr, forKey: "dashboardBbPerHr")
        defaults.set(hourlyRate, forKey: "dashboardHourlyRate")
        defaults.set(profitPerSession, forKey: "dashboardProfitPerSession")
        defaults.set(winRatio, forKey: "dashboardWinRatio")
        defaults.set(hoursPlayed, forKey: "dashboardHoursPlayed")
    }
}

#Preview {
    DashboardConfig()
        .preferredColorScheme(.dark)
}
