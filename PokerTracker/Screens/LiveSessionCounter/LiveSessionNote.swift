//
//  LiveSessionNote.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/18/25.
//

import SwiftUI

struct LiveSessionNote: View {
    
    @State private var noteText: String = ""
    @ObservedObject var timerViewModel: TimerViewModel
    @Environment(\.dismiss) var dismiss
    
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
                        .overlay(
                            HStack {
                                VStack {
                                    VStack {
                                        Text(noteText.isEmpty ? "Session Note" : "")
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
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
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
                saveNote()
                dismiss()
                
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
    }
    
    private func saveNote() {
        
        if !timerViewModel.notes.isEmpty {
            timerViewModel.notes.append("\n" + noteText)
        } else {
            timerViewModel.notes.append(noteText)
        }
        print(noteText)
    }
}

#Preview {
    LiveSessionNote(timerViewModel: TimerViewModel())
}
