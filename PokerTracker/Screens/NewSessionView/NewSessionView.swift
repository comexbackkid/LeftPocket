//
//  NewSessionView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct NewSessionView: View {
    
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionsListViewModel: SessionsListViewModel
    @StateObject var viewModel = NewSessionViewModel()

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
                        })
                        
                        Picker(selection: $viewModel.stakes, label: Text("Stakes") , content: {
                            Text("1/2").tag("1/2")
                            Text("1/3").tag("1/3")
                            Text("2/5").tag("2/5")
                            Text("5/10").tag("5/10")
                        })
                        
                        DatePicker("Date", selection: $viewModel.date, in: ...Date(),
                                   displayedComponents: .date)
                        
                        DatePicker("Start time", selection: $viewModel.startTime,
                                   displayedComponents: .hourAndMinute)
                            
                        DatePicker("End time", selection: $viewModel.endTime,
                                   displayedComponents: .hourAndMinute)
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
                            saveButtonPressed()
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Save Session")
                        })
                    }
                }
                .navigationTitle("New Session")
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }
    }
    
    // This needs to go into the NewSessionViewModel
    func saveButtonPressed() {
        guard viewModel.isValidForm else {return}
        sessionsListViewModel.addSession(location: viewModel.location,
                                         game: viewModel.game,
                                         stakes: viewModel.stakes,
                                         date: viewModel.date,
                                         profit: Int(viewModel.positiveNegative + viewModel.profit) ?? 0,
                                         notes: viewModel.notes,
                                         startTime: viewModel.startTime,
                                         endTime: viewModel.endTime)
    }
}

struct NewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSessionView(isPresented: .constant(true)).environmentObject(SessionsListViewModel())
    }
}
