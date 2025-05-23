//
//  BankrollProgressView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/26/24.
//

import SwiftUI

struct BankrollProgressView: View {
    
    enum ProgressStatus: CustomStringConvertible {
        case notReady
        case nearlyReady
        case ready
        case undefined

        init(progress: Float) {
            switch progress {
            case ..<0.5:
                self = .notReady
            case 0.5..<0.8:
                self = .nearlyReady
            case 0.8...:
                self = .ready
            default:
                self = .undefined
            }
        }

        var description: String {
            switch self {
            case .notReady:
                return "You're not quite ready to move up in stakes yet."
            case .nearlyReady:
                return "Keep it up, you're almost ready to move up stakes!"
            case .ready:
                return "Well done! Now's a good time to consider moving up stakes."
            case .undefined:
                return "Progress undefined"
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var progressIndicator: Float
    
    var statusUpdate: ProgressStatus {
        ProgressStatus(progress: progressIndicator)
    }
    let isSubscribed: Bool
    
    var body: some View {
        
        HStack {
            
            ZStack {
                
                Circle()
                    .stroke(lineWidth: 8)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray.opacity(0.1))
                    
                Circle()
                    .trim(from: 0, to: CGFloat(min(self.progressIndicator, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(LinearGradient(colors: [.mint, .mint.opacity(0.6)],
                                                    startPoint: .leading,
                                                    endPoint: .bottom))
                    .animation(.easeInOut(duration: 2.0), value: progressIndicator)
                
                Text("\(progressIndicator.asPercent())")
                    .captionStyle()
                    .dynamicTypeSize(...DynamicTypeSize.medium)
            }
            
            
            Text(statusUpdate.description)
                .calloutStyle()
                .padding(.leading, 12)
            
            Spacer()
            
        }
        .blur(radius: isSubscribed ? 0 : 5)
        .padding(20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    BankrollProgressView(progressIndicator: .constant(0.77), isSubscribed: true)
}
