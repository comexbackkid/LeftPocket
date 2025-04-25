//
//  MindfulnessCompleted.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/25/24.
//

import SwiftUI
import AudioToolbox

struct MindfulnessCompleted: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var passedMeditation: Meditation?
    
    let meditation: Meditation
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                Image("nightsky")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                VStack {
                    
                    Text("\(meditation.duration.formattedTime)")
                        .font(.custom("Asap-Black", size: 28))
                        .foregroundStyle(.white)
                    
                    Text("of mindfulness added")
                        .subHeadlineStyle()
                        .foregroundStyle(.white)
                }
            }
            
            VStack {
                
                Text("🎉  Well Done!")
                    .font(.custom("Asap-Black", size: 34))
                    .bold()
                    .padding(.vertical)
                    .padding(.top, 5)
                
                VStack (alignment: .leading) {
                    
                    Text("You logged \(meditation.duration.formattedTime) of meditation minutes today. Continue doing this before you play poker and keep working to improve your focus & headspace.\n")
                        .bodyStyle()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Check back to see how these numbers impact your results over time.")
                        .bodyStyle()
                }
                
                Spacer()
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                    passedMeditation = nil
                    
                } label: {
                    PrimaryButton(title: "Finish")
                }
            }
            
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                playConfirmationSound()
            }
        }
    }
    
    private func playConfirmationSound() {
        // Other possible codes: 1307
        AudioServicesPlaySystemSound(1112)
    }
}

extension TimeInterval {

    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return "\(minutes) min \(seconds) sec"
    }
}

#Preview {
    MindfulnessCompleted(passedMeditation: .constant(.beach), meditation: .beach)
        .preferredColorScheme(.dark)
}
