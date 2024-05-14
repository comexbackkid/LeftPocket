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
                    
                    emptyState
                    
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
            case .productUpdates: ProductUpdates(activeSheet: $activeSheet)
            case .recentSession: SessionDetailView(activeSheet: $activeSheet, pokerSession: viewModel.sessions.first!)
            }
        }
    }
    
    var bankroll: Int {
        return viewModel.tallyBankroll(bankroll: .all)
    }
    
    var emptyState: some View {
        
        VStack (spacing: 5) {
            
            Image("pokerchipsvector-transparent")
                .resizable()
                .frame(width: 125, height: 125)
            
            Text("No Sessions")
                .cardTitleStyle()
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Tap & hold the Plus button below.\n During a live session, add rebuys by\npressing the \(Image(systemName: "dollarsign.arrow.circlepath")) button.")
                .foregroundColor(.secondary)
                .subHeadlineStyle()
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            
            Image("squigleArrow")
                .resizable()
                .frame(width: 80, height: 150)
                .padding(.top, 20)
        }
        
    }
    
    var lastSession: Int {
        return viewModel.sessions.first?.profit ?? 0
    }
    
    var productUpdatesIcon: some View {
        
        HStack {
            Button {
                activeSheet = .productUpdates
            } label: {
                Image(systemName: "bell.fill")
                    .opacity(0.75)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.bottom, -20)
    }
    
    var quickMetrics: some View {
        
        HStack (spacing: 18) {
            
            VStack (spacing: 3) {
                Text(String(viewModel.sessions.count))
                    .font(.system(size: 20, design: .rounded))
                    .opacity(0.75)
                
                Text(viewModel.sessions.count == 1 ? "Session" : "Sessions")
                    .captionStyle()
                    .fontWeight(.thin)
            }
            
            Divider()
            
            VStack (spacing: 3) {
                Text(String(viewModel.totalWinRate()))
                    .font(.system(size: 20, design: .rounded))
                    .opacity(0.75)
                
                Text("Win Ratio")
                    .captionStyle()
                    .fontWeight(.thin)
            }
            
            Divider()
            
            VStack (spacing: 3) {
                Text(viewModel.totalHoursPlayedHomeScreen())
                    .font(.system(size: 20, design: .rounded))
                    .opacity(0.75)
                
                Text("Hours")
                    .captionStyle()
                    .fontWeight(.thin)
            }
        }
        .padding(20)
        .frame(width: UIScreen.main.bounds.width * 0.85)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .padding(.bottom, 25)
        
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
                
                Text("My Bankroll")
                    .font(.custom("Asap-Regular", size: 13))
                    .opacity(0.5)
                
                Text(bankroll, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .font(.system(size: 55, design: .rounded))
                    .fontWeight(.medium)
                    .opacity(0.75)
                
                if !viewModel.sessions.isEmpty {
                    
                    HStack {
                        
                        Image(systemName: "arrow.up.right")
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundColor(lastSession > 0 ? .green : lastSession < 0 ? .red : Color(.systemGray))
                            .rotationEffect(lastSession >= 0 ? .degrees(0) : .degrees(90))
                        
                        Text(lastSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                            .fontWeight(.light)
                            .font(.system(size: 20, design: .rounded))
                            .profitColor(total: lastSession)
                        
                    }
                    .padding(.top, -36)
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
    
    case productUpdates, recentSession
    
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
