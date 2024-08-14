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
    @ObservedObject var timerViewModel: TimerViewModel
    
    @Binding var isPresented: Bool
    @Binding var audioConfirmation: Bool
    @State var addLocationIsShowing = false
    @State var addStakesIsShowing = false
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
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
        .onAppear {
            newSession.loadUserDefaults()
            audioConfirmation = false
            
            // Loading optional data if the user activated a live session
            if let liveSessionStartTime = timerViewModel.liveSessionStartTime {
                newSession.startTime = liveSessionStartTime
                newSession.buyIn = timerViewModel.totalBuyInForLiveSession == 0 ? "" : String(timerViewModel.totalBuyInForLiveSession)
            }

        }
        .alert(item: $newSession.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
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
            
            if newSession.sessionType != .tournament { stakesSelection }
            
            gameSelection
            
            if newSession.sessionType == .tournament { tournamentDetails }
            
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
                        Text("Add New Location")
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
                
                Button {
                    addStakesIsShowing = true
                } label: {
                    HStack {
                        Text("Add Stakes")
                        Image(systemName: "dollarsign.circle")
                    }
                }
                
                Picker("Picker", selection: $newSession.stakes) {
                    ForEach(vm.userStakes, id: \.self) {
                        Text($0).tag($0)
                    }
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
        .sheet(isPresented: $addStakesIsShowing, content: {
            NewStakesView(addStakesIsShowing: $addStakesIsShowing)
        })
        
    }
    
    var tournamentDetails: some View {
        
        VStack {
            
            HStack {
                
                Image(systemName: "stopwatch")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                Text("Speed")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Menu {
                    withAnimation {
                        Picker("Speed", selection: $newSession.speed) {
                            Text("Standard").tag("Standard")
                            Text("Turbo").tag("Turbo")
                            Text("Super Turbo").tag("Super Turbo")
                        }
                    }
                    
                } label: {
                    
                    if newSession.speed.isEmpty {
                        Text("Please select ›")
                            .bodyStyle()
                            .fixedSize()
                        
                    } else {
                        Text(newSession.speed)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: newSession.speed)
                    }
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
                .foregroundColor(newSession.speed.isEmpty ? .brandPrimary : .brandWhite)
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            HStack {
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                Text("Size")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Menu {
                    withAnimation {
                        Picker("Size", selection: $newSession.size) {
                            Text("MTT").tag("MTT")
                            Text("Sit & Go").tag("Sit & Go")
                        }
                    }
                    
                } label: {
                    
                    if newSession.size.isEmpty {
                        Text("Please select ›")
                            .bodyStyle()
                            .fixedSize()
                        
                    } else {
                        Text(newSession.size)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: newSession.size)
                    }
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
                .foregroundColor(newSession.size.isEmpty ? .brandPrimary : .brandWhite)
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
        }
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
                    Picker("Game", selection: $newSession.game) {
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
                .datePickerStyle(.compact)
                
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
                .datePickerStyle(.compact)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
    
    var inputFields: some View {
        
        VStack {
            
            HStack (alignment: .top) {
                
                // Buy In
                if newSession.sessionType != .tournament {
                    HStack {
                        Text(vm.userCurrency.symbol)
                            .font(.callout)
                            .foregroundColor(newSession.buyIn.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                        
                        TextField("Buy In", text: $newSession.buyIn)
                            .font(.custom("Asap-Regular", size: 17))
                            .keyboardType(.numberPad)
                    }
                    .padding(18)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.leading)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .leading),
                                                                                           removal: .scale(scale: 0, anchor: .bottomLeading))))
                }
                
                // Cash Out
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(newSession.cashOut.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField(newSession.sessionType == .tournament ? "Total Winnings" : "Cash Out", text: $newSession.cashOut)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading, newSession.sessionType == .tournament ? 16 : 0)
                .padding(.trailing)
                .padding(.bottom, 10)
            }
            
            // This .foregroundColor logic is gnarly because the symbol needs to change to white and account for both cash & tournament modes
            HStack {
                
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(newSession.sessionType == .tournament && newSession.buyIn.isEmpty || newSession.sessionType == .cash && newSession.expenses.isEmpty || newSession.sessionType == nil && newSession.expenses.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField(newSession.sessionType == .tournament ? "Buy In" : "Expenses (Meals, tips, etc.)", text: newSession.sessionType == .tournament ? $newSession.buyIn : $newSession.expenses)
                                        .font(.custom("Asap-Regular", size: 17))
                                        .keyboardType(.numberPad)
                                        .onChange(of: newSession.sessionType, perform: { value in
                                            newSession.expenses = ""
                                        })
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading)
                .padding(.trailing, newSession.sessionType == .tournament ? 10 : 16)
                .padding(.bottom, 10)
                
                if newSession.sessionType == .tournament {
                    HStack {
                        Text("#")
                            .font(.callout)
                            .foregroundColor(newSession.rebuyCount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                        
                        TextField("Rebuy Ct.", text: $newSession.rebuyCount)
                            .font(.custom("Asap-Regular", size: 17))
                            .keyboardType(.numberPad)
                    }
                    .padding(18)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.leading, 0)
                    .padding(.trailing, 16)
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .trailing),
                                                                                           removal: .scale(scale: 0, anchor: .topTrailing))))
                }
            }
            
            if newSession.sessionType == .tournament {
                
                HStack {
                    
                    Text("#")
                        .font(.callout)
                        .foregroundColor(newSession.entrants.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
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
                
                HStack {
                    
                    Text("#")
                        .font(.callout)
                        .foregroundColor(newSession.finish.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("Your Finish", text: $newSession.finish)
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
                .padding(.bottom, 10)
            
            if newSession.sessionType != .tournament {
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(newSession.highHandBonus.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("High Hand Bonus (Optional)", text: $newSession.highHandBonus)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.bottom, 10)
                .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .bottom),
                                                                                       removal: .scale(scale: 0, anchor: .bottom))))
            }
        }
        .padding(.horizontal, 8)
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                newSession.savedButtonPressed(viewModel: vm)
                audioConfirmation = true
                timerViewModel.liveSessionStartTime = nil
                isPresented = newSession.presentation ?? true
                
            } label: {
                PrimaryButton(title: "Save Session")
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                isPresented = false
                
            } label: {
                Text("Cancel")
                    .bodyStyle()
            }
            .tint(.red)
        }
        .padding(.bottom, 10)
    }
}

struct AddNewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewSessionView(timerViewModel: TimerViewModel(), isPresented: .constant(true), audioConfirmation: .constant(false))
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(TimerViewModel())
            .preferredColorScheme(.dark)
    }
}
