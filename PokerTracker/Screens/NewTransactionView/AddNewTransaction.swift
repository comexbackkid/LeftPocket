//
//  AddNewTransaction.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/15/24.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct AddNewTransaction: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("multipleBankrollsEnabled") var multipleBankrollsEnabled: Bool = false
    @Binding var showNewTransaction: Bool
    @Binding var audioConfirmation: Bool
    
    @State private var type: TransactionType?
    @State private var selectedBankrollID: UUID?
    @State private var amount: String = ""
    @State private var date: Date = .now
    @State private var notes: String = ""
    @State private var tags: String = ""
    @State private var transactionPopup = false
    @State private var alertItem: AlertItem?
    @State private var showPaywall = false
    private var selectedBankrollName: String {
        if let id = selectedBankrollID,
           let match = vm.bankrolls.first(where: { $0.id == id }) {
            return match.name
        } else {
            return "Default Bankroll"
        }
    }
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
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
                    .padding(.horizontal, 24)
                    
                    saveButton
                }
            }
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
        .onAppear { audioConfirmation = false }
        .alert(item: $alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("New Transaction")
                .titleStyle()
                .padding(.top, 30)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            
            HStack {
                Text("Enter any \"off-the-felt\" expenses like meals, travel, & memberships, or bankroll transactions. These do not affect your performance stats.")
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
                PopoverView(bodyText: "Transactions are for players who want a precise ledger of their current, actual bankroll figure. They do not factor into your player stats, & are tallied together in Tag Reports & your Annual Report to assist with profit & loss statements.")
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    .frame(height: 180)
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
                    
                    Button("Expense") {
                        type = .expense
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
                        
                    case .expense:
                        Text("Expense")
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
            
            if multipleBankrollsEnabled {
                HStack {
                    
                    Image(systemName: "bag.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                        .frame(width: 30, height: 30)
                    
                    Text("Bankroll")
                        .bodyStyle()
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Menu {
                            
                        Picker("Bankroll Picker", selection: $selectedBankrollID) {
                            Text("Default Bankroll").tag(UUID?.none)
                            ForEach(vm.bankrolls) { bankroll in
                                Text(bankroll.name).tag(Optional(bankroll.id))
                            }
                        }
           
                    } label: {
                        Text(selectedBankrollName)
                            .bodyStyle()
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .foregroundColor(.brandWhite)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 10)
            }
            
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
                .frame(height: 100, alignment: .top)
                .scrollContentBackground(.hidden)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .overlay(
                    HStack {
                        VStack {
                            VStack {
                                Text(notes.isEmpty ? "Entry Title" : "")
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
                .padding(.bottom, 10)
            
            HStack {
                Image(systemName: "tag.fill")
                    .font(.caption2)
                    .frame(width: 13)
                    .foregroundColor(tags.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Tags (Optional)", text: $tags)
                    .font(.custom("Asap-Regular", size: 17))
            }
            .allowsHitTesting(subManager.isSubscribed ? true : false)
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.bottom, 10)
            .overlay {
                if !subManager.isSubscribed {
                    HStack {
                        Spacer()
                        Button {
                            showPaywall = true
                        } label: {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                                .padding(.bottom, 10)
                                .padding(.trailing, 40)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                    .dynamicTypeSize(.medium...DynamicTypeSize.large)
                    .overlay {
                        HStack {
                            Spacer()
                            VStack {
                                DismissButton()
                                    .padding()
                                    .onTapGesture {
                                        showPaywall = false
                                }
                                Spacer()
                            }
                        }
                    }
            }
            .task {
                for await customerInfo in Purchases.shared.customerInfoStream {
                    
                    showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                    await subManager.checkSubscriptionStatus()
                }
            }
        }
    }
    
    var isValidForm: Bool {
        
        guard type != nil else {
            alertItem = AlertContext.invalidTransactionType
            return false
        }
        
        guard !amount.isEmpty else {
            alertItem = AlertContext.invalidAmount
            return false
        }
        
        if isPad {
            
            guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: amount)) else {
                alertItem = AlertContext.invalidCharacter
                return false
            }
        }
        
        return true
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                saveButtonPressed()
                audioConfirmation = true
                
            } label: {
                PrimaryButton(title: "Save Transaction")
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                showNewTransaction = false
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 24)
    }
    
    private func saveButtonPressed() {
        guard isValidForm else { return }
        let newTransaction = vm.createTransaction(
            date: date,
            type: type!,
            amount: Int(amount) ?? 0,
            notes: notes,
            tags: tags.isEmpty ? nil : [tags]
        )

        if let bankrollID = selectedBankrollID {
            vm.addTransaction(newTransaction, to: bankrollID)
        } else {
            vm.transactions.append(newTransaction)
            vm.transactions.sort(by: { $0.date > $1.date })
        }
        showNewTransaction = false
    }
}

#Preview {
    AddNewTransaction(showNewTransaction: .constant(true), audioConfirmation: .constant(false))
        .environmentObject(SessionsListViewModel())
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}
