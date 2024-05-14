//
//  LiveSessionCounter.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/19/24.
//

import SwiftUI

struct LiveSessionCounter: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    @State private var showRebuyModal = false
    
    var body: some View {
        
        HStack (spacing: 10) {
            
            Image(systemName: "timer")
                .foregroundStyle(.secondary)
                .font(.title3)
                .fontWeight(.medium)
            
            Text(timerViewModel.liveSessionTimer)
                .buttonTextStyle()
            
            Image(systemName: "dollarsign.arrow.circlepath")
                .foregroundColor(.brandPrimary)
                .fontWeight(.medium)
                .font(.title2)
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    showRebuyModal = true
                }
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.9))
        .cornerRadius(20)
        .onDisappear {
            timerViewModel.stopTimer()
        }
        .sheet(isPresented: $showRebuyModal, content: {
            LiveSessionRebuyModal()
                .presentationDetents([.height(340), .large])
                .presentationBackground(.ultraThinMaterial)
        })
    }
}

#Preview {
    LiveSessionCounter()
        .environmentObject(TimerViewModel())
        .preferredColorScheme(.dark)
}
