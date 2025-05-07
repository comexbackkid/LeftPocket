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

enum Field {
    case buyIn
    case cashOut
    case bounties
    case rebuys
    case rebuyCount
    case entrants
    case finish
    case expenses
    case notes
    case highHands
    case stakerName
    case stakerAmount
}

struct AddNewSessionView: View {

    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    @StateObject var newSession = NewSessionViewModel()
    @ObservedObject var timerViewModel: TimerViewModel
    @Binding var audioConfirmation: Bool
    @State var addLocationIsShowing = false
    @State var addStakesIsShowing = false
    @State var addGameTypeIsShowing = false
    @State var showPaywall = false
    @State var showCashRebuyField = false
    @State var showStakingPopover = false
    @State var showBountiesPopover = false
    @State var showCustomMarkup = false
    @State var locationsBefore = 0
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @AppStorage("multipleBankrollsEnabled") var multipleBankrollsEnabled: Bool = false
    private var selectedBankrollName: String {
        if let id = newSession.selectedBankrollID,
           let match = vm.bankrolls.first(where: { $0.id == id }) {
            return match.name
        } else {
            return "Default"
        }
    }
    
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
            .safeAreaInset(edge: .bottom, spacing: 10) {
                Color.clear.frame(height: 20)
            }
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
        .onAppear {
            newSession.loadUserDefaults(bankrolls: vm.bankrolls)
            audioConfirmation = false
            if let liveSessionStartTime = timerViewModel.liveSessionStartTime {
                newSession.times[0].start = liveSessionStartTime
                newSession.buyIn = String(timerViewModel.totalBuyInForLiveSession - timerViewModel.rebuyTotalForSession)
                newSession.cashRebuys = timerViewModel.rebuyTotalForSession == 0 ? "" : String(timerViewModel.rebuyTotalForSession)
                newSession.rebuyCount = String(timerViewModel.totalRebuys.count)
                newSession.notes = timerViewModel.notes.joined(separator: "\n\n")
                newSession.totalPausedTime = timerViewModel.totalPausedTime
                newSession.moodLabelRaw = timerViewModel.moodLabelRaw
            }
        }
        .fullScreenCover(isPresented: $showPaywall, content: {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                .dynamicTypeSize(.large)
                .overlay {
                    HStack {
                        Spacer()
                        VStack {
                            DismissButton()
                                .padding(.horizontal)
                                .onTapGesture {
                                    showPaywall = false
                            }
                            Spacer()
                        }
                    }
                }
        })
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
            
            newSessionTip
            
            sessionSelection
            
            if multipleBankrollsEnabled { bankrollSelection }
            
            locationSelection
            
            gameSelection
            
            if newSession.sessionType != .tournament { stakesAndHands }

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
                .frame(width: 30, height: 30)
            
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
                    withAnimation {
                        newSession.sessionType = .tournament
                    }
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
    
    var bankrollSelection: some View {
        
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
                Picker("Bankroll Picker", selection: $newSession.selectedBankrollID) {
                    Text("Default").tag(UUID?.none)
                    ForEach(vm.bankrolls) { bankroll in
                        Text(bankroll.name).tag(Optional(bankroll.id))
                    }
                }
   
            } label: {
                Text(selectedBankrollName)
                    .bodyStyle()
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .animation(nil, value: newSession.selectedBankrollID)
            }
            .foregroundColor(.brandWhite)
            .buttonStyle(PlainButtonStyle())
            .animation(.none, value: newSession.selectedBankrollID)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    var locationSelection: some View {
        
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(.systemGray3))
                .frame(width: 30, height: 30)
            
            Text("Location")
                .bodyStyle()
                .padding(.leading, 4)
            
            Spacer()
            
            let locationCount = vm.locations.count
            
            Menu {
                
                Button {
                    if !subManager.isSubscribed && locationCount < 2 {
                        addLocationIsShowing = true
                        
                    } else if subManager.isSubscribed {
                        addLocationIsShowing = true
                        
                    } else {
                        showPaywall = true
                    }
                    
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
                        .truncationMode(.tail)
                        .animation(nil, value: newSession.location)
                }
            }
            .foregroundColor(newSession.location.name.isEmpty ? .brandPrimary : .brandWhite)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .sheet(isPresented: $addLocationIsShowing, onDismiss: {
            if vm.locations.count > locationsBefore {
                if let newLocation = vm.locations.last {
                    newSession.location = newLocation
                }
            }
        }, content: {
            NewLocationView(addLocationIsShowing: $addLocationIsShowing)
                .presentationDragIndicator(.visible)
                .onAppear {
                    locationsBefore = vm.locations.count
                }
        })
        .animation(nil, value: newSession.location)
    }
    
    var stakesAndHands: some View {
        
        // MARK: STAKES SELECTION
        
        VStack {
            HStack {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
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
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .transition(.opacity.combined(with: .scale(scale: 1, anchor: .top)))
            .sheet(isPresented: $addStakesIsShowing, content: {
                NewStakesView(addStakesIsShowing: $addStakesIsShowing)
            })
            .animation(nil, value: newSession.stakes)
            
            // MARK: HANDS PER HOUR SELECTION
            
            if newSession.showHandsPerHour {
                HStack {
                    
                    Image(systemName: "hare.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                        .frame(width: 30, height: 30)
                    
                    Text("Hands Per Hour")
                        .bodyStyle()
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Menu {
                        
                        Menu {
                            Picker("Live Hands Per Hour", selection: $newSession.handsPerHour) {
                                Text("15").tag(15)
                                Text("20").tag(20)
                                Text("25").tag(25)
                                Text("30").tag(30)
                                Text("35").tag(35)
                            }
                        } label: {
                            Text("Live")
                        }
                        
                        Menu {
                            Picker("Online ands Per Hour", selection: $newSession.handsPerHour) {
                                Text("50").tag(50)
                                Text("75").tag(75)
                                Text("100").tag(100)
                                Text("125").tag(125)
                                Text("150").tag(150)
                                Text("175").tag(175)
                                Text("200").tag(200)
                            }
                        } label: {
                            Text("Online")
                        }
                        
                    } label: {
                        Text("\(newSession.handsPerHour)")
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: newSession.handsPerHour)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
    
    var tournamentDetails: some View {
        
        VStack {
            
            // MARK: TOURNAMENT SPEED
            
            HStack {
                Image(systemName: "stopwatch")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
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
            
            // MARK: TOURNAMENT SIZE
            
            HStack {
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
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
            
            // MARK: TOURNAMENT BOUNTIES TOGGLE
            
            HStack {
                
                Image(systemName: "scope")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
                HStack {
                    Text("Bounties")
                        .bodyStyle()
                        
                    Button {
                        showBountiesPopover = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
                .padding(.leading, 4)
                .popover(isPresented: $showBountiesPopover, content: {
                    PopoverView(bodyText: "Bounty dollar value is added together with your Tournament Payout to determine your total gross winnings.")
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .frame(height: 140)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .shadow(radius: 10)
                })
                
                Spacer()
                
                if subManager.isSubscribed {
                    withAnimation {
                        Toggle(isOn: $newSession.hasBounties.animation()) {
                            // No Label Needed
                        }
                        .tint(.brandPrimary)
                    }
                    
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .animation(.easeInOut, value: newSession.sessionType)
            
            // MARK: TOURNAMENT STAKING TOGGLE
            
            HStack {
                
                Image(systemName: "cart.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
                HStack {
                    Text("Staking")
                        .bodyStyle()
                    
                    Button {
                        showStakingPopover = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
                .padding(.leading, 4)
                .popover(isPresented: $showStakingPopover, content: {
                    PopoverView(bodyText: "Similar to crowdfunding, if you're selling action or shares of a Tournament you can keep track of who's staking you & for what percentage of the gross winnings they're entitled to.")
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .frame(height: 170)
                        .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                        .presentationCompactAdaptation(.popover)
                        .shadow(radius: 10)
                })
                
                Spacer()
                
                if subManager.isSubscribed {
                    Toggle(isOn: $newSession.staking) {
                        // No Label Needed
                    }
                    .tint(.brandPrimary)
                    
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .animation(.easeInOut, value: newSession.sessionType)
            
            if newSession.staking {
                HStack {
                    
                    Image(systemName: "percent")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                        .frame(width: 30, height: 30)
                    
                    Text("Markup")
                        .bodyStyle()
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Menu {
                        withAnimation {
                            Picker("Markup", selection: $newSession.markup) {
                                Text("1.0").tag(1.0)
                                Text("1.1").tag(1.1)
                                Text("1.2").tag(1.2)
                                Text("1.3").tag(1.3)
                                Text("1.4").tag(1.4)
                                Text("1.5").tag(1.5)
                            }
                        }
                        
                        Button("Custom Amount") {
                            showCustomMarkup = true
                        }
                        
                    } label: {
                        Text("\(newSession.markup.formatted(.number.precision(.fractionLength(2))))")
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: newSession.markup)
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .animation(.easeInOut, value: newSession.staking)
                .sheet(isPresented: $showCustomMarkup) {
                    CustomMarkupAmount(markup: $newSession.markup)
                        .presentationDetents([.height(360), .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.ultraThinMaterial)
                }
            }
            
            // MARK: TOURNAMENT MULTI-DAY TOGGLE
            
            HStack {
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
                Text("Multi-Day")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                if subManager.isSubscribed {
                    Toggle(isOn: $newSession.multiDayToggle) {
                        // No Label Needed
                    }
                    .tint(.brandPrimary)
                    .allowsHitTesting(newSession.tournamentDays > 1 ? false : true)
                    
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .animation(.easeInOut, value: newSession.sessionType)
        }
    }
    
    var gameSelection: some View {
        
        VStack {
            
            HStack {
                
                Image(systemName: "dice")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
                Text("Game")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Menu {
                    
                    Button {
                        addGameTypeIsShowing = true
                        
                    } label: {
                        HStack {
                            Text("Add Game")
                            Image(systemName: "dice")
                        }
                    }
                    
                    Picker("Picker", selection: $newSession.game) {
                        ForEach(vm.userGameTypes, id: \.self) {
                            Text($0).tag($0)
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
            .sheet(isPresented: $addGameTypeIsShowing) {
                NewGameType()
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
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(width: 15)
                            .foregroundColor(newSession.buyIn.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                        
                        TextField("Buy In", text: $newSession.buyIn)
                            .font(.custom("Asap-Regular", size: 17))
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .buyIn)
                    }
                    .padding(18)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.leading)
                    .padding(.trailing, 5)
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .asymmetric(insertion: .push(from: .leading),
                                                                    removal: .scale(scale: 0, anchor: .bottomLeading).combined(with: .push(from: .trailing)))))
                }
                
                // MARK: CASH OUT / WINNINGS
                
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .font(.callout)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 15)
                        .foregroundColor(newSession.cashOut.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField(newSession.sessionType == .tournament ? "Tournament Payout" : "Cash Out", text: $newSession.cashOut)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .cashOut)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading, newSession.sessionType == .tournament ? 16 : 0)
                .padding(.trailing)
                .padding(.bottom, 10)
            }
            
            // MARK: BOUNTIES
            
            if newSession.sessionType != .cash && newSession.hasBounties {
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .font(.callout)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 15)
                        .foregroundColor(newSession.bounties.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("Bounties", text: $newSession.bounties)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .bounties)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom, 10)
                .transition(.asymmetric(insertion: .scale.combined(with: .push(from: .top)),
                                        removal: .push(from: .bottom).combined(with: .scale(scale: 0, anchor: .top))))
            }
            
            // MARK: CASH GAME REBUYS
            
            if newSession.sessionType != .tournament {
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .font(.callout)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 15)
                        .foregroundStyle(newSession.cashRebuys.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Rebuys / Top Offs", text: $newSession.cashRebuys)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .rebuys)
                    
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading)
                .padding(.trailing, 16)
                .padding(.bottom, 10)
                .transition(.asymmetric(insertion: .scale(scale: 0, anchor: .bottom).combined(with: .opacity),
                                        removal: .scale(scale: 0, anchor: .bottom).combined(with: .opacity)))
            }
            
            // MARK: TOURNAMENTS & GASH, EXPENSES / BUY IN HANDLING
            
            HStack {
                
                HStack {
                    Text(vm.userCurrency.symbol)
                        .font(.callout)
                        .font(.callout)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 15)
                        .foregroundColor(newSession.sessionType == .tournament && newSession.buyIn.isEmpty || newSession.sessionType == .cash && newSession.expenses.isEmpty || newSession.sessionType == nil && newSession.expenses.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField(newSession.sessionType == .tournament ? "Buy In" : "Table Expenses (Rake, tips)", text: newSession.sessionType == .tournament ? $newSession.buyIn : $newSession.expenses)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .expenses)
                        .onChange(of: newSession.sessionType, perform: { value in
                            newSession.expenses = ""
                        })
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading)
                .padding(.trailing, newSession.sessionType == .tournament ? 5 : 16)
                .padding(.bottom, 10)
                
                if newSession.sessionType == .tournament {
                    HStack {
                        Text("#")
                            .font(.callout)
                            .frame(width: 15)
                            .foregroundColor(newSession.rebuyCount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                        
                        TextField("Rebuys", text: $newSession.rebuyCount)
                            .font(.custom("Asap-Regular", size: 17))
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .rebuyCount)
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
            
            // MARK: TOURNAMENT-ONLY SPECIFIC DETAILS
            
            if newSession.sessionType == .tournament {
                HStack {
                    
                    Image(systemName: "person.fill")
                        .font(.callout)
                        .frame(width: 15)
                        .foregroundColor(newSession.entrants.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("No. of Entrants", text: $newSession.entrants)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .entrants)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.bottom, 10)
                .transition(.opacity.combined(with: .scale))
                
                HStack {
                    
                    Image(systemName: "trophy.fill")
                        .font(.callout)
                        .frame(width: 15)
                        .foregroundColor(newSession.finish.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("Your Finish", text: $newSession.finish)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .finish)
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
                .focused($focusedField, equals: .notes)
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 15)
                        .foregroundColor(newSession.highHandBonus.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("High Hand Bonus (Optional)", text: $newSession.highHandBonus)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .highHands)
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
            
            let tagsList = vm.allSessions.filter({ !$0.tags.isEmpty }).map({ $0.tags[0] }).uniqued()
            HStack {
                Image(systemName: "tag.fill")
                    .font(.caption2)
                    .frame(width: 15)
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
                if !tagsList.isEmpty && subManager.isSubscribed {
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(tagsList, id: \.self) { tag in
                                Button(tag) {
                                    let impact = UIImpactFeedbackGenerator(style: .soft)
                                    impact.impactOccurred()
                                    newSession.tags = ""
                                    newSession.tags = tag
                                }
                            }
                            
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.bold)
                                .frame(height: 20)
                                .padding(.bottom, 10)
                                .padding(.trailing, 40)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
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
            
            // MARK: TOURNAMENT STAKING
            
            if newSession.staking {
                VStack {
                    
                    HStack {
                        Rectangle().frame(height: 0.75)
                            .opacity(0.1)
                        Text("Action Sold")
                            .captionStyle()
                            .fixedSize()
                            .opacity(0.33)
                            .padding(.horizontal)
                        Rectangle().frame(height: 0.75)
                            .opacity(0.1)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 26)
                    
                    HStack (alignment: .center) {
                        
                        if !newSession.stakerName.isEmpty {
                            Group {
                                Button {
                                    let impact = UIImpactFeedbackGenerator(style: .soft)
                                    impact.impactOccurred()
                                    guard !newSession.stakerName.isEmpty, !newSession.actionSold.isEmpty else {
                                        newSession.alertItem = AlertContext.invalidStakingField
                                        return
                                    }
                                    newSession.addStaker(newSession.stakerName, Double(newSession.actionSold) ?? 0)
                                    newSession.stakerName = ""
                                    newSession.actionSold = ""

                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .fontWeight(.black)
                                        .foregroundStyle(Color.brandPrimary)
                                        .padding(.trailing, 5)
                                }
                            }
                            .transition(.asymmetric(insertion: .scale.combined(with: .push(from: .leading)),
                                                    removal: .push(from: .trailing).combined(with: .scale(scale: 0, anchor: .leading))))
                        }
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.callout)
                                .frame(width: 15)
                                .foregroundColor(newSession.stakerName.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                            
                            withAnimation {
                                TextField("Name", text: $newSession.stakerName)
                                    .font(.custom("Asap-Regular", size: 17))
                                    .focused($focusedField, equals: .stakerName)
                            }
                        }
                        .padding(18)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                        
                        
                        HStack {
                            Text("%")
                                .font(.callout)
                                .frame(width: 15)
                                .foregroundColor(newSession.actionSold.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                            
                            TextField("", text: $newSession.actionSold)
                                .font(.custom("Asap-Regular", size: 17))
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .stakerAmount)
                        }
                        .frame(width: 60)
                        .padding(18)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.leading, 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .animation(.bouncy, value: newSession.stakerName)
                }
                
                VStack (alignment: .leading) {
                    ForEach(newSession.stakerList) { staker in
                        HStack (alignment: .center) {
                            
                            Button {
                                let impact = UIImpactFeedbackGenerator(style: .soft)
                                impact.impactOccurred()
                                newSession.removeStaker(staker)
                                
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .fontWeight(.black)
                                    .foregroundStyle(Color.red)
                                    .padding(.trailing, 10)
                            }
                            
                            Text(staker.name + " is staking \(staker.percentage.asPercent())")
                                .font(.custom("Asap-Regular", size: 17))
                                .opacity(0.33)
                            
                            Spacer()
                        }
                        .padding(.leading)
                        .padding(.bottom, 5)
                    }
                }
                .padding(.top)
                .padding(.bottom, newSession.stakerList.isEmpty ? 0 : 16)
            }
        }
        .padding(.horizontal, 8)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                if focusedField == .buyIn {
                    Button("Next") {
                        focusedField = .cashOut
                    }
                } else if focusedField == .cashOut {
                    if newSession.hasBounties {
                        Button("Next") {
                            focusedField = newSession.sessionType == .cash ? .rebuys : .bounties
                        }
                    } else {
                        Button("Next") {
                            focusedField = newSession.sessionType == .cash ? .rebuys : .expenses
                        }
                    }
                } else if focusedField == .bounties {
                    Button("Next") {
                        focusedField = .expenses
                    }
                } else if focusedField == .rebuys {
                    Button("Next") {
                        focusedField = .expenses
                    }
                } else if focusedField == .expenses {
                    Button("Next") {
                        focusedField = newSession.sessionType == .cash ? .notes : .rebuyCount
                    }
                } else if focusedField == .rebuyCount {
                    Button("Next") {
                        focusedField = .entrants
                    }
                } else if focusedField == .entrants {
                    Button("Next") {
                        focusedField = .finish
                    }
                } else if focusedField == .finish {
                    Button("Next") {
                        focusedField = .notes
                    }
                } else if focusedField == .notes {
                    if newSession.sessionType == .cash {
                        Button("Next") {
                            focusedField = .highHands
                        }
                    } else {
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                } else if focusedField == .highHands {
                    Button("Done") {
                        focusedField = nil
                    }
                }
                if focusedField == .stakerName {
                    Button("Next") {
                        focusedField = .stakerAmount
                    }
                } else if focusedField == .stakerAmount {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                newSession.savedButtonPressed(viewModel: vm) {
                    dismiss()
                }
                audioConfirmation = true
                timerViewModel.liveSessionStartTime = nil
                
            } label: {
                PrimaryButton(title: "Save Session")
            }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                audioConfirmation = false
                dismiss()
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
    
    var newSessionTip: some View {
        
        VStack {
            let newSessionTip = NewSessionViewTip()
            TipView(newSessionTip) { action in
                if action.id == "add-first-location" {
                    addLocationIsShowing = true
                    newSessionTip.invalidate(reason: .actionPerformed)
                }
            }
            .tipViewStyle(CustomTipViewStyle())
            .padding(.horizontal, 16)
            .padding(.bottom)
        }
    }
}

struct AddNewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewSessionView(timerViewModel: TimerViewModel(), audioConfirmation: .constant(false))
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(TimerViewModel())
            .preferredColorScheme(.dark)
    }
}
