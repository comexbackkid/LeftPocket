//
//  ContentView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isPresented = false
    @EnvironmentObject var sessionsListViewModel: SessionsListModel
    
    var body: some View {
        //        Color("brandWhite")
        LinearGradient(gradient: Gradient(colors: [Color("brandWhite"), Color("bgGray")]), startPoint: .top, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(
                ScrollView(.vertical) {
                    VStack(spacing: 5) {
                        HeaderView(isPresented: $isPresented)
                        HStack {
                            VStack {
                                Text("Bankroll")
                                    .font(.caption)
                                    .opacity(0.6)
                                
                                Text("$" + "\(sessionsListViewModel.tallyBankroll())")
                                    .fontWeight(.black)
                                    .font(.system(size: 46, design: .rounded))
                                    .foregroundColor(Color("brandBlack"))
                                    .padding(.bottom, 4)
                                
                                HStack {
                                    Image(systemName: "arrow.up")
                                    Text(sessionsListViewModel.sessions.last.profit)
                                        .fontWeight(.bold)
                                        .font(.system(size: 24, design: .rounded))
                                }
                                .foregroundColor(.green)
                                
                                Text("Last Session")
                                    .font(.caption)
                                    .opacity(0.6)
                                    .padding(.bottom, 50)
                            }
                        }
                        .padding()
                        
                        MetricsCardView()
                            .padding(.bottom, 50)
                        
                        RecentSessionCardView(pokerSession: MockData.sampleSession)
                            .padding(.bottom, 50)
                        Spacer()
                            .sheet(isPresented: $isPresented, content: {
                                NewSessionView(isPresented: $isPresented)
                            })
                    }
                }
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionsListModel())
    }
}



