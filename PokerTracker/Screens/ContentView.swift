//
//  ContentView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI


struct ContentView: View {
    
    @State private var showMetricsAsSheet = false
    @State var activeSheet: Sheet?
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: 5) {
                
                HeaderView(activeSheet: $activeSheet)
                
                BankrollSnapshot()
                    .padding(.bottom)
                    .offset(x: 0, y: -10)
                
                if viewModel.sessions.isEmpty {
                    
                    EmptyState()
                        .padding(.top, 80)
                    
                } else {
                    
                    metricsCard
                    
                    recentSessionCard

                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $showMetricsAsSheet) {
                MetricsView()
            }
        }
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newSession: NewSessionView(isPresented: .init(get: {
                activeSheet == .newSession
            }, set: { isPresented in
                activeSheet = isPresented ? .newSession : nil
            }))
            case .recentSession: SessionDetailView(activeSheet: $activeSheet,
                                                   pokerSession: viewModel.sessions.first!)
            }
        }
    }
    
    var metricsCard: some View {
        
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            showMetricsAsSheet = true
        }, label: {
            MetricsCardView()
                .padding(.bottom)
        })
            .buttonStyle(PlainButtonStyle())
    }
    
    var recentSessionCard: some View {
        
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            activeSheet = .recentSession
        }, label: {
            RecentSessionCardView(pokerSession: viewModel.sessions.first!)
                
        })
        .padding(.bottom, 30)
        .buttonStyle(CardButtonStyle())
    }
}

struct CardButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                if configuration.isPressed {
                    Color.black.opacity(0.1).cornerRadius(20)
                } else {
                    Color.clear
                }
            }
    }
}

struct BankrollSnapshot: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var bankroll: String {
        return viewModel.tallyBankroll().asCurrency()
    }
    
    var lastSession: Int {
        return viewModel.sessions.first?.profit ?? 0
    }
    
    var body: some View {
        HStack {
            VStack {
                
                Text("BANKROLL")
                    .font(.caption)
                    .opacity(0.6)
                
                Text(bankroll)
                    .fontWeight(.thin)
                    .font(.system(size: 60, design: .rounded))
                    .padding(.bottom, 2)
                
                Text("LAST")
                    .font(.caption)
                    .opacity(0.6)
                
                HStack {
                    Text(lastSession.asCurrency())
                        .fontWeight(.light)
                        .font(.system(size: 24, design: .rounded))
                        .profitColor(total: lastSession)
                }
                .padding(.bottom, 20)
                
                Divider().frame(width: UIScreen.main.bounds.width * 0.6)
                    .padding(.bottom, 45)
            }
        }
    }
}

enum Sheet: String, Identifiable {
    
    case newSession, recentSession
    var id: String {
        rawValue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionsListViewModel())
    }
}
