//
//  NewSessionView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct NewSessionView: View {
    
    @Binding var isPresented: Bool
    @StateObject var newSession = NewSessionViewModel()
    @EnvironmentObject var vm: SessionsListViewModel
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Picker(selection: $newSession.sessionType, label: Text("Text")) {
                    Text("Cash").tag(Optional(NewSessionViewModel.SessionType.cash))
                    Text("Tournament").tag(Optional(NewSessionViewModel.SessionType.tournament))
                }
                .pickerStyle(SegmentedPickerStyle())
                .listRowBackground(Color(.clear))
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                locationSection
                
                if newSession.sessionType == .tournament {
                    
                    tournamentDetails
                    
                } else {
                    
                    cashDetails
                }
                
                sessionNotesSection
                
                saveButton
            }
            .navigationTitle("New Session")
            .alert(item: $newSession.alertItem) { alertItem in
                
                Alert(title: alertItem.title,
                      message: alertItem.message,
                      dismissButton: alertItem.dismissButton)
            }
        }
        .accentColor(.brandPrimary)
    }
    
    var locationSection: some View {
        
        Section(header: Text("Details"),
                footer: Text("Choose from the default list or add your own location from the Settings screen.")) {
            
            if #available(iOS 16.0, *) {
                
                Picker(selection: $newSession.location, label: Text("Location").frame(width: 75, alignment: .leading).lineLimit(1), content: {
                    
                    ForEach(vm.locations, id: \.self) { location in
                        Text(location.name).tag(location.name)
                    }
                })
                .pickerStyle(.menu)

            } else {
                
                Picker(selection: $newSession.location, label: Text("Location"), content: {
                    
                    ForEach(vm.locations, id: \.self) { location in
                        Text(location.name).tag(location.name)
                    }
                })
            }
        }
    }
    
    var cashDetails: some View {
        
        Section {
            
            if #available(iOS 16.0, *) {
                Picker(selection: $newSession.game, label: Text("Game").frame(width: 75, alignment: .leading).lineLimit(1), content: {
                    Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                    Text("Pot-Limit Omaha").tag("Pot-Limit Omaha")
                    Text("Seven Card Stud").tag("Seven Card Stud")
                    Text("Five Card Draw").tag("Five Card Draw")
                })
                .pickerStyle(.menu)
                
            } else {
                
                Picker(selection: $newSession.game, label: Text("Game"), content: {
                    Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                    Text("Pot-Limit Omaha").tag("Pot-Limit Omaha")
                    Text("Seven Card Stud").tag("Seven Card Stud")
                    Text("Five Card Draw").tag("Five Card Draw")
                })
            }
            
            if #available(iOS 16.0, *) {
                
                Picker(selection: $newSession.stakes, label: Text("Stakes").frame(width: 75, alignment: .leading).lineLimit(1), content: {
                    Text(".02/0.05").tag(".02/.05")
                    Text(".05/.10").tag(".05/.10")
                    Text(".25/.50").tag(".25/.50")
                    Text(".50/1").tag(".50/1")
                    Text("1/2").tag("1/2")
                    Text("1/3").tag("1/3")
                    Text("2/2").tag("2/2")
                    Text("2/5").tag("2/5")
                    Text("5/10").tag("5/10")
                })
                .pickerStyle(.menu)
                
            } else {
                
                Picker(selection: $newSession.stakes, label: Text("Stakes") , content: {
                    Text(".25/.50").tag(".25/.50")
                    Text(".50/1").tag(".50/1")
                    Text("1/2").tag("1/2")
                    Text("1/3").tag("1/3")
                    Text("2/2").tag("2/2")
                    Text("2/5").tag("2/5")
                    Text("5/10").tag("5/10")
                })
            }
            
            
            DatePicker("Start", selection: $newSession.startTime, in: ...Date.now,
                       displayedComponents: [.date, .hourAndMinute])
            
            DatePicker("End", selection: $newSession.endTime, in: ...Date.now,
                       displayedComponents: [.date, .hourAndMinute])
            HStack {
                Text("$")
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                TextField("Win / Loss", text: $newSession.profit)
                    .keyboardType(.numberPad)
                Picker(selection: $newSession.positiveNegative, label: Text(""), content: {
                    Text("+").tag("+")
                    Text("-").tag("-")
                })
                .pickerStyle(SegmentedPickerStyle())
            }
            
            HStack {
                Text("$")
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                TextField("Expenses", text: $newSession.expenses)
                    .keyboardType(.numberPad)
            }
        }
    }
    
    var tournamentDetails: some View {
        
        Section {
            
            if #available(iOS 16.0, *) {
                
                Picker(selection: $newSession.game, label: Text("Game").frame(width: 75, alignment: .leading).lineLimit(1), content: {
                    Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                })
                .pickerStyle(.menu)
                
            } else {
                Picker(selection: $newSession.game, label: Text("Game"), content: {
                    Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                })
            }
            
            TextField("No. of Entrants", text: $newSession.entrants)
                .keyboardType(.numberPad)
            
            DatePicker("Start", selection: $newSession.startTime, in: ...Date.now,
                       displayedComponents: [.date, .hourAndMinute])
            
            DatePicker("End", selection: $newSession.endTime, in: ...Date.now,
                       displayedComponents: [.date, .hourAndMinute])

            HStack {
                Text("$")
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                TextField("Total Buy-In", text: $newSession.expenses)
                    .keyboardType(.numberPad)
            }
            
            HStack {
                Text("$")
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                TextField("Winnings", text: $newSession.profit)
                    .keyboardType(.numberPad)
            }
        }
    }
    
    var sessionNotesSection: some View {
        Section(header: Text("Notes (Optional)")) {
            TextEditor(text: $newSession.notes)
                .frame(height: 100)
        }
    }
    
    var saveButton: some View {
        Section {
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                newSession.savedButtonPressed(viewModel: vm)
                isPresented = newSession.presentation ?? true
            }, label: {
                PrimaryButton(title: "Save Session")
            })
            .listRowBackground(Color(.clear))
        }
    }
}

struct NewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSessionView(isPresented: .constant(true)).environmentObject(SessionsListViewModel())
    }
}
