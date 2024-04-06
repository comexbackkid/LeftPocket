//
//  AddNewSessionView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/13/23.
//

import SwiftUI
import RevenueCatUI
import RevenueCat

struct AddNewSessionView: View {

    @StateObject var newSession = NewSessionViewModel()
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    @Binding var isPresented: Bool
    @State var addLocationIsShowing = false
    @State var showPaywall = false
    
    var body: some View {
        
        VStack {
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    title
                    
                    Spacer()
                    
                    gameDetails
                    
                    inputFields
                    
                    saveButton
                }
            }
        }
        .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
        .onAppear {
            newSession.loadUserDefaults()
            if let liveSessionStartTime = timerViewModel.liveSessionStartTime {
                newSession.startTime = liveSessionStartTime
            }
        }
        .alert(item: $newSession.alertItem) { alertItem in
            
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("New Session")
                .titleStyle()
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var gameDetails: some View {
        
        VStack (alignment: .leading) {
            
            sessionSelection
            
            locationSelection
            
            if newSession.sessionType != .tournament {
                
                stakesSelection
                
            }
            
            gameSelection
            
            gameTiming
            
        }
        .padding(.horizontal, 8)
    }
    
    var sessionSelection: some View {
        
        HStack {
            
            Image(systemName: "suit.club.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.systemGray3))
                .frame(width: 30)
            
            Text("Session")
                .bodyStyle()
                .padding(.leading, 4)
            
            Spacer()
            
            Menu {
                    
                Button("Cash Game") {
                    withAnimation {
                        newSession.sessionType = .cash
                    }
                }
                
                Button("Tournament") {
                    
                    if subManager.isSubscribed {
                        withAnimation {
                            newSession.sessionType = .tournament
                        }
                        
                    } else { showPaywall = true }
                }
   
            } label: {
                
                switch newSession.sessionType {
                case .cash:
                    Text("Cash Game")
                        .bodyStyle()
                        .fixedSize()
                        .lineLimit(1)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                    
                case .tournament:
                    
                    Text("Tournament")
                        .bodyStyle()
                        .fixedSize()
                        .lineLimit(1)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                    
                default:
                    Text("Please select ›")
                        .bodyStyle()
                        .fixedSize()
                        .lineLimit(1)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
            }
            .transaction { transaction in
                transaction.animation = nil
            }
            .foregroundColor(newSession.sessionType == nil ? .brandPrimary : .brandWhite)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .sheet(isPresented: $showPaywall) {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
        }
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }
    
    var locationSelection: some View {
        
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.systemGray3))
                .frame(width: 30)
            
            Text("Location")
                .bodyStyle()
                .padding(.leading, 4)
            
            Spacer()
            
            Menu {
                
                Button {
                    addLocationIsShowing.toggle()
                } label: {
                    HStack {
                        Text("Add Location")
                        Image(systemName: "mappin.and.ellipse")
                    }
                }
                                    
                Picker("Picker", selection: $newSession.location) {
                    ForEach(vm.locations) { location in
                        Text(location.name).tag(location)
                    }
                }
                
            } label: {
                
                if newSession.location.name.isEmpty {
                    Text("Please select ›")
                        .bodyStyle()
                        .lineLimit(1)

                } else {
                    
                    Text(newSession.location.name)
                        .bodyStyle()
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .animation(nil, value: newSession.location)
            .foregroundColor(newSession.location.name.isEmpty ? .brandPrimary : .brandWhite)
            .buttonStyle(PlainButtonStyle())
            .transaction { transaction in
                transaction.animation = .none
            }
            
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .sheet(isPresented: $addLocationIsShowing, content: {
            NewLocationView(addLocationIsShowing: $addLocationIsShowing)
        })
        
    }
    
    var stakesSelection: some View {
        
        HStack {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.systemGray3))
                .frame(width: 30)
            
            Text("Stakes")
                .bodyStyle()
                .padding(.leading, 4)
               
            Spacer()
            
            Menu {
                Picker("Picker", selection: $newSession.stakes) {
                    Text("1/2").tag("1/2")
                    Text("2/2").tag("2/2")
                    Text("1/3").tag("1/3")
                    Text("2/3").tag("2/3")
                    Text("2/5").tag("2/5")
                    Text("5/5").tag("5/5")
                    Text("5/10").tag("5/10")
                    Text("10/10").tag("10/10")
                    Text("10/20").tag("10/20")
                    Text("20/40").tag("20/40")
                    Text("25/50").tag("25/50")
                }
                
            } label: {
                if newSession.stakes.isEmpty {
                    Text("Please select ›")
                        .bodyStyle()
                } else {
                    Text(newSession.stakes)
                        .bodyStyle()
                        .fixedSize()
                }
            }
            .foregroundColor(newSession.stakes.isEmpty ? .brandPrimary : .brandWhite)
            .buttonStyle(PlainButtonStyle())
            .transaction { transaction in
                transaction.animation = .none
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .transition(.opacity.combined(with: .scale(scale: 1, anchor: .top)))
    }
    
    var gameSelection: some View {
        
        HStack {
            
            Image(systemName: "dice")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.systemGray3))
                .frame(width: 30)
            
            Text("Game")
                .bodyStyle()
                .padding(.leading, 4)
            
            Spacer()
            
            Menu {
                
                withAnimation {
                    Picker("Picker", selection: $newSession.game) {
                        Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                        Text("Pot Limit Omaha").tag("Pot Limit Omaha")
                        Text("Seven Card Stud").tag("Seven Card Stud")
                        Text("Mixed").tag("Mixed")
                    }
                }
                
            } label: {
                
                if newSession.game.isEmpty {
                    Text("Please select ›")
                        .bodyStyle()
                        .fixedSize()
                } else {
                    
                    Text(newSession.game)
                        .bodyStyle()
                        .fixedSize()
                        .lineLimit(1)
                        .animation(nil, value: newSession.game)
                }
            }
            .transaction { transaction in
                transaction.animation = nil
            }
            .foregroundColor(newSession.game.isEmpty ? .brandPrimary : .brandWhite)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    var gameTiming: some View {
        
        VStack {
            
            HStack {
                
                Image(systemName: "clock")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("Start", selection: $newSession.startTime, in: ...Date.now,
                           displayedComponents: [.date, .hourAndMinute])
                .accentColor(.brandPrimary)
                .padding(.leading, 4)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(CompactDatePickerStyle())
                
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            HStack {
                
                Image(systemName: "hourglass.tophalf.filled")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("End", selection: $newSession.endTime, in: newSession.startTime...Date.now,
                           displayedComponents: [.date, .hourAndMinute])
                .accentColor(.brandPrimary)
                .padding(.leading, 4)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(CompactDatePickerStyle())
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
    
    var inputFields: some View {
        
        VStack {
            
            // MARK: CURRENT PROFIT / LOSS TEXTFIELD
            
            HStack (alignment: .top) {
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(newSession.profit.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField(newSession.sessionType == .tournament ? "Winnings" : "Profit / Loss", text: $newSession.profit)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading)
                .padding(.trailing, newSession.sessionType == .tournament ? 16 : 10)
                .padding(.bottom, 10)
                
                if newSession.sessionType != .tournament {
                    
                    CustomToggle(vm: newSession)
                        .padding(.trailing)
                        .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .trailing),
                                                                        removal: .scale(scale: 0, anchor: .topTrailing))))
                }
            }
            
            // MARK: ATTEMPT AT NEW PROFIT / LOSS TEXTFIELD WITH BUY IN AND CASH OUT FIELDS
            
//            HStack (alignment: .top) {
//                
//                // Buy In
//                if newSession.sessionType != .tournament {
//                    HStack {
//                        Text(vm.userCurrency.symbol)
//                            .font(.callout)
//                            .foregroundColor(newSession.buyIn.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
//                        
//                        TextField(newSession.sessionType == .tournament ? "Winnings" : "Buy In", text: $newSession.buyIn)
//                            .font(.custom("Asap-Regular", size: 17))
//                            .keyboardType(.numberPad)
//                    }
//                    .padding(18)
//                    .background(.gray.opacity(0.2))
//                    .cornerRadius(15)
//                    .padding(.leading)
//                    .padding(.trailing, 10)
//                    .padding(.bottom, 10)
//                    .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .leading),
//                                                                                           removal: .scale(scale: 0, anchor: .topLeading))))
//                }
//                
//                // Cash Out
//                HStack {
//                    Text(vm.userCurrency.symbol)
//                        .font(.callout)
//                        .foregroundColor(newSession.cashOut.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
//                    
//                    TextField(newSession.sessionType == .tournament ? "Winnings" : "Cash Out", text: $newSession.cashOut)
//                        .font(.custom("Asap-Regular", size: 17))
//                        .keyboardType(.numberPad)
//                }
//                .padding(18)
//                .background(.gray.opacity(0.2))
//                .cornerRadius(15)
//                .padding(.leading, newSession.sessionType == .tournament ? 16 : 0)
//                .padding(.trailing)
//                .padding(.bottom, 10)
//
//            }
            
            HStack {
                Text(vm.userCurrency.symbol)
                    .font(.callout)
                    .foregroundColor(newSession.expenses.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField(newSession.sessionType == .tournament ? "Total Buy In" : "Expenses (Meals, tips, etc.)", text: $newSession.expenses)
                                    .font(.custom("Asap-Regular", size: 17))
                                    .keyboardType(.numberPad)
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            if newSession.sessionType == .tournament {
                
                HStack {
                    
                    TextField("No. of Entrants", text: $newSession.entrants)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.bottom, 10)
                .transition(.opacity.combined(with: .scale))
            }
            
            TextEditor(text: $newSession.notes)
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
                                Text(newSession.notes.isEmpty ? "Notes (Optional)" : "")
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
                .padding(.horizontal)
        }
        .padding(.horizontal, 8)
    }
    
    var saveButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            newSession.savedButtonPressed(viewModel: vm)
            timerViewModel.liveSessionStartTime = nil
            isPresented = newSession.presentation ?? true
            
        } label: {
            PrimaryButton(title: "Save Session")
        }
    }
}

struct AddNewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewSessionView(isPresented: .constant(true))
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(TimerViewModel())
            .preferredColorScheme(.dark)
    }
}
