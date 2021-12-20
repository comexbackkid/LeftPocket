//
//  NewSessionView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct NewSessionView: View {
    
    @Binding var isPresented: Bool
    @StateObject var viewModel = NewSessionViewModel()
    @EnvironmentObject var sessionsListViewModel: SessionsListViewModel

    var body: some View {
        
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Details")) {
                        
                        Picker(selection: $viewModel.location, label: Text("Location"), content: {
                            
                            ForEach(sessionsListViewModel.locations, id: \.self) { location in
                                Text(location.name).tag(location.name)
                            }
                        })
                        
                        Picker(selection: $viewModel.game, label: Text("Game"), content: {
                            Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                            Text("Pot-Limit Omaha").tag("Pot-Limit Omaha")
                            Text("Seven Card Stud").tag("Seven Card Stud")
                            Text("Five Card Draw").tag("Five Card Draw")
                            Text("Razz").tag("Razz")
                        })
                        
                        Picker(selection: $viewModel.stakes, label: Text("Stakes") , content: {
                            Text(".25/.50").tag(".25/.50")
                            Text(".50/1").tag(".50/1")
                            Text("1/2").tag("1/2")
                            Text("1/3").tag("1/3")
                            Text("2/5").tag("2/5")
                            Text("5/10").tag("5/10")
                        })
                        
                        DatePicker("Start", selection: $viewModel.startTime,
                                   displayedComponents: [. date, .hourAndMinute])
                            
                        DatePicker("End", selection: $viewModel.endTime,
                                   displayedComponents: [. date, .hourAndMinute])
                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                                .opacity(0.8)
                            TextField("Profit", text: $viewModel.profit)
                                .keyboardType(.numberPad)
                            Picker(selection: $viewModel.positiveNegative, label: Text(""), content: {
                                Text("+").tag("+")
                                Text("-").tag("-")
                            })
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
      
                    Section(header: Text("Hand Notes (Optional)")) {
                        TextEditor(text: $viewModel.notes)
                            .frame(height: 120)
                    }
                    Section {
                        Button(action: {
                            viewModel.savedButtonPressed(viewModel: sessionsListViewModel)
                            isPresented = viewModel.presentation ?? true
                        }, label: {
                            Text("Save Session")
                        })
                    }
                }
                .navigationTitle("New Session")
                .alert(item: $viewModel.alertItem) { alertItem in
                    
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
