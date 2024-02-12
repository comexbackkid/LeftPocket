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
    
    @State private var sessionType: SessionType?
    @State private var location = LocationModel(name: "", localImage: "", imageURL: "")
    @State private var stakes = ""
    @State private var game = ""
    
    @State private var resultMessage: String? = ""
    
    enum SessionType: String, Codable { case cash, tournament }
    
    var body: some View {
        
        GeometryReader { geo in
            
            ScrollView (.vertical) {
                
                VStack {
                    
                    title
                    
                    instructions
                    
                    gameSelections
                    
                    saveDefaultsButton
                    
                    if let resultMessage {
                        
                        VStack {
                            
                            Spacer()
                            
                            Text(resultMessage)
                            
                            if !resultMessage.isEmpty {
                                
                                Image(systemName: "checkmark.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .padding(.top, 1)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .frame(height: geo.size.height)
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
        
        VStack {
            
            Text("Choose your default Session settings here. These values will automatically populate every time you log a new Session.")
                .bodyStyle()
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
                    default:
                        Text("Please select ›")
                            .bodyStyle()
                            .lineLimit(1)
                    }
                }
                .foregroundColor(sessionType == nil ? .brandPrimary : .brandWhite)
                .buttonStyle(PlainButtonStyle())
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
                    
                    Picker("Picker", selection: $location) {
                        ForEach(vm.locations) { location in
                            Text(location.name).tag(location)
                        }
                    }
                    
                } label: {
                    
                    if location.name.isEmpty {
                        Text("Please select ›")
                            .bodyStyle()
                            .lineLimit(1)
                        
                    } else {
                        
                        Text(location.name)
                            .bodyStyle()
                            .lineLimit(1)
                    }
                }
                .foregroundColor(location.name.isEmpty ? .brandPrimary : .brandWhite)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 10)
            
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
                    
                    Picker("Picker", selection: $stakes) {
                        Text("1/2").tag("1/2")
                        Text("1/3").tag("1/3")
                        Text("2/2").tag("2/2")
                        Text("2/3").tag("2/3")
                        Text("2/5").tag("2/5")
                        Text("5/5").tag("5/5")
                        Text("5/10").tag("5/10")
                        Text("10/10").tag("10/10")
                        Text("10/20").tag("10/20")
                        Text("50/100").tag("50/100")
                        Text("100/200").tag("100/200")
                    }
                    
                } label: {
                    
                    if stakes.isEmpty {
                        Text("Please select ›")
                            .bodyStyle()
                            .fixedSize()
                    } else {
                        
                        Text(stakes)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                    }
                }
                .foregroundColor(stakes.isEmpty ? .brandPrimary : .brandWhite)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 10)
            
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
            
        } label: {
            PrimaryButton(title: "Save Defaults")
        }
        
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
        
        let defaults = UserDefaults.standard
        let resetResult = Result {
            
            defaults.removeObject(forKey: "sessionTypeDefault")
            defaults.removeObject(forKey: "locationDefault")
            defaults.removeObject(forKey: "stakesDefault")
            defaults.removeObject(forKey: "gameDefault")
            
        }
        
        switch resetResult {
        case .success:
            resultMessage = "Session Defaults reset!"
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
            
            defaults.set(stakes, forKey: "stakesDefault")
            defaults.set(game, forKey: "gameDefault")
        }
        
        switch saveResult {
        case .success:
            resultMessage = "Session Defaults saved successfully!"
        case .failure(let error):
            resultMessage = "\(error.localizedDescription)"
        }
    }
    
    func loadUserDefaults() {
        
        let defaults = UserDefaults.standard
        
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
