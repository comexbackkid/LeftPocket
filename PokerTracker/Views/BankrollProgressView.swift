//
//  BankrollProgressView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/26/24.
//

import SwiftUI

struct BankrollProgressView: View {
    
    enum ProgressStatus: CustomStringConvertible {
        case notQuiteReady
        case nearlyReady
        case ready
        case undefined

        init(progress: Float) {
            switch progress {
            case ..<0.5:
                self = .notQuiteReady
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
            case .notQuiteReady:
                return "You're not quite ready to move up in stakes."
            case .nearlyReady:
                return "Keep going! You're almost ready to move up in stakes."
            case .ready:
                return "Congratulations! You can now move up in stakes."
            case .undefined:
                return "Progress undefined"
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    let progress: Float
    
    var statusUpdate: ProgressStatus {
        ProgressStatus(progress: progress)
    }
    
    var body: some View {
        
        HStack {
            
            ZStack {
                
                Circle()
                    .stroke(lineWidth: 8)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray.opacity(0.1))
                    
                Circle()
                    .trim(from: 0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(LinearGradient(colors: [.mint, .mint.opacity(0.4), ],
                                                    startPoint: .leading,
                                                    endPoint: .bottom))
                
                Text("\(progress.asPercent())")
                    .captionStyle()
            }
            
            Text(statusUpdate.description)
                .calloutStyle()
                .padding(.leading, 12)
            
            Spacer()
            
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
    }
}

#Preview {
    BankrollProgressView(progress: 0.62)
        .background(Color.brandBackground)
        .preferredColorScheme(.dark)
}
