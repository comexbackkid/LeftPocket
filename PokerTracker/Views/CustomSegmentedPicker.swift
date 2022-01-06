//
//  CustomSegmentedPicker.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/6/22.
//

import SwiftUI

struct CustomSegmentedPicker: View {
    
    @ObservedObject var pbyViewModel: ProfitByYearViewModel
    
    var body: some View {
        
        HStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                pbyViewModel.timeline = Year.ytd.yearSelection()
            } label: {
                Text("YTD")
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 17)
                    .foregroundColor(.brandBlack)
                    .background(pbyViewModel.timeline == Year.ytd.yearSelection() ? Color.pickerGray.opacity(0.5) : .clear)
                    .clipShape(Capsule())
            }
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                pbyViewModel.timeline = Year.last.yearSelection()
            } label: {
                Text(Date().modifyDays(days: -365).getYearShortHand())
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 17)
                    .foregroundColor(.brandBlack)
                    .background(pbyViewModel.timeline == Year.last.yearSelection() ? Color.pickerGray.opacity(0.5) : .clear)
                    .clipShape(Capsule())
            }
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                pbyViewModel.timeline = Year.all.yearSelection()
            } label: {
                Text("All")
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal, 30)
                    .padding(.vertical, 17)
                    .foregroundColor(.brandBlack)
                    .background(pbyViewModel.timeline == "All" ? Color.pickerGray.opacity(0.5) : .clear)
                    .clipShape(Capsule())
            }
        }
    }
}

struct CustomSegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomSegmentedPicker(pbyViewModel: ProfitByYearViewModel())
    }
}
