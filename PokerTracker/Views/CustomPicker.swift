//
//  CustomPicker.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/7/22.
//

import SwiftUI

struct CustomPicker: View {
    
    @ObservedObject var vm: yearlySummaryViewModel
    @Namespace private var animation
    
    var body: some View {
        
        HStack (alignment: .center, spacing: -20) {

            ytdButton
            
            lastYrButton
            
            allButton
        }
    }
    
    var ytdButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation {
                vm.myNewTimeline = .ytd
            }
        } label: {
            HStack {
                ZStack {
                    
                    if vm.myNewTimeline == .ytd {
                        Capsule()
                            .foregroundColor(Color.pickerGray.opacity(0.5))
                            .frame(width: 90)
                            .matchedGeometryEffect(id: "timeline", in: animation)
                    }

                    Text("YTD")
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
    
    var lastYrButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation {
                vm.myNewTimeline = .lastYear
            }
        } label: {
            HStack {
                ZStack {
                    
                    if vm.myNewTimeline == .lastYear {
                        Capsule()
                            .foregroundColor(Color.pickerGray.opacity(0.5))
                            .frame(width: 90)
                            .matchedGeometryEffect(id: "timeline", in: animation)
                    }

                    Text("\(Date().modifyDays(days: -360).getYearShortHand())")
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
    
    var allButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation {
                vm.myNewTimeline = .all
            }
        } label: {
            HStack {
                ZStack {
                    
                    if vm.myNewTimeline == .all {
                        Capsule()
                            .foregroundColor(Color.pickerGray.opacity(0.5))
                            .frame(width: 90)
                            .matchedGeometryEffect(id: "timeline", in: animation)
                    }
                    
                    Text("ALL")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.brandBlack)
                        .padding(.horizontal, 40)
                }
            }
            .frame(height: 50)
        }
    }
}

struct CustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomPicker(vm: yearlySummaryViewModel())
    }
}














// OLD CODE IN CAES WE NEED IT. ITERATED THROUGH A HARDCODED ARRAY OF DATES PREVIOUSLY

//        let timelines = ["YTD", Date().modifyDays(days: -360).getYear(), "All"]

//        HStack (alignment: .center, spacing: -20) {
//            ForEach(timelines, id: \.self) { timeline in
//                Button {
//                    let impact = UIImpactFeedbackGenerator(style: .light)
//                    impact.impactOccurred()
//                    withAnimation {
//                        vm.selectedTimeline = timeline
//                    }
//                } label: {
//                    HStack {
//                        ZStack {
//
//                            if vm.selectedTimeline == timeline {
//                                Capsule()
//                                    .foregroundColor(Color.pickerGray.opacity(0.5))
//                                    .frame(width: 90)
//                                    .matchedGeometryEffect(id: "timeline", in: animation)
//                            }
//
//                            // Hack to display two digits instead of the full year. Ex 21 vs. 2021
//                            Text(timeline.count == 4 ? Date().modifyDays(days: -365).getYearShortHand() : timeline)
//                                .font(.subheadline)
//                                .bold()
//                                .foregroundColor(.brandBlack)
//                                .padding(.horizontal, 40)
//                        }
//                    }
//                    .frame(height: 50)
//                }
//                .buttonStyle(.plain)
//            }
//        }
