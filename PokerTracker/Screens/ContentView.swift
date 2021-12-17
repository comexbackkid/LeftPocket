//
//  ContentView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isPresented = false
    @State var activeSheet: ActiveSheet?
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        BackgroundView()
            .overlay(
                ScrollView(.vertical) {
                    VStack(spacing: 5) {
                        HeaderView(activeSheet: $activeSheet)
                            .sheet(item: $activeSheet) { item in
                                switch item {
                                case .newSession: NewSessionView(isPresented: $isPresented)
                                case .recentSession: SessionDetailView(pokerSession: viewModel.sessions.first ?? MockData.sampleSession)
                                }
                            }
                        
                        BankrollSnapshot()
                            .padding(.bottom)
                            .offset(x: 0, y: -10)
                        
                        if viewModel.sessions.isEmpty {
                            
                            EmptyState()
                                .padding(.top, 80)
                            
                        } else {
                        
                        MetricsCardView()
                            .padding(.bottom)
                        
                        Button(action: {
                            activeSheet = .recentSession
                        }, label: {
                            RecentSessionCardView(pokerSession: viewModel.sessions.first ?? MockData.sampleSession)
                                .padding(.bottom, 30)
                            
                        })
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()

                        }
                    }
                }
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionsListViewModel())
    }
}


struct BackgroundView: View {
    
    var body: some View {
        
        LinearGradient(gradient: Gradient(colors: [Color("brandWhite"), Color("bgGray")]),
                       startPoint: .top,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct BankrollSnapshot: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var bankroll: String {
        return viewModel.tallyBankroll().accountingStyle()
    }
    
    var lastSession: Int {
        return viewModel.sessions.first?.profit ?? 0
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Bankroll")
                    .font(.caption)
                    .opacity(0.6)
                
                Text(bankroll)
                    .fontWeight(.black)
                    .font(.system(size: 46, design: .rounded))
                    .foregroundColor(Color("brandBlack"))
                    .padding(.bottom, 4)
                Text("Last Session")
                    .font(.caption)
                    .opacity(0.6)
                    
                HStack {
                    Text("\(lastSession.accountingStyle())")
                        .fontWeight(.bold)
                        .font(.system(size: 24, design: .rounded))
                        .modifier(AccountingView(total: lastSession))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// Sheet switcher
enum ActiveSheet: Identifiable {
    case newSession, recentSession
    
    var id: Int {
        hashValue
    }
}
