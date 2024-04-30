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
    
    var body: some View {
        
        HStack (spacing: 10) {
            
            Image(systemName: "timer")
                .foregroundColor(.brandPrimary)
                .bold()
            
            Text(timerViewModel.liveSessionTimer)
                .buttonTextStyle()
                
        }
        .padding()
        .background(.ultraThinMaterial.opacity(0.9))
        .cornerRadius(20)
        .onDisappear {
            timerViewModel.stopTimer()
        }
    }
}

#Preview {
    LiveSessionCounter()
        .environmentObject(TimerViewModel())
}
