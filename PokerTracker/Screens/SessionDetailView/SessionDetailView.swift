//
//  SessionDetailView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct SessionDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    let pokerSession: PokerSession

    var body: some View {
        
        ScrollView (.vertical) {
            VStack(spacing: 4) {
                GraphicHeaderView(image: pokerSession.location.imageURL,
                                  location: pokerSession.location.name,
                                  date: pokerSession.date)
                Divider()
                    .frame(width: 180)
                
                KeyMetrics(sessionDuration: pokerSession.dateInterval,
                           sessionProfit: pokerSession.profit,
                           sessionHourlyRate: pokerSession.hourlyRate)
                
                VStack(alignment: .leading) {
                    
                    Text("Notes")
                            .font(.headline)
                            .padding(.bottom, 5)
                            .padding(.top, 20)
                    
                    Text(pokerSession.notes)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = self.pokerSession.notes
                            }, label: {
                                Text("Copy to Clipboard")
                                Image(systemName: "doc.on.doc")
                            })
                        }
                        .padding(.bottom, 30)
                    
                    Text("Miscellaneous")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    MiscView(vm: SessionsListViewModel(), pokerSession: pokerSession)
                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    alignment: .topLeading
                )
                .padding()
                .padding(.bottom, 70)
                
                Spacer()
            }
         
//            .overlay(Button(action: {
//                presentationMode.wrappedValue.dismiss()
//            }, label: {
//                DismissButton()
//            }).padding(.trailing, 22).padding(.top, 40), alignment: .topTrailing)
        }
        .ignoresSafeArea()
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        SessionDetailView(pokerSession: MockData.sampleSession)
    }
}

struct GraphicHeaderView: View {
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    let image: String
    let location: String
    let date: Date
    
    var body: some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .padding(.bottom)
        Text(location)
            .font(.title)
            .bold()
        Text("\(dateFormatter.string(from: date))")
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.bottom, 40)
    }
}

struct KeyMetrics: View {
    
    let sessionDuration: String
    let sessionProfit: Int
    let sessionHourlyRate: Int
    
    var body: some View {
        HStack(spacing: 50) {
            VStack {
                Text("Duration")
                    .font(.headline)
                Text(sessionDuration)
                
            }
            VStack {
                Text("Profit")
                    .font(.headline)
                Text(sessionProfit.accountingStyle())
                    .modifier(AccountingView(total: sessionProfit))
                
            }
            VStack {
                Text("Hourly")
                    .font(.headline)
                Text(sessionHourlyRate.accountingStyle())
                    .modifier(AccountingView(total: sessionProfit))
            }
        }.padding()
    }
}

struct MiscView: View {
    
    @ObservedObject var vm: SessionsListViewModel
    
    let pokerSession: PokerSession
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    var body: some View {

        HStack {
            Text("Date")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(dateFormatter.string(from: pokerSession.date))")
                .font(.subheadline)
        }
        Divider()
        HStack {
            Text("Game")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(pokerSession.game)
                .font(.subheadline)
        }
        Divider()
        HStack {
            Text("Stakes")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(pokerSession.stakes)
                .font(.subheadline)
        }
        Divider()
        HStack {
            Text("Visits")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(vm.sessions.filter({$0.location.name == pokerSession.location.name}).count)")
                .font(.subheadline)
        }
    }
}
