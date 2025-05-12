//
//  LiveSessionInitialBuyIn.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 9/16/24.
//

import SwiftUI
import HealthKit

struct LiveSessionInitialBuyIn: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var hkManager: HealthKitManager
    @ObservedObject var timerViewModel: TimerViewModel
    @State private var alertItem: AlertItem?
    @State private var initialBuyInField: String = ""
    @State private var selectedMood: HKStateOfMind.Label?
    @State private var selectedValence: Double?
    @State private var animateEmoji = false
    @Binding var buyInConfirmationSound: Bool
    @FocusState var isFocused: Bool
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    private let moodChoices: [(label: HKStateOfMind.Label, imageName: String, valence: Double)] = [
        (.angry, "mood_angry", -0.9),
        (.discouraged,   "mood_unsure",  -0.6),
        (.drained,    "mood_tired",  -0.3),
        (.joyful,   "mood_happy",   0.6),
        (.excited,   "mood_elated",  0.9)
    ]
    
    var body: some View {
        
        VStack {
            
            title
            
            instructions
            
            inputFields
            
            moodSelection
            
            saveButton
            
            Spacer()
            
        }
        .dynamicTypeSize(.medium)
        .ignoresSafeArea()
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message, dismissButton: alert.dismissButton)
        }
        .onAppear(perform: {
            buyInConfirmationSound = false
        })
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            isFocused = false
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("Enter Buy In")
                .font(.custom("Asap-Black", size: 34))
                .bold()
                .padding(.bottom, 5)
                .padding(.top, 20)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Enter your starting stack below. You can add rebuys and top-offs later.")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    var inputFields: some View {
        
        HStack {
            Text(vm.userCurrency.symbol)
                .font(.callout)
                .foregroundColor(initialBuyInField.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
            
            TextField("Initial Buy In", text: $initialBuyInField)
                .font(.custom("Asap-Regular", size: 17))
                .keyboardType(.numberPad)
                .focused($isFocused, equals: true)
        }
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    var moodSelection: some View {
        
        VStack {
            Text("How Do You Feel?")
                .foregroundStyle(.primary)
                .font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
                .padding(.top)
            
            if !hkManager.isStateOfMindAuthorized {
                Text("Enable health permissions from iOS Settings.")
                    .captionStyle()
                    .padding(.horizontal, 30)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)
            }
            
            HStack(spacing: 16) {
                ForEach(moodChoices, id: \.label) { choice in
                    Button {
                        if hkManager.isStateOfMindAuthorized {
                            selectedMood = choice.label
                            selectedValence = choice.valence
                            animateEmoji.toggle()
                            
                        } else {
                            hkManager.requestAuthorization()
                        }
                        
                    } label: {
                        Image(choice.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .opacity(selectedMood == choice.label ? 1.0 : 0.5)
                            .phaseAnimator(MoodAnimationPhase.allCases, trigger: selectedMood) { content, phase in
                                content
                                    .scaleEffect(selectedMood == choice.label ? phase.scaleAmount : 1.0)
                            } animation: { phase in
                                phase.animation
                            }
                    }
                    .sensoryFeedback(.selection, trigger: selectedMood)
                }
            }
            .padding(.bottom, 6)
        }
        .padding(.top, 4)
    }
    
    var saveButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            buyInConfirmationSound = true
            saveButtonPressed()
            
        } label: {
            PrimaryButton(title: "Save")
        }
        .padding(.horizontal)
    }
    
    private var isValidForm: Bool {
        guard !initialBuyInField.isEmpty else {
            alertItem = AlertContext.invalidBuyIn
            return false
        }
        
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: initialBuyInField)) else {
            alertItem = AlertContext.invalidCharacter
            return false
        }
        
        return true
    }
    
    private func saveButtonPressed() {
        guard isValidForm else { return }
        let moodRaw = selectedMood?.rawValue
        Task {
            if let mood = selectedMood, let valence = selectedValence {
                let sample = HKStateOfMind(date: Date(), kind: .momentaryEmotion, valence: valence, labels: [mood], associations: [])
                
                do {
                    try await hkManager.saveStateOfMindSample(sample)
                    
                    print("State of mind saved! (Mood: \(mood), Valence: \(valence))")
                    
                } catch {
                    print("Failed saving mood: ",error)
                }
            }
        }
        
        timerViewModel.addInitialBuyIn(initialBuyInField, mood: moodRaw)
        dismiss()
    }
}

extension HealthKitManager {
    func saveStateOfMindSample(_ sample: HKStateOfMind) async throws {
        try await store.save(sample)
    }
}

enum MoodAnimationPhase: CaseIterable {
    case start, expand, contract, overshoot, settle

    var scaleAmount: CGFloat {
        switch self {
        case .start:      return 1.0
        case .expand:     return 1.3
        case .contract:   return 0.8
        case .overshoot:  return 1.1
        case .settle:     return 1.0
        }
    }

    var animation: Animation {
        switch self {
        case .start:      return .smooth
        case .expand:     return .easeOut(duration: 0.2)
        case .contract:   return .easeInOut(duration: 0.1)
        case .overshoot:  return .easeIn(duration: 0.1)
        case .settle:     return .easeOut(duration: 0.1)
        }
    }
}

#Preview {
        LiveSessionInitialBuyIn(timerViewModel: TimerViewModel(), buyInConfirmationSound: .constant(false))
            .environmentObject(SessionsListViewModel())
            .environmentObject(HealthKitManager())
            .frame(height: 420)
            .preferredColorScheme(.dark)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
}
