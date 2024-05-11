//
//  HealthKitPrimingView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/9/24.
//

import SwiftUI


struct HealthKitPrimingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingHealthKitPermissions = false
    @Binding var hasSeen: Bool
    
    var description = """
    This app displays your sleep data in interactive charts.

    Your data is private and secure, and is not shared with anyone You can always turn off sharing from your iOS Settings later.
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
            
            Button {
                isShowingHealthKitPermissions = true
            } label: {
                PrimaryButton(title: "Connect Apple Health")
            }
            
        }
        .padding(30)
        .interactiveDismissDisabled()
        .onAppear { hasSeen = true }
//        .healthDataAccessRequest(store: hkManager.store,
//                                 shareTypes: hkManager.types,
//                                 readTypes: hkManager.types,
//                                 trigger: isShowingHealthKitPermissions) { result in
//            switch result {
//            case .success(_):
//                dismiss()
//            case .failure(_):
//                // Handle error later
//                dismiss()
//            }
//        }
    }
}

#Preview {
    HealthKitPrimingView(hasSeen: .constant(true))
//        .preferredColorScheme(.dark)
}
