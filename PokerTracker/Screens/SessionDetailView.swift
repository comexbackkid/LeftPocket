//
//  SessionDetailView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct SessionDetailView: View {
    
    var pokerSession: PokerSession
    @EnvironmentObject var sessionsListViewModel: SessionsListModel
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    let formatter = DateIntervalFormatter()
    
    
    var dateInterval: DateInterval {
        let di = DateInterval(start: pokerSession.startTime, end: pokerSession.endTime)
        return di
    }
    
    
//    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: <#T##Date#>, to: <#T##Date#>)
//    let hours = diffComponents.hour
//    let minutes = diffComponents.minute
//
    
    var intervalFormatter: DateIntervalFormatter {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    
    

    
    var body: some View {

        ScrollView (.vertical) {
            VStack(spacing: 4) {
                Image(pokerSession.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom)
                Text(pokerSession.location)
                    .font(.title)
                    .bold()
                
                Text("\(pokerSession.date)")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
                
                Divider()
                    .frame(width: 180)
                
                HStack(spacing: 50) {
                    VStack {
                        Text("Duration")
                            .font(.headline)
                        Text(intervalFormatter.string(from: pokerSession.startTime, to: pokerSession.endTime))
                        
                    }
                    VStack {
                        Text("Profit")
                            .font(.headline)
                        Text("$" + String(pokerSession.profit))
                        
                    }
                    VStack {
                        Text("Hourly")
                            .font(.headline)
                        Text("$14/hr")
                        
                    }
                    
                }.padding()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Notes")
                            .font(.headline)
                            .padding(.bottom, 5)
                            .padding(.top, 20)
                    }
                    Text(pokerSession.notes)
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
        }
        .ignoresSafeArea()
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetailView(pokerSession: MockData.sampleSession)
    }
}
