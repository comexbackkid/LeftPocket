//
//  MonthlyReportView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct ProfitByMonth: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var yearFilter: String = Date().getYear()
    @ObservedObject var vm: SessionsListViewModel
    
    var body: some View {
        
        ScrollView {
            
            VStack (spacing: 10) {
                
                headerInfo

                Divider()
                    .padding(.bottom, 10)
                
                monthlyTotals

            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("Profit by Month"))
            .padding(30)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
            .padding(.top, 50)
            
            yearTotal
            
            HStack {
                Spacer()
            }
        }
        .background(Color.brandBackground)
    }
    
    var headerInfo: some View {
        
        VStack (spacing: 7) {
            
            let allYears = vm.sessions.map({ $0.date.getYear() }).uniqued()
            
            HStack {
                Text("Select Year")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Menu {
                    Picker("", selection: $yearFilter) {
                        ForEach(allYears, id: \.self) {
                            Text($0)
                        }
                    }
                } label: {
                    Text(yearFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
            }
            
            HStack {
                Text("Total Sessions")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Text("\(vm.sessions.filter({ $0.date.getYear() == yearFilter }).count)")
                    .bodyStyle()
            }
        }
        .padding(.bottom, 10)
    }
    
    var monthlyTotals: some View {
        
        ForEach(vm.months, id: \.self) { month in
            HStack {
                Text(month)
                
                Spacer()
                
                let filteredMonths = vm.sessions.filter({ $0.date.getYear() == yearFilter })
                let total = filteredMonths.filter({ $0.date.getMonth() == month }).map {$0.profit}.reduce(0,+)
//                        let hourlyRate = filteredMonths.filter({ $0.date.getMonth() == month }).map { $0.hourlyRate }.reduce(0,+)
                
                Text(total, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: total)
                    .frame(width: 80, alignment: .trailing)
            }
            .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        }
        
    }
    
    var yearTotal: some View {
        
        VStack {
            
            let bankrollTotalByYear = vm.bankrollByYear(year: yearFilter)
            
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color(.systemGray))
                
                Text("Total")
                    
                Spacer()
                
                Text(bankrollTotalByYear, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bankrollTotalByYear)
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        .padding(.top, 15)
        
    }
}

struct MonthlyReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByMonth(vm: SessionsListViewModel())
                .environmentObject(SessionsListViewModel())
                .preferredColorScheme(.dark)
        }
        
    }
}
