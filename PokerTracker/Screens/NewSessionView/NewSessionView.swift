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
    @EnvironmentObject var viewModel: SessionsListViewModel

    var body: some View {
        
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Details"),
                            footer: Text("Choose from the default list or add your own location from the Settings screen.")) {
                        
                        Picker(selection: $newSession.location, label: Text("Location"), content: {
                            
                            ForEach(viewModel.locations, id: \.self) { location in
                                Text(location.name).tag(location.name)
                            }
                        })
                    }
                    
                    Section {
                        Picker(selection: $newSession.game, label: Text("Game"), content: {
                            Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                            Text("Pot-Limit Omaha").tag("Pot-Limit Omaha")
                            Text("Seven Card Stud").tag("Seven Card Stud")
                            Text("Five Card Draw").tag("Five Card Draw")
                        })
                        
                        Picker(selection: $newSession.stakes, label: Text("Stakes") , content: {
                            Text(".25/.50").tag(".25/.50")
                            Text(".50/1").tag(".50/1")
                            Text("1/2").tag("1/2")
                            Text("1/3").tag("1/3")
                            Text("2/2").tag("2/2")
                            Text("2/5").tag("2/5")
                            Text("5/10").tag("5/10")
                        })
                        
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
      
                    Section(header: Text("Session Notes (Optional)")) {
                        TextEditor(text: $newSession.notes)
                            .frame(height: 100)
                    }
                    Section {
                        Button(action: {
                            newSession.savedButtonPressed(viewModel: viewModel)
                            isPresented = newSession.presentation ?? true
                        }, label: {
                            Text("Save Session")
                        })
                    }
                }
                .navigationTitle("New Session")
                .alert(item: $newSession.alertItem) { alertItem in
                    
                    Alert(title: alertItem.title,
                          message: alertItem.message,
                          dismissButton: alertItem.dismissButton)
                }
            }
        }
        .accentColor(.brandPrimary)
    }
}

struct NewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSessionView(isPresented: .constant(true)).environmentObject(SessionsListViewModel())
    }
}
