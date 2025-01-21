//
//  AddNewSessionView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/13/23.
//

import SwiftUI
import RevenueCatUI
import RevenueCat
import TipKit

struct AddNewSessionView: View {

    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @StateObject var newSession = NewSessionViewModel()
    @ObservedObject var timerViewModel: TimerViewModel
    
    @Binding var isPresented: Bool
    @Binding var audioConfirmation: Bool
    
    @State var addLocationIsShowing = false
    @State var addStakesIsShowing = false
    @State var showPaywall = false
    @State var showCashRebuyField = false
    
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
            .scrollDismissesKeyboard(.immediately)
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
                newSession.buyIn = timerViewModel.totalBuyInForLiveSession == 0 ? "" : String(timerViewModel.totalBuyInForLiveSession - timerViewModel.rebuyTotalForSession)
                newSession.cashRebuys = newSession.sessionType == .cash ? String(timerViewModel.rebuyTotalForSession) : ""
                newSession.rebuyCount = String(timerViewModel.totalRebuys.count - 1)
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
        .alert(item: $newSession.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("New Session")
                .titleStyle()
                .padding(.top, 30)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var gameDetails: some View {
        
        VStack (alignment: .leading) {
            
            if #available(iOS 17.0, *) { newSessionTip }
            
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
            .foregroundColor(newSession.sessionType == nil ? .brandPrimary : .brandWhite)
            .buttonStyle(PlainButtonStyle())
            .animation(.none, value: newSession.sessionType)
            .onChange(of: newSession.sessionType) { _ in
                newSession.multiDayToggle = false
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        
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
                        .animation(nil, value: newSession.location)
                }
            }
            .foregroundColor(newSession.location.name.isEmpty ? .brandPrimary : .brandWhite)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .sheet(isPresented: $addLocationIsShowing, content: {
            NewLocationView(addLocationIsShowing: $addLocationIsShowing)
        })
        .animation(nil, value: newSession.location)
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
            
            HStack {
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                Text("Multi-Day")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Toggle(isOn: $newSession.multiDayToggle) {
                    // No Label Needed
                }
                .tint(.brandPrimary)
                .allowsHitTesting(newSession.addDay ? false : true)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .animation(.bouncy, value: newSession.sessionType)
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
            
            // DAY ONE
            
            if newSession.multiDayToggle {
                HStack {
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                    Text("Day One")
                        .captionStyle()
                        .opacity(0.33)
                        .padding(.horizontal)
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.scale)
            }
            
            HStack {
                
                Image(systemName: "clock")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("Start", selection: $newSession.startTime, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                .accentColor(.brandPrimary)
                .padding(.leading, 4)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(.compact)
                .opacity(newSession.addDay ? 0.4 : 1)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .disabled(newSession.addDay ? true : false)
            
            HStack {
                
                Image(systemName: "hourglass.tophalf.filled")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("End", selection: $newSession.endTime, in: newSession.startTime...Date.now, displayedComponents: [.date, .hourAndMinute])
                .accentColor(.brandPrimary)
                .padding(.leading, 4)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(.compact)
                .opacity(newSession.addDay ? 0.4 : 1)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .disabled(newSession.addDay ? true : false)
            
            if newSession.addDay {
                HStack {
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                    Text("Day Two")
                        .captionStyle()
                        .opacity(0.33)
                        .padding(.horizontal)
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // DAY TWO
            
            if newSession.addDay {

                Group {
                    HStack {
                        
                        Image(systemName: "clock")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.systemGray3))
                            .frame(width: 30)
                        
                        DatePicker("Start", selection: $newSession.startTimeDayTwo, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                        .accentColor(.brandPrimary)
                        .padding(.leading, 4)
                        .font(.custom("Asap-Regular", size: 18))
                        .datePickerStyle(.compact)
                        .opacity(newSession.noMoreDays ? 0.4 : 1)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .disabled(newSession.noMoreDays ? true : false)
                    
                    
                    HStack {
                        
                        Image(systemName: "hourglass.tophalf.filled")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.systemGray3))
                            .frame(width: 30)
                        
                        DatePicker("End", selection: $newSession.endTimeDayTwo, in: newSession.startTimeDayTwo...Date.now, displayedComponents: [.date, .hourAndMinute])
                        .accentColor(.brandPrimary)
                        .padding(.leading, 4)
                        .font(.custom("Asap-Regular", size: 18))
                        .datePickerStyle(.compact)
                        .opacity(newSession.noMoreDays ? 0.4 : 1)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .disabled(newSession.noMoreDays ? true : false)
                    
                }
                .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom).combined(with: .move(edge: .top))).combined(with: .scale(scale: 0.6, anchor: .top)))
            }
            
            // ADD, COMPLETE, CANCEL BUTTONS
            
            if newSession.multiDayToggle {
                HStack {
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                    
                    Image(systemName: "x.square.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .fontWeight(.black)
                        .foregroundStyle(newSession.noMoreDays ? .gray : Color.red)
                        .opacity(newSession.noMoreDays ? 0.5 : 1)
                        .padding(.trailing)
                        .padding(.leading, newSession.addDay ? 16 : -30)
                        .onTapGesture {
                            withAnimation {
                                newSession.addDay = false
                            }
                        }
                        .opacity(newSession.addDay ? 1 : 0)
                        .animation(.snappy, value: newSession.addDay)
                        .allowsHitTesting(newSession.noMoreDays ? false : true)
                    
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .fontWeight(.black)
                        .foregroundStyle(newSession.noMoreDays || newSession.addDay ? .gray : Color.brandPrimary)
                        .opacity(newSession.noMoreDays || newSession.addDay ? 0.5 : 1)
                        .padding(.horizontal)
                        .onTapGesture {
                            withAnimation {
                                newSession.addDay = true
                            }
                        }
                        .allowsHitTesting(newSession.noMoreDays ? false : true)
                    
                    Image(systemName: newSession.noMoreDays ? "pencil.circle.fill" : "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .fontWeight(.black)
                        .foregroundStyle(newSession.noMoreDays ? Color.yellow : Color.green)
                        .padding(.leading)
                        .padding(.trailing, newSession.addDay ? 16 : -30)
                        .onTapGesture {
                            newSession.noMoreDays.toggle()
                        }
                        .opacity(newSession.addDay ? 1 : 0)
                        .animation(.snappy, value: newSession.addDay)
                        .transition(.scale)
                    
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .animation(.snappy, value: newSession.addDay)
            }
        }
    }
    
    var inputFields: some View {
        
        VStack {
            
            HStack (alignment: .top) {
                
                // MARK: CASH GAME BUY IN
                
                if newSession.sessionType != .tournament {
                    HStack {
                        Text(vm.userCurrency.symbol)
                            .font(.callout)
                            .frame(width: 13)
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
                
                // MARK: CASH GAME CASH OUT
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .frame(width: 13)
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
            
            // MARK: CASH GAME REBUYS
            if newSession.sessionType != .tournament {
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .frame(width: 13)
                        .foregroundStyle(newSession.cashRebuys.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Rebuys / Top Offs", text: $newSession.cashRebuys)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                    
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading)
                .padding(.trailing, 16)
                .padding(.bottom, 10)
            }
            
            
            // MARK: TOURNAMENTS & GASH, EXPENSES / BUY IN HANDLING
            HStack {
                
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .frame(width: 13)
                        .foregroundColor(newSession.sessionType == .tournament && newSession.buyIn.isEmpty || newSession.sessionType == .cash && newSession.expenses.isEmpty || newSession.sessionType == nil && newSession.expenses.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField(newSession.sessionType == .tournament ? "Buy In" : "Expenses (Tips, rake, etc.)", text: newSession.sessionType == .tournament ? $newSession.buyIn : $newSession.expenses)
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
                            .frame(width: 13)
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
                    
                    Image(systemName: "person.fill")
                        .font(.callout)
                        .frame(width: 13)
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
                        .frame(width: 13)
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
            
            // MARK: NOTES
            
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
                        .frame(width: 13)
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
            
            // MARK: TAGS
            
            HStack {
                Image(systemName: "tag.fill")
                    .font(.caption2)
                    .frame(width: 13)
                    .foregroundColor(newSession.tags.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Tags (Optional)", text: $newSession.tags)
                    .font(.custom("Asap-Regular", size: 17))
            }
            .allowsHitTesting(subManager.isSubscribed ? true : false)
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
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
                AppReviewRequest.requestReviewIfNeeded()
                
            } label: {
                PrimaryButton(title: "Save Session")
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                isPresented = false
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
        }
        .padding(.bottom, 10)
    }
    
    @available(iOS 17.0, *)
    var newSessionTip: some View {
        
        VStack {
            let newSessionTip = NewSessionViewTip()
            TipView(newSessionTip)
                .tipViewStyle(CustomTipViewStyle())
                .padding(.horizontal, 16)
                .padding(.bottom)
        }
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
