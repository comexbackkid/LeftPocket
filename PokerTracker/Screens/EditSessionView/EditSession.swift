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
    @StateObject var editSession = EditSessionViewModel()
    
    let pokerSession: PokerSession_v2
    
    var body: some View {
        
        VStack {
            
            ScrollView(.vertical) {
                
                VStack {
                    
                    title
                    
                    Spacer()
                    
                    switch editSession.sessionType {
                    case .cash:
                        cashGameDetails
                        cashInputFields
                        saveButton
                        
                    case .tournament:
                        tournamentGameDetails
                        tournamentInputFields
                        saveButton
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .frame(maxHeight: .infinity)
        .background(Color.brandBackground)
        .alert(item: $editSession.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
        .onAppear {
            determineSessionType()
            editSession.date = pokerSession.date
            editSession.startTime = pokerSession.startTime
            editSession.endTime = pokerSession.endTime
            if let startTimeDayTwo = pokerSession.startTimeDayTwo {
                editSession.startTimeDayTwo = startTimeDayTwo
            }
            if let endTimeDayTwo = pokerSession.endTimeDayTwo {
                editSession.endTimeDayTwo = endTimeDayTwo
            }
        }
    }
    
    // Check if the Session we're trying to edit is a cash game or tournament, and display relevant fields
    private func determineSessionType() {
        switch pokerSession.isTournament {
        case true: editSession.sessionType = .tournament
        case false: editSession.sessionType = .cash
        }
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
                            Picker("Speed", selection: $editSession.speed) {
                                Text("Standard").tag("Standard")
                                Text("Turbo").tag("Turbo")
                                Text("Super Turbo").tag("Super Turbo")
                            }
                        }
                        
                    } label: {
                        
                        Text(editSession.speed)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: editSession.speed)
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
                            Picker("Size", selection: $editSession.size) {
                                Text("MTT").tag("MTT")
                                Text("Sit & Go").tag("Sit & Go")
                            }
                        }
                        
                    } label: {
                        
                        Text(editSession.size)
                            .bodyStyle()
                            .fixedSize()
                            .lineLimit(1)
                            .animation(nil, value: editSession.size)
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
            editSession.speed = pokerSession.tournamentSpeed.map { String($0) } ?? "Standard"
            editSession.size = pokerSession.tournamentSize.map { String($0) } ?? "MTT"
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
                    editSession.addLocationIsShowing = true
                } label: {
                    HStack {
                        Text("Add New Location")
                        Image(systemName: "mappin.and.ellipse")
                    }
                }
                                    
                Picker("Picker", selection: $editSession.location) {
                    ForEach(viewModel.locations) { location in
                        Text(location.name).tag(location)
                    }
                }
                
            } label: {
                
                Text(editSession.location.name)
                    .bodyStyle()
                    .lineLimit(1)
                    .fixedSize()
            }
            .animation(nil, value: editSession.location)
            .foregroundColor(.brandWhite)
            .buttonStyle(PlainButtonStyle())
            .transaction { transaction in
                transaction.animation = .none
            }
            
        }
        .onAppear {
            editSession.location = pokerSession.location
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .sheet(isPresented: $editSession.addLocationIsShowing, content: {
            NewLocationView(addLocationIsShowing: $editSession.addLocationIsShowing)
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
                    editSession.addStakesIsShowing = true
                } label: {
                    HStack {
                        Text("Add Stakes")
                        Image(systemName: "dollarsign.circle")
                    }
                }
                
                Picker("Picker", selection: $editSession.stakes) {
                    ForEach(viewModel.userStakes, id: \.self) {
                        Text($0).tag($0)
                    }
                }
                
            } label: {
                Text(editSession.stakes)
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
            editSession.stakes = pokerSession.stakes
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .transition(.opacity.combined(with: .scale(scale: 1, anchor: .top)))
        .sheet(isPresented: $editSession.addStakesIsShowing, content: {
            NewStakesView(addStakesIsShowing: $editSession.addStakesIsShowing)
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
                    Picker("Game", selection: $editSession.game) {
                        Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                        Text("Pot Limit Omaha").tag("Pot Limit Omaha")
                        Text("Seven Card Stud").tag("Seven Card Stud")
                        Text("Mixed").tag("Mixed")
                    }
                }
                
            } label: {
                
                Text(editSession.game)
                    .bodyStyle()
                    .fixedSize()
                    .lineLimit(1)
                    .animation(nil, value: editSession.game)
            }
            .foregroundColor(.brandWhite)
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            editSession.game = pokerSession.game
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    var gameTiming: some View {
        
        VStack {
            
            if let tournamentDays = pokerSession.tournamentDays, tournamentDays > 1 {
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
            }
            
            HStack {
                
                Image(systemName: "clock")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("Start", selection: $editSession.startTime, in: ...Date.now,
                           displayedComponents: [.date, .hourAndMinute])
                .accentColor(.brandPrimary)
                .padding(.leading, 4)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(.compact)
                
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .opacity(pokerSession.tournamentDays ?? 0 > 1 ? 0.4 : 1)
            .disabled(pokerSession.tournamentDays ?? 0 > 1 ? true : false)
            
            HStack {
                
                Image(systemName: "hourglass.tophalf.filled")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("End", selection: $editSession.endTime, in: editSession.startTime...Date.now,
                           displayedComponents: [.date, .hourAndMinute])
                .accentColor(.brandPrimary)
                .padding(.leading, 4)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(.compact)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            .opacity(pokerSession.tournamentDays ?? 0 > 1 ? 0.4 : 1)
            .disabled(pokerSession.tournamentDays ?? 0 > 1 ? true : false)
            
            if pokerSession.tournamentDays ?? 0 > 1 {
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
                .disabled(true)
                
                HStack {
                    
                    Image(systemName: "clock")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                        .frame(width: 30)
                    
                    DatePicker("Start", selection: $editSession.startTimeDayTwo, in: ...Date.now,
                               displayedComponents: [.date, .hourAndMinute])
                    .accentColor(.brandPrimary)
                    .padding(.leading, 4)
                    .font(.custom("Asap-Regular", size: 18))
                    .datePickerStyle(.compact)
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .opacity(pokerSession.tournamentDays ?? 0 > 1 ? 0.4 : 1)
                .disabled(true)
                
                HStack {
                    
                    Image(systemName: "hourglass.tophalf.filled")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                        .frame(width: 30)
                    
                    DatePicker("End", selection: $editSession.endTimeDayTwo, in: editSession.startTimeDayTwo...Date.now,
                               displayedComponents: [.date, .hourAndMinute])
                    .accentColor(.brandPrimary)
                    .padding(.leading, 4)
                    .font(.custom("Asap-Regular", size: 18))
                    .datePickerStyle(.compact)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                .opacity(pokerSession.tournamentDays ?? 0 > 1 ? 0.4 : 1)
                .disabled(true)
            }
        }
    }
    
    var cashInputFields: some View {
        
        VStack {
            
            HStack (alignment: .top) {
                
                // Buy In
                HStack {
                    Text(viewModel.userCurrency.symbol)
                        .font(.callout)
                        .foregroundColor(editSession.buyIn.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Buy In", text: $editSession.buyIn)
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
                        .foregroundColor(editSession.cashOut.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Cash Out", text: $editSession.cashOut)
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
                        .foregroundStyle(editSession.expenses.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("Expenses (Meals, tips, etc.)", text: $editSession.expenses)
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
            
            TextEditor(text: $editSession.notes)
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
                                Text(editSession.notes.isEmpty ? "Notes (Optional)" : "")
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
                        .foregroundStyle(editSession.highHandBonus.isEmpty ? .secondary.opacity(0.5) : Color.brandWhite)
                    
                    TextField("High Hand Bonus (Optional)", text: $editSession.highHandBonus)
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
                    .foregroundColor(editSession.tags.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Tags (Optional)", text: $editSession.tags)
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
            editSession.buyIn = String(pokerSession.buyIn)
            editSession.cashOut = String(pokerSession.cashOut)
            editSession.expenses = String(pokerSession.expenses)
            editSession.highHandBonus = String(pokerSession.highHandBonus)
            editSession.notes = pokerSession.notes
            editSession.tags = pokerSession.tags.joined(separator: ", ")
        }
    }
    
    var tournamentInputFields: some View {
        
        VStack {
            
            HStack {
                Text(viewModel.userCurrency.symbol)
                    .font(.callout)
                    .foregroundColor(editSession.cashOut.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Total Winnings", text: $editSession.cashOut)
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
                        .foregroundColor(editSession.buyIn.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("Buy In", text: $editSession.buyIn)
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
                        .foregroundColor(editSession.rebuyCount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                    
                    TextField("Rebuy Ct.", text: $editSession.rebuyCount)
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
                    .foregroundColor(editSession.entrants.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("No. of Entrants", text: $editSession.entrants)
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
                    .foregroundColor(editSession.finish.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Your Finish", text: $editSession.finish)
                    .font(.custom("Asap-Regular", size: 17))
                    .keyboardType(.numberPad)
            }
            .padding(18)
            .background(.gray.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .transition(.opacity.combined(with: .scale))
  
            TextEditor(text: $editSession.notes)
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
                                Text(editSession.notes.isEmpty ? "Notes (Optional)" : "")
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
                    .foregroundColor(editSession.tags.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
                
                TextField("Tags (Optional)", text: $editSession.tags)
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
            editSession.buyIn = String(pokerSession.buyIn)
            editSession.cashOut = String(pokerSession.cashOut)
            editSession.rebuyCount = pokerSession.rebuyCount.map { String($0) } ?? "0"
            editSession.entrants = pokerSession.entrants.map { String($0) } ?? ""
            editSession.finish = pokerSession.finish.map { String($0) } ?? ""
            editSession.notes = pokerSession.notes
            editSession.tags = pokerSession.tags.joined(separator: ", ")
            editSession.tournamentDays = pokerSession.tournamentDays.map { String($0) } ?? "1"
        }
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                if editSession.isValidForm {
                    editSession.saveEditedSession(viewModel: viewModel, editedSession: pokerSession)
                    viewModel.sessions.removeAll { session in
                        session.id == pokerSession.id
                    }
                    dismiss()
                }
                
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
}

#Preview {
    EditSession(pokerSession: MockData.sampleTournament)
        .environmentObject(SessionsListViewModel())
        .environmentObject(SubscriptionManager())
        .preferredColorScheme(.dark)
}
