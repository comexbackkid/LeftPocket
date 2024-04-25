//
//  SessionDefaultsView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/11/24.
//

import SwiftUI

enum CurrencyType: String, CaseIterable, Identifiable, Codable {
    case USD
    case EUR
    case GBP
    case BRL
    case MXN
    case CNY
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .GBP: return "British Pound"
        case .BRL: return "Brazilian Real"
        case .MXN: return "Mexican Peso"
        case .CNY: return "Chinese Yuan"
        }
    }
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .BRL: return "R$"
        case .MXN: return "MX$"
        case .CNY: return "¥"
        }
    }
}

struct SessionDefaultsView: View {
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var vm: SessionsListViewModel
    
    @State private var sessionType: SessionType?
    @State private var location = LocationModel(name: "", localImage: "", imageURL: "")
    @State private var stakes = ""
    @State private var game = ""
    @State private var currency: CurrencyType = .USD
    @State private var resultMessage: String = ""
    @State private var errorMessage: String?
    @State private var addStakesIsShowing = false
    @State private var addLocationIsShowing = false
    
    enum SessionType: String, Codable { case cash, tournament }
    
    var body: some View {
            
            ScrollView (.vertical) {
                
                VStack {
                    
                    title
                    
                    instructions
                    
                    gameSelections
                    
                    saveDefaultsButton
                    
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
                        
                    } else if !resultMessage.isEmpty {
                        
                        VStack {
                            Text("Success!")
                            Text(resultMessage)
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.top, 1)
                                .foregroundColor(.green)
                        }
                    }
                }
                .background(Color.brandBackground)
            }
            .onAppear {
                loadUserDefaults()
            }
            .background(Color.brandBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                resetDefaultsButton
            }
    }
    
    var title: some View {
        
        HStack {
            Text("Session Defaults")
                .titleStyle()
                .padding(.top, -37)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Choose your default settings here. These values will automatically populate every time you log a new session.")
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
                    .frame(width: 30)
                
                Text("Session")
                    .bodyStyle()
                    .padding(.leading, 4)
                
                Spacer()
                
                Menu {
                    
                    Picker("Picker", selection: $sessionType) {
                        Text("Cash Game").tag(Optional(SessionDefaultsView.SessionType.cash))
                        
                        // Right now we're just choosing to hide the Tournament option unless user is subscribed
                        if subManager.isSubscribed {
                            Text("Tournament").tag(Optional(SessionDefaultsView.SessionType.tournament))
                        }
                    }
                    .onChange(of: sessionType, perform: { value in
                        errorMessage = nil
                        resultMessage = ""
                    })
//                    .onChange(of: sessionType) {
//                        errorMessage = nil
//                        resultMessage = ""
//                    }
                    
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
            
            HStack {
                
                Image(systemName: "creditcard.circle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
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
            PrimaryButton(title: "Save Defaults")
        }
        .padding(.bottom, 20)
        
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
    
    func resetUserDefaults() {
        
        sessionType = nil
        location = LocationModel(name: "", localImage: "", imageURL: "")
        stakes = ""
        game = ""
        currency = .USD
        
        let defaults = UserDefaults.standard
        let resetResult = Result {
            
            defaults.removeObject(forKey: "sessionTypeDefault")
            defaults.removeObject(forKey: "locationDefault")
            defaults.removeObject(forKey: "stakesDefault")
            defaults.removeObject(forKey: "gameDefault")
            defaults.removeObject(forKey: "currencyDefault")
        }
        
        switch resetResult {
        case .success:
            resultMessage = "Session Defaults reset."
        case .failure(let error):
            resultMessage = "\(error.localizedDescription)"
        }
    }
    
    func saveToUserDefaults() {
        
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
            vm.loadCurrency()
        }
        
        switch saveResult {
        case .success:
            resultMessage = "Session Defaults have been saved."
        case .failure(let error):
            errorMessage = "\(error.localizedDescription)"
        }
    }
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
        guard
            let encodedCurrency = defaults.object(forKey: "currencyDefault") as? Data,
            let decodedCurrency = try? JSONDecoder().decode(CurrencyType.self, from: encodedCurrency)
                
        else { return }
        
        currency = decodedCurrency
        
        guard
            let encodedSessionType = defaults.object(forKey: "sessionTypeDefault") as? Data,
            let decodedSessionType = try? JSONDecoder().decode(SessionType.self, from: encodedSessionType)
                
        else { return }
        
        sessionType = decodedSessionType
        
        guard
            let encodedLocation = defaults.object(forKey: "locationDefault") as? Data,
            let decodedLocation = try? JSONDecoder().decode(LocationModel.self, from: encodedLocation)
                
        else { return }
        
        location = decodedLocation
        
        guard
            let encodedStakes = defaults.string(forKey: "stakesDefault"),
            let encodedGame = defaults.string(forKey: "gameDefault")
                
        else { return }
        
        stakes = encodedStakes
        game = encodedGame
    }
}

#Preview {
    NavigationView {
        SessionDefaultsView()
            .environmentObject(SubscriptionManager())
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
