//
//  CustomPicker.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/7/22.
//

import SwiftUI

struct CustomPicker: View {
    
    let timelines = ["YTD", Date().modifyDays(days: -360).getYear(), "All"]
    @ObservedObject var pbyViewModel: ProfitByYearViewModel
    @Namespace private var animation
    
    var body: some View {
        HStack (alignment: .center, spacing: -20) {
            ForEach(timelines, id: \.self) { timeline in
                Button {
                    withAnimation {
                        pbyViewModel.selectedTimeline = timeline
                    }
                } label: {
                    HStack {
                        ZStack {
                            
                            if pbyViewModel.selectedTimeline == timeline {
                                Capsule()
                                    .foregroundColor(Color.pickerGray.opacity(0.5))
                                    .frame(width: 90)
                                    .matchedGeometryEffect(id: "timeline", in: animation)
                            }
                            
                            // Hack to display two digits instead of the full year. Ex 21 vs. 2021
                            Text(timeline.count == 4 ? Date().modifyDays(days: -365).getYearShortHand() : timeline)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.brandBlack)
                                .padding(.horizontal, 40)
                        }
                    }
                    .frame(height: 50)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct CustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomPicker(pbyViewModel: ProfitByYearViewModel())
    }
}
