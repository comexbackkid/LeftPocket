//
//  LiveSessionNote.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/18/25.
//

import SwiftUI

struct LiveSessionNote: View {
    
    @State private var noteText: String = ""
    @Binding var noteConfirmationSound: Bool
    @ObservedObject var timerViewModel: TimerViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    var body: some View {
        
        VStack {
            
            ScrollView {
                
                VStack {
                    
                    title
                    
                    instructions
                    
                    TextEditor(text: $noteText)
                        .font(.custom("Asap-Regular", size: 17))
                        .padding(12)
                        .frame(height: 250, alignment: .top)
                        .scrollContentBackground(.hidden)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                        .focused($isFocused, equals: true)
                        .overlay(
                            HStack {
                                VStack {
                                    VStack {
                                        Text(noteText.isEmpty ? "Type here..." : "")
                                            .font(.custom("Asap-Regular", size: 17))
                                            .font(.callout)
                                            .foregroundColor(.secondary.opacity(0.5))
                                            .padding(.horizontal)
                                            .padding(.top, 20)
                                            .disableAutocorrection(true)
                                    }
                                    Spacer()
                                }
                                Spacer()
                            })
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                        .padding(.horizontal, 8)
                    
                    saveButton
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done") {
                    isFocused = false
                }
            }
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("New Note")
                .titleStyle()
                .padding(.top, 30)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                Text("Jot down any hand histories or player notes here. All notes will be automatically saved to your Live Session once it's ended.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                timerViewModel.addNote(noteText)
                dismiss()
                noteConfirmationSound = true
                
            } label: {
                PrimaryButton(title: "Save Note")
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                dismiss()
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
        }
        .padding(.bottom, 10)
        .padding(.horizontal)
        .padding(.horizontal, 8)
    }
}

#Preview {
    LiveSessionNote(noteConfirmationSound: .constant(false), timerViewModel: TimerViewModel())
}
