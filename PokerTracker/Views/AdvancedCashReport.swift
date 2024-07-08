//
//  AdvancedCashReport.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/21/24.
//

import SwiftUI

struct AdvancedCashReport: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @State private var locationFilter: LocationModel?
    @State private var stakesFilter = "All"
    @State private var dateRangeFilter = "All"
    
    // I think we need a variety of computed properties
    // But not sure how to handle all of the filters
    
//    var filteredSessions: [PokerSession] {
        
//        var result = viewModel.sessions
        
//        return result
//    }
    
    var body: some View {

        ScrollView {
            
            title
            
            VStack (spacing: 10) {
                
                headerFilters
                
                Divider().padding(.vertical)
                
                incomeReport
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
            .lineSpacing(2.5)
            .padding(30)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            barChart
        }
        .background(Color.brandBackground)
        .accentColor(.brandPrimary)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Cash Game Report")
                .titleStyle()
                .padding(.top, -37)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var headerFilters: some View {
        
        VStack (spacing: 7) {
            
            HStack {
                Text("Date Range")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Menu {
                    Picker("", selection: $dateRangeFilter) {
                        Text("All").tag("All")
                        Text("Last 7 Days").tag("Last 7 Days")
                        Text("Last 30 Days").tag("Last 30 Days")
                        Text("Last 3 Months").tag("Last 3 Months")
                        Text("Last 12 Months").tag("Last 12 Months")
                    }
                } label: {
                    Text(dateRangeFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            
            HStack {
                Text("Location")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Menu {
                    Button("All") {
                        locationFilter = nil
                    }
                    Picker("", selection: $locationFilter) {
                        ForEach(viewModel.sessions.map({ $0.location }).uniqued(), id: \.self) { location in
                            Text(location.name).tag(location as LocationModel?)
                        }
                    }
                } label: {
                    Text(locationFilter?.name ?? "All" + " ›")
                        .bodyStyle()
                        .lineLimit(1)
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            
            HStack {
                Text("Stakes")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Menu {
                    Picker("", selection: $stakesFilter) {
                        Text("All").tag("All")
                        Text("1/2").tag("1/2")
                        Text("1/3").tag("1/3")
                        Text("2/5").tag("2/5")
                    }
                } label: {
                    Text(stakesFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            
            
        }
        .padding(.bottom, 10)
    }
    
    var incomeReport: some View {
        
        VStack (spacing: 12) {
            
            HStack {
                Text("Gross Income")
                
                Spacer()
                Text("$3,200")
                    .foregroundStyle(.green)
            }
            
            HStack {
                Text("Expenses")
                
                Spacer()
                Text("$120")
                    .foregroundStyle(.red)
            }
            
            HStack {
                Text("Net Profit")
                
                Spacer()
                Text("$3,080")
                    .foregroundStyle(.green)
            }
            
            Divider().padding(.vertical)
            
            HStack {
                Text("Hourly Rate")
                
                Spacer()
                Text("$37")
                    .foregroundStyle(.green)
            }
            
            HStack {
                Text("Win Ratio")
                
                Spacer()
                Text("65%")
            }
            
            HStack {
                Text("No. of Sessions")
                
                Spacer()
                Text("12")
            }
            
            HStack {
                Text("Hours Played")
                
                Spacer()
                Text("120h")
            }
        }
        
    }
    
    var barChart: some View {
        
        BarChartByYear(showTitle: false, moreAxisMarks: false, cashOnly: true)
            .padding(30)
            .padding(.top, 25)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 200)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            .padding(.top, 20)
        
    }
}

#Preview {
    AdvancedCashReport()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
