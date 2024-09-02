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
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresentedAsSheet: Bool?
    
    @State private var sessionType: SessionType?
    @State private var location = LocationModel(name: "", localImage: "", imageURL: "")
    @State private var stakes = ""
    @State private var game = ""
    @State private var currency: CurrencyType = .USD
    @State private var resultMessage: String = ""
    @State private var errorMessage: String?
    @State private var showAlertModal = false
    @State private var addStakesIsShowing = false
    @State private var addLocationIsShowing = false
    
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
                        
                    }
                }
                .background(Color.brandBackground)
            }
            .onAppear {
                loadUserDefaults()
            }
            .background(Color.brandBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { resetDefaultsButton }
            
            .sheet(isPresented: $showAlertModal, content: {
                AlertModal(message: resultMessage)
                    .presentationDetents([.height(220)])
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
                .padding(.top, isPresentedAsSheet ?? false ? 0 : -37)
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
                Text("Choose your default settings here. These values will automatically populate every time you log a new Session.")
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
                        Text("Cash Game").tag(Optional(SessionType.cash))
                        
                        // Right now we're just choosing to hide the Tournament option unless user is subscribed
                        if subManager.isSubscribed {
                            Text("Tournament").tag(Optional(SessionType.tournament))
                        }
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
                
                Image(systemName: "banknote.fill")
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
    
    private func resetUserDefaults() {
        
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
            vm.loadCurrency()
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
        SessionDefaultsView(isPresentedAsSheet: .constant(true))
            .environmentObject(SubscriptionManager())
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
