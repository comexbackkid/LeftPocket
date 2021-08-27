//
//  SessionDetailView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI


struct SessionDetailViewModel {
    let pokerSession: PokerSession
    
    var dateInterval: String {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: pokerSession.startTime, to: pokerSession.endTime)
        let hours = diffComponents.hour ?? 0
        let minutes = diffComponents.minute ?? 0
        
        return "\(hours):\(minutes)"
    }
    
}

struct SessionDetailView: View {
    
    let viewModel: SessionDetailViewModel

    
    var body: some View {
        ScrollView (.vertical) {
            VStack(spacing: 4) {
                Image(viewModel.pokerSession.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom)
                Text(viewModel.pokerSession.location)
                    .font(.title)
                    .bold()
                
                Text("\(viewModel.pokerSession.date)")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
                
                Divider()
                    .frame(width: 180)
                
                HStack(spacing: 50) {
                    VStack {
                        Text("Duration")
                            .font(.headline)
                        Text(viewModel.dateInterval)
                        
                    }
                    VStack {
                        Text("Profit")
                            .font(.headline)
                        Text("$" + String(viewModel.pokerSession.profit))
                        
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
                    Text(viewModel.pokerSession.notes)
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
//        SessionDetailView(viewModel: SessionDetailViewModel(pokerSession: MockData.sampleSession))
        let viewModel = SessionDetailViewModel(pokerSession: PokerSession.faked(startTime: Date(), endTime: Date().adding(minutes: 360)))
        SessionDetailView(viewModel: viewModel)
    }
}
