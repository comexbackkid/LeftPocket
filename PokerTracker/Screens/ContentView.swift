//
//  ContentView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showMetricsAsSheet = false
    @State var activeSheet: Sheet?
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: 5) {
                
                bankrollView
                
                if viewModel.sessions.isEmpty {
                    
                    EmptyState(image: .sessions)
                        .padding(.top, 85)
                    
                } else {
                    
                    quickMetrics
                    
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
        .background { homeBackground.ignoresSafeArea() }
        .sheet(item: $activeSheet) { sheet in
            
            switch sheet {
            case .newSession: AddNewSessionView(isPresented: .init(get: {
                activeSheet == .newSession
            }, set: { isPresented in
                activeSheet = isPresented ? .newSession : nil
            }))
            case .recentSession: SessionDetailView(activeSheet: $activeSheet,
                                                   pokerSession: viewModel.sessions.first!)
            }
        }
    }
    
    var bankroll: String {
        return viewModel.tallyBankroll(bankroll: .all).asCurrency()
    }
    
    var lastSession: Int {
        return viewModel.sessions.first?.profit ?? 0
    }
    
    var quickMetrics: some View {
        
        HStack (spacing: 18) {
            
            VStack (spacing: 3) {
                Text(String(viewModel.sessions.count))
                    .font(.system(size: 22, design: .rounded))
                    .opacity(0.75)
                
                Text(viewModel.sessions.count == 1 ? "Session" : "Sessions")
                    .captionStyle()
                    .fontWeight(.thin)
            }
            
            Divider()
            
            VStack (spacing: 3) {
                Text(String(viewModel.totalWinRate()))
                    .font(.system(size: 22, design: .rounded))
                    .opacity(0.75)
                
                Text("Win Rate")
                    .captionStyle()
                    .fontWeight(.thin)
            }
            
            Divider()
            
            VStack (spacing: 3) {
                Text(viewModel.totalHoursPlayedHomeScreen())
                    .font(.system(size: 22, design: .rounded))
                    .opacity(0.75)
                
                Text("Hours")
                    .captionStyle()
                    .fontWeight(.thin)
            }
        }
        .padding(.bottom, 30)
        
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
        .zIndex(1.0)
    }
    
    var recentSessionCard: some View {
        
        Button(action: {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            activeSheet = .recentSession
            
        }, label: {
            
            RecentSessionCardView(pokerSession: viewModel.sessions.first!)
        })
        .buttonStyle(CardViewButtonStyle())
        .padding(.bottom, 30)
    }
    
    var bankrollView: some View {
        
        HStack {
            
            VStack {
                
                Text("BANKROLL")
                    .font(.custom("Asap-Regular", size: 13))
                    .opacity(0.5)
                
                Text(bankroll)
                    .font(.system(size: 60, design: .rounded))
                    .opacity(0.75)
                
                if !viewModel.sessions.isEmpty {
                    
                    HStack {
                        
                        Image(systemName: "arrowtriangle.up.fill")
                            .resizable()
                            .frame(width: 11, height: 11)
                            .foregroundColor(lastSession > 0 ? .green : lastSession < 0 ? .red : Color(.systemGray))
                            .rotationEffect(lastSession >= 0 ? .degrees(0) : .degrees(180))
                        
                        Text(lastSession.asCurrency())
                            .fontWeight(.light)
                            .font(.system(size: 20, design: .rounded))
                            .profitColor(total: lastSession)
                        
                    }
                    .padding(.top, -40)
                    
                }
                

            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.bottom, 20)
    }
    
    var homeBackground: some View {
        
        RadialGradient(colors: [.brandBackground, Color("newWhite").opacity(0.3)],
                       center: .topLeading,
                       startRadius: 500,
                       endRadius: 5)
        
    }
}

enum Sheet: String, Identifiable {
    
    case newSession, recentSession
    var id: String {
        rawValue
    }
}

struct CardViewButtonStyle: ButtonStyle {
    
    // This just removes some weird button styling from our custom card view that couldn't otherwise be made
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
            .preferredColorScheme(.dark)
    }
}
