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
        }
    }
    
    var ytdButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation {
                vm.pickerSelection = .ytd
            }
        } label: {
            HStack {
                ZStack {
                    
                    if vm.pickerSelection == .ytd {
                        Capsule()
                            .foregroundColor(Color.pickerGray.opacity(0.5))
                            .frame(width: 90)
                            .matchedGeometryEffect(id: "timeline", in: animation)
                    }

                    Text("YTD")
                        .subHeadlineStyle()
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                        .padding(.horizontal, 45)
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
                vm.pickerSelection = .lastYear
            }
        } label: {
            HStack {
                ZStack {
                    
                    if vm.pickerSelection == .lastYear {
                        
                        Capsule()
                            .foregroundColor(Color.pickerGray.opacity(0.5))
                            .frame(width: 90)
                            .matchedGeometryEffect(id: "timeline", in: animation)
                    }

                    Text("PREV")
                        .subHeadlineStyle()
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                        .padding(.horizontal, 45)
                }
            }
            .frame(height: 50)
        }
        .buttonStyle(.plain)
    }
}

struct CustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomPicker(vm: AnnualReportViewModel())
//            .preferredColorScheme(.dark)
    }
}
