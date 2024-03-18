//
//  CustomPicker.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/7/22.
//

import SwiftUI

struct CustomPicker: View {
    
    @ObservedObject var vm: AnnualReportViewModel
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
                        .subHeadlineStyle()
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
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

                    Text("\(Date().modifyDays(days: -365).getYearShortHand())")
                        .subHeadlineStyle()
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
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
                        .subHeadlineStyle()
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                        .padding(.horizontal, 40)
                }
            }
            .frame(height: 50)
        }
    }
}

struct CustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomPicker(vm: AnnualReportViewModel())
//            .preferredColorScheme(.dark)
    }
}
