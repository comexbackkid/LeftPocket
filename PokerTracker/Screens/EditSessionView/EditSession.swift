//
//  EditSession.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/8/24.
//

import SwiftUI
import AVFoundation
import AVKit

struct EditSession: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    
    @State private var location: LocationModel = LocationModel(name: "", localImage: "", imageURL: "")
    @State private var date: Date = Date()
    @State private var stakes: String = ""
    @State private var game: String = ""
    @State private var startTime: Date = Date().modifyTime(minutes: -360)
    @State private var endTime: Date = Date()
    @State private var buyIn: String = ""
    @State private var cashOut: String = ""
    @State private var expenses: String = ""
    @State private var notes: String = ""
    @State private var highHandBonus: String = ""
    @State private var entrants: String = ""
    @State private var finish: String = ""
    @State private var speed: String = ""
    @State private var size: String = ""
    @State private var rebuyCount: String = ""
    @State private var tags: String = ""
    @State private var addLocationIsShowing = false
    @State private var addStakesIsShowing = false
    @State private var alertItem: AlertItem?
    @State private var sessionType: SessionType?
    
    let pokerSession: PokerSession
    
    var body: some View {
        
        VStack {
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    title
                    
                    Spacer()
                    
                    switch sessionType {
                    case .cash:
                        
                        if canEditCashSession() {
                            
                            cashGameDetails
                            cashInputFields
                            saveButton
                            
                        } else {
                            
                            errorScreen
                        }
                        
                    case .tournament:
                        
                        if canEditTournamentSession() {
                            
                            tournamentGameDetails
                            tournamentInputFields
                            saveButton
                            
                        } else {
                            
                            errorScreen
                        }
                        
                    case nil:
                        errorScreen
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
        .alert(item: $alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
        .onAppear { determineSessionType() }
    }
    
    var title: some View {
        
        HStack {
            
            Text("Edit Session")
                .titleStyle()
                .padding(.top, 30)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var cashGameDetails: some View {
        
        VStack (alignment: .leading) {
                        
            locationSelection
            
            stakesSelection
            
            gameSelection
            
            gameTiming
            
        }
        .padding(.horizontal, 8)
    }
    
    var tournamentGameDetails: some View {
        
        VStack (alignment: .leading) {
            
            locationSelection
            
            gameSelection
            
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
                            Picker("Speed", selection: $speed) {
                                Text("Standard").tag("Standard")
                                Text("Turbo").tag("Turbo")
                                Text("Super Turbo").tag("Super Turbo")
                            }
                        }
                        
                    } label: {
                        
                        Text(speed)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: speed)
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .foregroundColor(.brandWhite)
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
                            Picker("Size", selection: $size) {
                                Text("MTT").tag("MTT")
                                Text("Sit & Go").tag("Sit & Go")
                            }
                        }
                        
                    } label: {
                        
                        Text(size)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: size)
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .foregroundColor(.brandWhite)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
            }
            
            gameTiming
            
        }
        .padding(.horizontal, 8)
        .onAppear {
            self.speed = pokerSession.tournamentSpeed.map { String($0) } ?? "Standard"
            self.size = pokerSession.tournamentSize.map { String($0) } ?? "MTT"
            self.startTime = pokerSession.startTime
            self.endTime = pokerSession.endTime
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
                    addLocationIsShowing = true
                } label: {
                    HStack {
                        Text("Add New Location")
                        Image(systemName: "mappin.and.ellipse")
                    }
                }
                                    
                Picker("Picker", selection: $location) {
                    ForEach(viewModel.locations) { location in
                        Text(location.name).tag(location)
                    }
                }
                
            } label: {
                
                Text(location.name)
                    .bodyStyle()
                    .lineLimit(1)
                    .fixedSize()
            }
            .animation(nil, value: location)
            .foregroundColor(.brandWhite)
            .buttonStyle(PlainButtonStyle())
            .transaction { transaction in
                transaction.animation = .none
            }
            
        }
        .onAppear {
            location = pokerSession.location
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
                
                Picker("Picker", selection: $stakes) {
                    ForEach(viewModel.userStakes, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                
            } label: {
                Text(stakes)
                    .bodyStyle()
                    .fixedSize()
            }
            .foregroundColor(.brandWhite)
            .buttonStyle(PlainButtonStyle())
            .transaction { transaction in
                transaction.animation = .none
            }
        }
        .onAppear {
            stakes = pokerSession.stakes
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .transition(.opacity.combined(with: .scale(scale: 1, anchor: .top)))
        .sheet(isPresented: $addStakesIsShowing, content: {
            NewStakesView(addStakesIsShowing: $addStakesIsShowing)
        })
        
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
                    Picker("Game", selection: $game) {
                        Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                        Text("Pot Limit Omaha").tag("Pot Limit Omaha")
                        Text("Seven Card Stud").tag("Seven Card Stud")
                        Text("Mixed").tag("Mixed")
                    }
                }
                
            } label: {
                
                Text(game)
                    .bodyStyle()
                    .fixedSize()
                    .lineLimit(1)
                    .animation(nil, value: game)
            }
            .foregroundColor(.brandWhite)
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            game = pokerSession.game
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
                
                DatePicker("Start", selection: $startTime, in: ...Date.now,
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
                
                DatePicker("End", selection: $endTime, in: startTime...Date.now,
                           displayedComponents: [.date, .hourAndMinute])
                .accentColor(.brandPrimary)
                .padding(.leading, 4)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(.compact)
            }
            .onAppear {
                startTime = pokerSession.startTime
                endTime = pokerSession.endTime
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
    }
    
    var cashInputFields: some View {
        
        VStack {
            
            HStack (alignment: .top) {
                
                // Buy In
                HStack {
                    Text(viewModel.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(buyIn.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Buy In", text: $buyIn)
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
                
                // Cash Out
                HStack {
                    Text(viewModel.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(cashOut.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Cash Out", text: $cashOut)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading, 0)
                .padding(.trailing)
                .padding(.bottom, 10)
            }
            
            HStack {
                
                HStack {
                    Text(viewModel.userCurrency.symbol)
                        .font(.callout)
                        .foregroundStyle(expenses.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Expenses (Meals, tips, etc.)", text: $expenses)
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
            
            TextEditor(text: $notes)
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
                                Text(notes.isEmpty ? "Notes (Optional)" : "")
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

                HStack {
                    Text(viewModel.userCurrency.symbol)
                        .font(.callout)
                        .foregroundStyle(highHandBonus.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("High Hand Bonus (Optional)", text: $highHandBonus)
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
            .padding(.horizontal)
            .padding(.bottom, 10)
            .overlay {
                if !subManager.isSubscribed {
                    HStack {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.bottom, 10)
                            .padding(.trailing, 40)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            self.buyIn = pokerSession.buyIn.map { String($0) } ?? ""
            self.cashOut = pokerSession.cashOut.map { String($0) } ?? ""
            self.expenses = pokerSession.expenses.map { String($0) } ?? ""
            self.highHandBonus = pokerSession.highHandBonus.map { String($0) } ?? ""
            self.notes = pokerSession.notes
            self.tags = pokerSession.tags?.joined(separator: ", ") ?? ""
        }
    }
    
    var tournamentInputFields: some View {
        
        VStack {
            
            HStack {
                Text(viewModel.userCurrency.symbol)
                    .font(.callout)
                    .foregroundColor(cashOut.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Total Winnings", text: $cashOut)
                    .font(.custom("Asap-Regular", size: 17))
                    .keyboardType(.numberPad)
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.leading, 16)
            .padding(.trailing)
            .padding(.bottom, 10)
            
            HStack {
                
                HStack {
                    Text(viewModel.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(buyIn.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("Buy In", text: $buyIn)
                        .font(.custom("Asap-Regular", size: 17))
                        .keyboardType(.numberPad)
                                        
                }
                .padding(18)
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.leading)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
                
              
                HStack {
                    Text("#")
                        .font(.callout)
                        .foregroundColor(rebuyCount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("Rebuy Ct.", text: $rebuyCount)
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
            
            HStack {
                
                Text("#")
                    .font(.callout)
                    .foregroundColor(entrants.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("No. of Entrants", text: $entrants)
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
                    .foregroundColor(finish.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Your Finish", text: $finish)
                    .font(.custom("Asap-Regular", size: 17))
                    .keyboardType(.numberPad)
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .transition(.opacity.combined(with: .scale))
  
            TextEditor(text: $notes)
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
                                Text(notes.isEmpty ? "Notes (Optional)" : "")
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
            .padding(.horizontal)
            .padding(.bottom, 10)
            .overlay {
                if !subManager.isSubscribed {
                    HStack {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(.bottom, 10)
                            .padding(.trailing, 40)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .onAppear {
            self.buyIn = pokerSession.buyIn.map { String($0) } ?? ""
            self.cashOut = pokerSession.cashOut.map { String($0) } ?? ""
            self.rebuyCount = pokerSession.rebuyCount.map { String($0) } ?? "0"
            self.entrants = pokerSession.entrants.map { String($0) } ?? ""
            self.finish = pokerSession.finish.map { String($0) } ?? ""
            self.notes = pokerSession.notes
            self.tags = pokerSession.tags?.joined(separator: ", ") ?? ""
        }
    }
    
    var errorScreen: some View {
        
        VStack (spacing: 20) {
            
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .fontWeight(.semibold)
                .foregroundStyle(Color.donutChartOrange)
            
            Text("This Session cannot be edited because it was created prior to Left Pocket v4.0. If you wish to make changes to this Session, you must log it again with the correct information, & then simply delete the old Session.")
                .bodyStyle()
            
            Spacer()
            
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
        .padding()
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                saveEditedSession()
                
            } label: {
                PrimaryButton(title: "Save Changes")
            }
            
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
        .padding(.bottom, 10)
    }
    
    // Check if the Session we're trying to edit is a cash game or tournament, and display relevant fields
    private func determineSessionType() {
        if let sessionType = pokerSession.isTournament {
            if sessionType == true {
                self.sessionType = .tournament
            } else {
                self.sessionType = .cash
            }
        } else {
            self.sessionType = .cash
        }
    }
    
    // We're just verifying that the pokerSession being edited as values that can be edited
    // Not able to edit OLD Left Pocket Sessions because we only calculated profit, didn't know the buy in or cash out amounts
    private func canEditCashSession() -> Bool {
        
        guard pokerSession.isTournament != true else {
            return false
        }
        
        guard pokerSession.buyIn != nil else {
            return false
        }
        
        guard pokerSession.cashOut != nil else {
            return false
        }
        
        return true
    }
    
    private func canEditTournamentSession() -> Bool {
        
        guard pokerSession.isTournament == true else {
            return false
        }
        
        guard pokerSession.buyIn != nil else {
            return false
        }
        
        guard pokerSession.cashOut != nil else {
            return false
        }
        
        return true
    }
    
    private var isValidForm: Bool {
        
        guard endTime > startTime else {
            alertItem = AlertContext.invalidEndTime
            return false
        }
        
        guard endTime.timeIntervalSince(startTime) > 60 else {
            alertItem = AlertContext.invalidDuration
            return false
        }
        
        if sessionType != .cash {
            
            guard !entrants.isEmpty else {
                alertItem = AlertContext.invalidEntrants
                return false
            }
            
            guard !finish.isEmpty else {
                alertItem = AlertContext.invalidFinish
                return false
            }
            
        }
        
        return true
    }
    
    private var tournamentRebuys: Int {
        
        guard !rebuyCount.isEmpty else { return 0 }
        
        let buyIn = Int(self.buyIn) ?? 0
        let numberOfRebuys = Int(rebuyCount) ?? 0
        
        return buyIn * numberOfRebuys
    }
    
    // Saves a duplicate of the pokerSession, then deletes the old one
    private func saveEditedSession() {
        
        var computedProfit: Int {
            (Int(cashOut) ?? 0) - Int(buyIn)!
        }
        
        if isValidForm {
            viewModel.addSession(location: location,
                                 game: game,
                                 stakes: stakes,
                                 date: startTime,
                                 profit: sessionType == .cash ? computedProfit - (Int(expenses) ?? 0) : (Int(cashOut) ?? 0) - (Int(buyIn) ?? 0) - tournamentRebuys,
                                 notes: notes,
                                 startTime: startTime,
                                 endTime: endTime,
                                 expenses: sessionType == .cash ? Int(self.expenses) ?? 0 : (Int(buyIn) ?? 0) + tournamentRebuys,
                                 isTournament: sessionType == .tournament,
                                 entrants: Int(entrants) ?? 0,
                                 finish: Int(finish) ?? 0,
                                 highHandBonus: Int(highHandBonus) ?? 0,
                                 buyIn: Int(buyIn) ?? 0,
                                 cashOut: Int(cashOut) ?? 0,
                                 rebuyCount: Int(rebuyCount) ?? 0,
                                 tournamentSize: size,
                                 tournamentSpeed: speed,
                                 tags: tags.isEmpty ? nil : [tags])
            
            viewModel.sessions.removeAll { session in
                session.id == pokerSession.id
            }
            
            dismiss()
        }
    }
}

#Preview {
    EditSession(pokerSession: MockData.sampleTournament)
        .environmentObject(SessionsListViewModel())
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}
