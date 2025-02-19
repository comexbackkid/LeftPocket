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
    
    @State private var askEachTimePopover = false
    @State private var sessionType: SessionType?
    @State private var location = LocationModel_v2(name: "")
    @State private var stakes = ""
    @State private var game = ""
    @State private var speed = ""
    @State private var size = ""
    @State private var currency: CurrencyType = .USD
    @State private var handsPerHour: Int = 25
    @State private var resultMessage: String = ""
    @State private var errorMessage: String?
    @State private var showAlertModal = false
    @State private var addStakesIsShowing = false
    @State private var addLocationIsShowing = false
    @State private var askLiveSessionEachTime = false
    @State private var showHandsPerHourOnNewSessionView = false
    
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
                            dismiss()
                            
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
                .padding(.bottom, 20)
            }
            .onAppear {
                loadUserDefaults()
            }
            .background(Color.brandBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { resetDefaultsButton }
            .sheet(isPresented: $showAlertModal, onDismiss: { if isPresentedAsSheet == true { dismiss() } }, content: {
                AlertModal(message: resultMessage)
                    .presentationDetents([.height(210)])
                    .presentationBackground(.ultraThinMaterial)
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
                        dismiss()
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
            
            HStack {
                
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30, height: 30)
                
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
                            .fixedSize()
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
                        
                        Picker("Picker", selection: $stakes) {
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
                    
                    Picker("Picker", selection: $game) {
                        Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                        Text("Pot Limit Omaha").tag("Pot Limit Omaha")
                        Text("Seven Card Stud").tag("Seven Card Stud")
                        Text("Mixed").tag("Mixed")
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
            
            if sessionType == .tournament {
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
    
    private func resetUserDefaults() {
        
        sessionType = nil
        location = LocationModel_v2(name: "")
        stakes = ""
        game = ""
        size = ""
        speed = ""
        currency = .USD
        askLiveSessionEachTime = false
        showHandsPerHourOnNewSessionView = false
        handsPerHour = 25
        
        let defaults = UserDefaults.standard
        let resetResult = Result {
            
            defaults.removeObject(forKey: "sessionTypeDefault")
            defaults.removeObject(forKey: "locationDefault")
            defaults.removeObject(forKey: "stakesDefault")
            defaults.removeObject(forKey: "gameDefault")
            defaults.removeObject(forKey: "currencyDefault")
            defaults.removeObject(forKey: "tournamentSizeDefault")
            defaults.removeObject(forKey: "tournamentSpeedDefault")
            defaults.removeObject(forKey: "askLiveSessionEachTime")
            defaults.removeObject(forKey: "showHandsPerHourOnNewSessionView")
            defaults.removeObject(forKey: "handsPerHourDefault")
        }
        
        switch resetResult {
        case .success:
            resultMessage = "Session Defaults reset."
        case .failure(let error):
            resultMessage = "\(error.localizedDescription)"
        }
    }
    
    private func saveToUserDefaults() {
        
        let defaults = UserDefaults.standard
        let saveResult = Result {
            
            if let encodedSessionType = try? JSONEncoder().encode(sessionType) {
                defaults.set(encodedSessionType, forKey: "sessionTypeDefault")
            }
            
            if let encodedLocation = try? JSONEncoder().encode(location) {
                defaults.set(encodedLocation, forKey: "locationDefault")
            }
            
            if let encodedCurrency = try? JSONEncoder().encode(currency) {
                defaults.set(encodedCurrency, forKey: "currencyDefault")
            }
            
            defaults.set(stakes, forKey: "stakesDefault")
            defaults.set(game, forKey: "gameDefault")
            defaults.set(size, forKey: "tournamentSizeDefault")
            defaults.set(speed, forKey: "tournamentSpeedDefault")
            defaults.set(askLiveSessionEachTime, forKey: "askLiveSessionEachTime")
            defaults.set(showHandsPerHourOnNewSessionView, forKey: "showHandsPerHourOnNewSessionView")
            defaults.set(handsPerHour, forKey: "handsPerHourDefault")
            vm.getUserCurrency()
        }
        
        switch saveResult {
        case .success:
            resultMessage = "Session Defaults have been saved."
            showAlertModal = true
            
        case .failure(let error):
            errorMessage = "\(error.localizedDescription)"
        }
    }
    
    private func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
        // Load Currency
        if let encodedCurrency = defaults.object(forKey: "currencyDefault") as? Data,
           let decodedCurrency = try? JSONDecoder().decode(CurrencyType.self, from: encodedCurrency) {
            currency = decodedCurrency
        } else {
            currency = .USD // Provide a default value if missing
        }
        
        // Load Session Type
        if let encodedSessionType = defaults.object(forKey: "sessionTypeDefault") as? Data,
           let decodedSessionType = try? JSONDecoder().decode(SessionType.self, from: encodedSessionType) {
            sessionType = decodedSessionType
        } else {
            sessionType = nil
        }
        
        // Load Location
        if let encodedLocation = defaults.object(forKey: "locationDefault") as? Data,
           let decodedLocation = try? JSONDecoder().decode(LocationModel_v2.self, from: encodedLocation) {
            location = decodedLocation
        } else {
            location = LocationModel_v2(name: "")
        }
        
        if let handsPerHour = defaults.object(forKey: "handsPerHourDefault") as? Int {
            self.handsPerHour = handsPerHour
        } else {
            handsPerHour = 25
        }
        
        // Load Stakes, Game, & Tournament Defaults
        stakes = defaults.string(forKey: "stakesDefault") ?? ""
        game = defaults.string(forKey: "gameDefault") ?? ""
        size = defaults.string(forKey: "tournamentSizeDefault") ?? ""
        speed = defaults.string(forKey: "tournamentSpeedDefault") ?? ""
        askLiveSessionEachTime = defaults.bool(forKey: "askLiveSessionEachTime")
        showHandsPerHourOnNewSessionView = defaults.bool(forKey: "showHandsPerHourOnNewSessionView")
    }
}

enum CurrencyType: String, CaseIterable, Identifiable, Codable {
    case USD
    case EUR
    case GBP
    case BRL
    case SGD
    case MXN
    case CNY
    case JPY
    case PHP
    case SEK
    case INR
    case THB
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .GBP: return "British Pound"
        case .BRL: return "Brazilian Real"
        case .SGD: return "Singapore Dollar"
        case .MXN: return "Mexican Peso"
        case .CNY: return "Chinese Yuan"
        case .JPY: return "Japanese Yen"
        case .PHP: return "Philippines Peso"
        case .SEK: return "Swedish Krona"
        case .INR: return "Indian Rupee"
        case .THB: return "Thai Baht"
        }
    }
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .BRL: return "R$"
        case .SGD: return "S$"
        case .MXN: return "MX$"
        case .CNY: return "¥"
        case .JPY: return "¥"
        case .PHP: return "₱"
        case .SEK: return "kr"
        case .INR: return "₹"
        case .THB: return "฿"
        }
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
