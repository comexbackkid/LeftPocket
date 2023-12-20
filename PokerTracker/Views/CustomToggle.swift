//
//  CustomToggle.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/15/23.
//

import SwiftUI

struct CustomToggle: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: NewSessionViewModel
    @Namespace private var animation
    
    var body: some View {
        
        HStack(alignment: .center, spacing: -10) {
            
            plusBtn
            
            minusBtn
            
        }
        .frame(height: 58)
        .font(.title3)
        .background(.gray.opacity(0.2))
        .cornerRadius(30)
        
    }
    
    var plusBtn: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation {
                vm.positiveNegative = "+"
            }
            
        } label: {
            HStack {
                ZStack {
                    
                    if vm.positiveNegative == "+" {
                        Capsule()
                            .foregroundColor(.gray.opacity(colorScheme == .dark ? 0.5 : 0.3))
                            .frame(width: 50)
                            .matchedGeometryEffect(id: "toggle", in: animation)
                    }
                    
                    Text("+")
                        .padding(.horizontal, 24)
                }
            }
            .frame(height: 50)
        }
        .buttonStyle(.plain)
    }
    
    var minusBtn: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation {
                vm.positiveNegative = "-"
            }
            
        } label: {
            HStack {
                ZStack {
                    
                    if vm.positiveNegative == "-" {
                        Capsule()
                            .foregroundColor(.gray.opacity(colorScheme == .dark ? 0.5 : 0.3))
                            .frame(width: 50)
                            .matchedGeometryEffect(id: "toggle", in: animation)
                    }
                    
                    Text("-")
                        .padding(.horizontal, 25)
                    
                }
            }
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        
    }
}

struct CustomToggle_Previews: PreviewProvider {
    static var previews: some View {
        CustomToggle(vm: NewSessionViewModel())
//            .preferredColorScheme(.dark)
    }
}
