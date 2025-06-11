//
//  SessionDefaultsView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/11/24.
//

import SwiftUI

struct SessionDefaultsView: View {
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var isPresentedAsSheet: Bool?
    @State var askEachTimePopover = false
    @State var sessionType: SessionType?
    @State var selectedBankrollID: UUID?
    @State var location = LocationModel_v2(name: "")
    @State var stakes = ""
    @State var game = ""
    @State var speed = ""
    @State var size = ""
    @State var currency: CurrencyType = .USD
    @State var handsPerHour: Int = 25
    @State var resultMessage: LocalizedStringResource = ""
    @State var errorMessage: String?
    @State var showAlertModal = false
    @State var addStakesIsShowing = false
    @State var addGameTypeIsShowing = false
    @State var addLocationIsShowing = false
    @State var askLiveSessionEachTime = false
    @State var showHandsPerHourOnNewSessionView = false
    @AppStorage("multipleBankrollsEnabled") var multipleBankrollsEnabled: Bool = false
    private var selectedBankrollName: String {
        if let id = selectedBankrollID,
           let match = vm.bankrolls.first(where: { $0.id == id }) {
            return match.name
        } else {
            return "Default"
        }
    }
    
    var body: some View {
            
            ScrollView (.vertical) {
                
                VStack {
                    
                    title
                    
                    instructions
                    
                    gameSelections
                    
                    saveDefaultsButton
                    
                    if isPresentedAsSheet == true {
                        Button(role: .cancel) {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            if isPresentedAsSheet == true { dismiss() }
                            
                        } label: {
                            Text("Cancel")
                                .buttonTextStyle()
                        }
                        .tint(.red)
                    }
                    
                    if let errorMessage {
                        
                        VStack {
                            Text("Uh oh! There was a problem.")
                            Text(errorMessage)
                            Image(systemName: "x.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.top, 1)
                                .foregroundColor(.red)
                        }
                    }
                }
                .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
                .background(Color.brandBackground)
                .padding(.bottom, 60)
            }
            .onAppear {
                loadUserDefaults()
            }
            .background(Color.brandBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { resetDefaultsButton }
            .sheet(isPresented: $showAlertModal, onDismiss: { if isPresentedAsSheet == true { dismiss() } }, content: {
                AlertModal(message: resultMessage, image: "checkmark.circle", imageColor: Color.green)
                    .presentationDetents([.height(280)])
                    .presentationBackground(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                    .presentationDragIndicator(.visible)
            })
            .overlay {
                if isPresentedAsSheet == true {
                    dismissButton
                }
            }
    }
    
    var title: some View {
        
        HStack {
            Text("Session Defaults")
                .titleStyle()
                .padding(.top, isPresentedAsSheet ?? false ? 30 : 0)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var dismissButton: some View {
        
        VStack {
            HStack {
                Spacer()
                DismissButton()
                    .shadow(color: Color.black.opacity(0.1), radius: 8)
                    .onTapGesture {
                        if isPresentedAsSheet == true { dismiss() }
                    }
            }
            Spacer()
        }
        .padding()
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Set your default Session info here. These values will automatically pre-populate whenever you log a completed Session, or start a Live Session.")
                    .bodyStyle()
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var gameSelections: some View {
        
        VStack {
            
            // MARK: SESSION TYPE
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
                    
                    Picker("Picker", selection: $sessionType) {
                        Text("Cash Game").tag(Optional(SessionType.cash))
                        
                        // Right now we're just choosing to hide the Tournament option unless user is subscribed
                        Text("Tournament").tag(Optional(SessionType.tournament))
                    }
                    .onChange(of: sessionType, perform: { value in
                        errorMessage = nil
                        resultMessage = ""
                    })
                    
                } label: {
                    
                    switch sessionType {
                    case .cash:
                        Text("Cash Game")
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                        
                    case .tournament:
                        Text("Tournament")
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                        
                    case .none:
                        Text("Please select ›")
                            .bodyStyle()
                            .lineLimit(1)
                    }
                }
                .foregroundColor(sessionType == nil ? .brandPrimary : .brandWhite)
                .buttonStyle(PlainButtonStyle())
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .padding(.bottom, 10)
            .padding(.top, 10)
            
            // MARK: DEFAULT BANKROLL
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
                        .animation(nil, value: selectedBankrollID)
                }
                .foregroundColor(.brandWhite)
                .buttonStyle(PlainButtonStyle())
                .animation(.none, value: selectedBankrollID)
            }
            .padding(.bottom, 10)
            
            // MARK: LOCATION
            HStack {
                
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
                Text("Location")
                    .bodyStyle()
                    .padding(.leading, 4)
                    .lineLimit(1)
                
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
                    
                    Picker("Picker", selection: $location) {
                        ForEach(vm.locations) { location in
                            Text(location.name).tag(location)
                        }
                    }
                    .onChange(of: location, perform: { value in
                        errorMessage = nil
                        resultMessage = ""
                    })
                    
                } label: {
                    if location.name.isEmpty {
                        Text("Please select ›")
                            .bodyStyle()
                            .lineLimit(1)
                        
                    } else {
                        Text(location.name)
                            .bodyStyle()
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .foregroundColor(location.name.isEmpty ? .brandPrimary : .brandWhite)
                .buttonStyle(PlainButtonStyle())
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .padding(.bottom, 10)
            .sheet(isPresented: $addLocationIsShowing, content: {
                NewLocationView(addLocationIsShowing: $addLocationIsShowing)
            })
            
            if sessionType != .tournament {
                
                // MARK: STAKES
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
                        
                        Picker("Stakes Picker", selection: $stakes) {
                            ForEach(vm.userStakes, id: \.self) {
                                Text($0).tag($0)
                            }
                            .onChange(of: stakes, perform: { value in
                                errorMessage = nil
                                resultMessage = ""
                            })
                        }
                        
                    } label: {
                        if stakes.isEmpty {
                            Text("Please select ›")
                                .bodyStyle()
                        } else {
                            Text(stakes)
                                .bodyStyle()
                                .fixedSize()
                        }
                    }
                    .foregroundColor(stakes.isEmpty ? .brandPrimary : .brandWhite)
                    .buttonStyle(PlainButtonStyle())
                    .transaction { transaction in
                        transaction.animation = .none
                    }
                }
                .padding(.bottom, 10)
                .sheet(isPresented: $addStakesIsShowing, content: {
                    NewStakesView(addStakesIsShowing: $addStakesIsShowing)
                })
            }
            
            // MARK: GAME TYPE
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
                    
                    Picker("Game", selection: $game) {
                        ForEach(vm.userGameTypes, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .onChange(of: game, perform: { value in
                        errorMessage = nil
                        resultMessage = ""
                    })
                    
                } label: {
                    if game.isEmpty {
                        Text("Please select ›")
                            .bodyStyle()
                            .fixedSize()
                        
                    } else {
                        Text(game)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                    }
                }
                .foregroundColor(game.isEmpty ? .brandPrimary : .brandWhite)
                .buttonStyle(PlainButtonStyle())
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .padding(.bottom, 10)
            .sheet(isPresented: $addGameTypeIsShowing) {
                NewGameType()
            }
            
            if sessionType == .tournament {
                
                // MARK: TOUNRAMENT SPEED
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
                            Picker("Speed", selection: $speed) {
                                Text("Standard").tag("Standard")
                                Text("Turbo").tag("Turbo")
                                Text("Super Turbo").tag("Super Turbo")
                            }
                            .onChange(of: speed, perform: { value in
                                errorMessage = nil
                                resultMessage = ""
                            })
                        }
                        
                    } label: {
                        
                        if speed.isEmpty {
                            Text("Please select ›")
                                .bodyStyle()
                                .fixedSize()
                            
                        } else {
                            Text(speed)
                                .bodyStyle()
                                .fixedSize()
                                .lineLimit(1)
                                .animation(nil, value: speed)
                        }
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .foregroundColor(speed.isEmpty ? .brandPrimary : .brandWhite)
                    .buttonStyle(.plain)
                }
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
                            Picker("Size", selection: $size) {
                                Text("MTT").tag("MTT")
                                Text("Sit & Go").tag("Sit & Go")
                            }
                            .onChange(of: size, perform: { value in
                                errorMessage = nil
                                resultMessage = ""
                            })
                        }
                        
                    } label: {
                        
                        if size.isEmpty {
                            Text("Please select ›")
                                .bodyStyle()
                                .fixedSize()
                            
                        } else {
                            Text(size)
                                .bodyStyle()
                                .fixedSize()
                                .lineLimit(1)
                                .animation(nil, value: size)
                        }
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .foregroundColor(size.isEmpty ? .brandPrimary : .brandWhite)
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)
            }
            
            
            // MARK: CURRENCY
            HStack {
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
                
                Text("Currency")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Menu {
                    
                    Picker("Picker", selection: $currency) {
                        ForEach(CurrencyType.allCases) {
                            Text($0.symbol).tag($0)
                        }
                    }
                    .onChange(of: currency, perform: { value in
                        errorMessage = nil
                        resultMessage = ""
                    })

                } label: {
                    
                    Text(currency.name)
                        .bodyStyle()
                        .fixedSize()
                        .lineLimit(1)
                }
                .foregroundColor(.brandWhite)
                .buttonStyle(PlainButtonStyle())
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            .padding(.bottom, 10)
            
            // MARK: HANDS PER HOUR
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
                        Picker("Live Hands Per Hour", selection: $handsPerHour) {
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
                        Picker("Online ands Per Hour", selection: $handsPerHour) {
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
                    Text("\(handsPerHour)")
                        .bodyStyle()
                        .fixedSize()
                        .lineLimit(1)
                }
                .foregroundColor(.brandWhite)
            }
            .padding(.bottom, 10)
            
            // MARK: DISPLAY HANDS PER HOUR?
            HStack {
                
                Image(systemName: "questionmark.bubble.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                    
                Spacer()
                
                Toggle(isOn: $showHandsPerHourOnNewSessionView) {
                    Text("Show Hands Per Hour")
                        .bodyStyle()
                        .padding(.leading, 4)
                }
                .tint(.brandPrimary)
            }
            .padding(.bottom, 10)
            
            // MARK: ASK FOR DEFAULTS EACH TIME?
            HStack {
                
                Image(systemName: "questionmark.bubble.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
                Spacer()
                
                Toggle(isOn: $askLiveSessionEachTime) {
                    HStack {
                        Text("Ask Each Time")
                            .bodyStyle()
                            .padding(.leading, 4)
                        
                        Button {
                            askEachTimePopover = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.subheadline)
                                .foregroundStyle(Color.brandPrimary)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $askEachTimePopover, arrowEdge: .bottom, content: {
                            PopoverView(bodyText: "With this turned on, every time you begin a Live Session you'll be prompted to enter / verify all Session details from the start. You can change them later if you want.")
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                                .frame(height: 150)
                                .dynamicTypeSize(.medium...DynamicTypeSize.medium)
                                .presentationCompactAdaptation(.popover)
                                .preferredColorScheme(colorScheme == .dark ? .dark : .light)
                                .shadow(radius: 10)
                        })
                    }
                }
                .tint(.brandPrimary)
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 25)
        .padding(.top, 5)
    }
    
    var saveDefaultsButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            saveToUserDefaults()
            vm.writeToWidget()
            
        } label: {
            PrimaryButton(title: "Save")
        }
        .padding(.top, 4)
        .padding(.horizontal)
    }
    
    var resetDefaultsButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            resetUserDefaults()
            
        } label: {
            Image(systemName: "gobackward")
        }
        .foregroundColor(.brandPrimary)
    }
    
}

#Preview {
    NavigationView {
        SessionDefaultsView(isPresentedAsSheet: .constant(false))
            .environmentObject(SubscriptionManager())
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
