//
//  HealthKitPrimingView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/9/24.
//

import SwiftUI
import HealthKitUI

struct HealthKitPrimingView: View {
    
    @EnvironmentObject var hkManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingHealthKitPermissions = false
    @Binding var hasSeen: Bool
    
    var description = """
    With Left Pocket Pro, you can read from your saved health data, specifically sleep & mindfulness numbers in order to evaluate how they are potentially affecting your play. Only mindfulness numbers are saved to the Health app from Left Pocket.

    
    Your data is private and secure, and is not shared with anyone. You can always turn off sharing from your iOS Settings later.
    """
    
    var body: some View {
        
        VStack (spacing: 100) {
            
            VStack (alignment: .leading, spacing: 10) {
                Image(.appleHeath)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom, 12)
                
                Text("Apple Health Integration")
                    .cardTitleStyle()
                
                Text(description)
                    .bodyStyle()
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Button {
                hkManager.requestAuthorization()
            } label: {
                PrimaryButton(title: "Connect Apple Health")
            }
        }
        .interactiveDismissDisabled()
        .onAppear { hasSeen = true }
        .onChange(of: hkManager.authorizationStatus, perform: { state in
            if state != .notDetermined {
                dismiss()
            } else {
                dismiss()
            }
        })
    }
}

#Preview {
    HealthKitPrimingView(hasSeen: .constant(true))
        .environmentObject(HealthKitManager())
        .preferredColorScheme(.dark)
}
