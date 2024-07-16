//
//  AddNewTransaction.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/15/24.
//

import SwiftUI

struct AddNewTransaction: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showNewTransaction: Bool
    
    @State private var type: TransactionType?
    @State private var amount: String = ""
    @State private var date: Date = .now
    @State private var notes: String = ""
    @State private var transactionPopup = false
    
    var body: some View {
        
        VStack {
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    title
                    
                    instructions
                    
                    VStack {
                        
                        selections
                        
                        inputFields
                        
                    }
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
            
            Text("New Transaction")
                .titleStyle()
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                Text("Enter transaction details below. Transactions do not factor in to your overall player metrics or statistics. Include an optional note such as, \"Starting Stack.\"")
                    .bodyStyle()
                
                Spacer()
            }
            
            HStack {
                
                Button {
                    transactionPopup = true

                } label: {
                    HStack (spacing: 4) {
                        
                        Text("More about Transactions")
                            .calloutStyle()
                        
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(Color.brandPrimary)
            }
            .popover(isPresented: $transactionPopup, arrowEdge: .bottom, content: {
                PopoverView(bodyText: "Transactions are optional, & geared towards those poker players who need a precise ledger of their current, actual bankroll figure. Use transactions to track when you contribute or withdraw funds from your poker bankroll.")
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    .frame(height: 190)
                    .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                    .presentationCompactAdaptation(.popover)
                    .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                    .shadow(radius: 10)
            })
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    var selections: some View {
        
        VStack {
            
            HStack {
                
                Image(systemName: "creditcard.circle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                Text("Type")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Menu {
                    
                    Button("Deposit") {
                        type = .deposit
                    }
                    
                    Button("Withdrawal") {
                        type = .withdrawal
                    }
                    
                } label: {
                    switch type {
                    case .deposit:
                        Text("Deposit")
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                        
                    case .withdrawal:
                        Text("Withdrawal")
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                        
                    case nil:
                        Text("Please select ›")
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(type == nil ? Color.brandPrimary : Color.brandWhite)
                
            }
            .padding(.bottom, 10)
            
            HStack {
                
                Image(systemName: "calendar")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: [.date])
                    .accentColor(.brandPrimary)
                    .padding(.leading, 4)
                    .font(.custom("Asap-Regular", size: 18))
                    .datePickerStyle(.compact)
            }
            .padding(.bottom, 10)
        }
    }
    
    var inputFields: some View {
        
        VStack {
            
            HStack {
                
                Text(vm.userCurrency.symbol)
                    .font(.callout)
                    .foregroundStyle(amount.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                
                TextField("Amount", text: $amount)
                    .font(.custom("Asap-Regular", size: 17))
                    .keyboardType(.numberPad)
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.bottom, 10)
            
            TextEditor(text: $notes)
                .font(.custom("Asap-Regular", size: 17))
                .padding(12)
                .frame(height: 130, alignment: .top)
                .scrollContentBackground(.hidden)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .overlay(
                    HStack {
                        VStack {
                            VStack {
                                Text(notes.isEmpty ? "Notes (Optional)" : "")
                                    .font(.custom("Asap-Regular", size: 17))
                                    .font(.callout)
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                
                            }
                            Spacer()
                        }
                        Spacer()
                    })
        }
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                saveButtonPressed()
                
            } label: {
                PrimaryButton(title: "Save Transaction")
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                showNewTransaction = false
            } label: {
                Text("Cancel")
                    .bodyStyle()
            }
            .tint(.red)
        }
        .padding(.bottom, 10)
    }
    
    private func saveButtonPressed() {
        vm.addTransaction(date: date, type: type ?? .deposit, amount: Int(amount) ?? 0, notes: notes)
        showNewTransaction = false
    }
}

#Preview {
    AddNewTransaction(showNewTransaction: .constant(true))
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
