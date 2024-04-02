//
//  ProfitByWeekdayView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/8/21.
//

import SwiftUI

struct ProfitByWeekdayView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var yearFilter: String = Date().getYear()
    @ObservedObject var vm: SessionsListViewModel
    
    var body: some View {
        
        let filteredDays = vm.sessions.filter({ $0.date.getYear() == yearFilter })
        let allYears = vm.sessions.map({ $0.date.getYear() }).uniqued()
        
        VStack {
            ForEach (vm.daysOfWeek, id: \.self) { day in
                HStack {
                    Text(day)
                        .calloutStyle()
                    
                    Spacer()
                    
                    let total = filteredDays.filter({ $0.date.dayOfWeek(day: $0.date) == day}).map { $0.profit }.reduce(0,+)
                    let hourlyRate = filteredDays.filter({ $0.date.dayOfWeek(day: $0.date) == day}).map { $0.hourlyRate }.reduce(0,+)
                    
                    Text(hourlyRate.asCurrency() + " / hr ")
                        .profitColor(total: hourlyRate)
                        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
                    
                    Text("\(total.asCurrency())")
                        .profitColor(total: total)
                        .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.vertical, 3)
            }
        }
        .navigationBarTitle(Text("Profit by Weekday"))
        .toolbar {
            Picker("", selection: $yearFilter) {
                ForEach(allYears, id: \.self) {
                    Text($0)
                }
            }
        }
//        .navigationBarItems(trailing: Picker(selection: $yearFilter, label: Text(""), content: {
//            
//            ForEach(allYears, id: \.self) { year in
//                Text(year)
//            }
//        })
//        .pickerStyle(MenuPickerStyle()))
//        .listStyle(PlainListStyle())
//        .lineSpacing(2.5)
        .padding(30)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        
        
    }
}

struct ProfitByWeekdayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByWeekdayView(vm: SessionsListViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
