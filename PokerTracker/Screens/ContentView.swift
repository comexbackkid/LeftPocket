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
                        HeaderView(isPresented: $isPresented, activeSheet: $activeSheet)
                        
                        BankrollSnapshot()
                            .padding()
                        
                        MetricsCardView()
                            .padding(.bottom, 30)
                        
                        Button(action: {
                            activeSheet = .recentSession
                        }, label: {
                            RecentSessionCardView(pokerSession: MockData.sampleSession)
                                .padding(.bottom, 40)
                            
                        })
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                            .sheet(item: $activeSheet) { item in
                                switch item {
                                case .newSession: NewSessionView(isPresented: $isPresented)
                                case .recentSession: SessionDetailView(pokerSession: viewModel.sessions.last ?? MockData.sampleSession)
                                }
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
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter.string(from: NSNumber(value: viewModel.tallyBankroll())) ?? "0"
    }
    
    var lastSession: String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter.string(from: NSNumber(value: viewModel.sessions.last?.profit ?? 0)) ?? "0"
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
                
                HStack {
                    Text(lastSession)
                        .fontWeight(.bold)
                        .font(.system(size: 24, design: .rounded))
                }
                .foregroundColor(viewModel.sessions.last?.profit ?? 0 > 0 ?
                                    .green : .red)

                Text("Last Session")
                    .font(.caption)
                    .opacity(0.6)
                    .padding(.bottom, 50)
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
