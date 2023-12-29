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
    
    var bankroll: String {
        return viewModel.tallyBankroll().asCurrency()
    }

    var lastSession: Int {
        return viewModel.sessions.first?.profit ?? 0
    }
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: 5) {
                
                bankrollView
                
                if viewModel.sessions.isEmpty {
                    
                    EmptyState(image: .sessions)
                        .padding(.top, 50)
                    
                } else {
                    
                    metricsCard
                    
                    recentSessionCard

                    Spacer()
                }
            }
            .padding(.bottom, 50)
            .fullScreenCover(isPresented: $showMetricsAsSheet) {
                MetricsView()
            }
        }
        .background(Color.brandBackground)
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
            .padding(.bottom, 12)
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
        .buttonStyle(CardViewButtonStyle())
    }
    
    var bankrollView: some View {
        
        HStack {
            
            VStack {
                
                Text("BANKROLL")
                    .font(.caption)
                    .opacity(0.6)
                
                Text(bankroll)
                    .fontWeight(.thin)
                    .font(.system(size: 60, design: .rounded))
                    .padding(.bottom, 2)
                    .opacity(0.8)
                
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
                    .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

enum Sheet: String, Identifiable {
    
    case newSession, recentSession
    var id: String {
        rawValue
    }
}

struct CardViewButtonStyle: ButtonStyle {
    
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionsListViewModel())
    }
}
