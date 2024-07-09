//
//  HeatMap.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/24/24.
//

import SwiftUI

struct HeatMap: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        VStack {
            
            GeometryReader { geometry in
                
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
                let spacing: CGFloat = 6
                let width = (geometry.size.width - (spacing * CGFloat(columns.count - 1))) / CGFloat(columns.count)
                let height = width
                let days = daysInMonth()
                
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(days, id: \.self) { day in
                        Circle()
                            .fill(self.isSessionDay(day) ? Color.gray : Color.gray.opacity(0.1))
                            .frame(width: width, height: height)
                            .cornerRadius(8)
                    }
                }
                .padding([.horizontal, .top], spacing)
                .frame(width: geometry.size.width, height: 270, alignment: .top)
            }
            
            let monthlyCount = viewModel.sessions.filter({ $0.date.getMonth() == Date().getMonth() && $0.date.getYear() == Date().getYear() }).count
            
            HStack {
                Text("You've played \(monthlyCount) session\(monthlyCount > 1 || monthlyCount < 1 ? "s" : "") this month")
                    .subHeadlineStyle()
                    .padding(.top, 5)
                
                Spacer()
            }
        }
        .dynamicTypeSize(.medium)
    }
    
    // Get all days in the current month
    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: Date())!
        
        var days: [Date] = []
        var day = interval.start
        
        while day <= interval.end {
            days.append(day)
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        
        return days
    }
    
    // Helper to determine if a session was played on a given day
    func isSessionDay(_ day: Date) -> Bool {
        let sessionDays = Set(viewModel.sessions.map { Calendar.current.startOfDay(for: $0.date) })
        return sessionDays.contains(Calendar.current.startOfDay(for: day))
    }
    
    // Date formatter for displaying days
    let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
}

#Preview {
    HeatMap()
        .environmentObject(SessionsListViewModel())
        .padding()
}
