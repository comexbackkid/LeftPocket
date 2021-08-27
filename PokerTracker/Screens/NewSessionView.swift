//
//  NewSessionView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct NewSessionView: View {
    
    @Binding var isPresented: Bool
    @EnvironmentObject var sessionsListViewModel: SessionsListModel
    
    @State var location: String = ""
    @State var game: String = ""
    @State var stakes: String = ""
    @State var profit: String = ""
    @State var notes: String = ""
    @State var date = Date()
    @State var startTime: Date = Date()
    @State var endTime: Date = Date()
    var imageName = "encore-header"
    
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Form {
                    Section(header: Text("Details")) {
                        
                        Picker(selection: $location, label: Text("Location"), content: {
                            Text("Chaser's Poker Room").tag("Chaser's Poker Room")
                            Text("Boston Billiards Club").tag("Boston Billiards Club")
                            Text("Encore Boston Harbor").tag("Encore Boston Harbor")
                            Text("Poker Bro's").tag("Poker Bro's")
                            Text("Club GG").tag("Club GG")
                        })
                        
                        Picker(selection: $game, label: Text("Game"), content: {
                            Text("NL Texas Hold Em").tag("NL Texas Hold Em")
                            Text("Pot-Limit Omaha").tag("Pot-Limit Omaha")
                        })
                        
                        Picker(selection: $stakes, label: Text("Stakes") , content: {
                            Text("1/2").tag("1/2")
                            Text("1/3").tag("1/3")
                            Text("2/5").tag("2/5")
                            Text("5/10").tag("5/10")
                        })
                        
                        DatePicker("Date", selection: $date,
                                   displayedComponents: .date)
                        DatePicker("Start time", selection: $startTime,
                                   displayedComponents: .hourAndMinute)
                            
                        DatePicker("End time", selection: $endTime,
                                   displayedComponents: .hourAndMinute)
                     
                        
                        TextField("Profit", text: $profit)
                            .keyboardType(.numberPad)
                    }
                    Section(header: Text("Hand Notes")) {
                        TextEditor(text: $notes)
                    }
                }
                VStack {
                    Spacer()
                    Button(action: {
                        saveButtonPressed()
                        isPresented = false
                    }, label: {
                        Text("Save")
                            .font(.title3)
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .background(Color("brandPrimary"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                            
                    })
                }
                .navigationTitle("New Session")
            }
        }
    }
    
    
    
    func saveButtonPressed() {
        
        sessionsListViewModel.addSession(location: location,
                                         game: game,
                                         stakes: stakes,
                                         date: dateFormatter.string(from: self.date),
                                         profit: profit,
                                         notes: notes,
                                         imageName: imageName,
                                         startTime: startTime,
                                         endTime: endTime)
    }
}

struct NewSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NewSessionView(isPresented: .constant(true)).environmentObject(SessionsListModel())
    }
}
