//
//  ProfitByWeekdayView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/8/21.
//

import SwiftUI

struct ProfitByWeekdayView: View {
    
    @State private var yearFilter: String = Date().getYear()
    @ObservedObject var vm: SessionsListViewModel
    
    var body: some View {
        
        let filteredDays = vm.sessions.filter({ $0.date.getYear() == yearFilter })
        let allYears = vm.sessions.map({ $0.date.getYear() }).uniqued()
        
        List {
            ForEach (vm.daysOfWeek, id: \.self) { day in
                HStack {
                    Text(day)
                        .font(.callout)
                    
                    Spacer()
                    
                    let total = filteredDays.filter({ $0.date.dayOfWeek(day: $0.date) == day}).map { $0.profit }.reduce(0,+)
                    let hourlyRate = filteredDays.filter({ $0.date.dayOfWeek(day: $0.date) == day}).map { $0.hourlyRate }.reduce(0,+)
                    
                    Text(hourlyRate.asCurrency() + " / hr ")
                        .profitColor(total: hourlyRate)
                        .font(.callout)
                    
                    Text("\(total.asCurrency())")
                        .profitColor(total: total)
                        .font(.callout)
                        .frame(width: 80, alignment: .trailing)
                }
            }
            
        }
        .navigationBarTitle(Text("Profit by Weekday"))
        .navigationBarItems(trailing: Picker(selection: $yearFilter, label: Text(""), content: {
            
            ForEach(allYears, id: \.self) { year in
                Text(year)
            }
        })
        .pickerStyle(MenuPickerStyle()))
        .listStyle(PlainListStyle())
        
    }
}

struct ProfitByWeekdayView_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByWeekdayView(vm: SessionsListViewModel())
    }
}
