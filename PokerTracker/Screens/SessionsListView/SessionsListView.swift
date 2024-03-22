//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import RevenueCatUI

enum ViewStyle: String, CaseIterable {
    case standard, compact
}

struct SessionsListView: View {
    
    @AppStorage("viewStyle") var viewStyle: ViewStyle = .standard
    
    @State var activeSheet: Sheet?
    @State var isPresented = false
    @State var showPaywall = false
    @State var sessionFilter: SessionFilter = .all
    
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    
    enum SessionFilter: String, CaseIterable {
        case all, cash, tournaments
    }
    
    var viewStyles: String {
        switch viewStyle {
        case .compact: "Compact View"
        case .standard: "Standard View"
        }
    }
    var sessionsTitle: String {
        switch sessionFilter {
        case .all: "All Sessions"
        case .cash: "Cash Sessions"
        case .tournaments: "Tournaments"
        }
    }
    var filteredSessions: [PokerSession] {
        
        switch sessionFilter {
        case .all: return vm.sessions
        case .cash: return vm.sessions.filter({ $0.isTournament == nil || $0.isTournament == false  })
        case .tournaments: return vm.sessions.filter({ $0.isTournament == true })
        }
    }
    let filterTip = FilterSessionsTip()
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                if vm.sessions.isEmpty {
                    
                    emptyView
                    
                } else {
                    
                    if !filteredSessions.isEmpty {
                        
                        List {
                            
                            screenTitle
                            
                            // With Paywall offering, we're only prompting them to subscribe with the New Session Button
                            // They can still view all their Sessions if they were previously free users. They just can't add new Sessions
                            
                            ForEach(filteredSessions) { session in
                                NavigationLink(
                                    destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session),
                                    label: {
                                        CellView(pokerSession: session, viewStyle: $viewStyle)
                                    })
                                .listRowBackground(Color.brandBackground)
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            }
                            .onDelete(perform: { indexSet in
                                vm.sessions.remove(atOffsets: indexSet)
                            })
                        }
                        .listStyle(PlainListStyle())
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            toolbarItem
                                .onTapGesture {
                                    filterTip.invalidate(reason: .actionPerformed)
                                }
                                .popoverTip(filterTip)
                        }
                        
                    } else {
                        
                        VStack (alignment: .leading) {
                            
                            screenTitle
                            
                            Spacer()
                            EmptyState(image: .sessions)
                            Spacer()
                        }
                        .toolbar {
                            toolbarItem
                        }
                    }
                }
            }
            .padding(.bottom, 50)
            .accentColor(.brandPrimary)
            .background(Color.brandBackground)
        }
        .accentColor(.brandPrimary)
    }
    
    var toolbarItem: some View {
        
        Menu {
            Picker("", selection: $sessionFilter) {
                ForEach(SessionFilter.allCases, id: \.self) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            
            Divider()
            
            Picker("", selection: $viewStyle) {
                ForEach(ViewStyle.allCases, id: \.self) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
    }
    
    var emptyView: some View {
        
        VStack {
            Spacer()
            EmptyState(image: .sessions)
            Spacer()
        }
    }
    
    var screenTitle: some View {
        
        Text(sessionsTitle)
            .titleStyle()
            .padding(.top, -38)
            .padding(.horizontal)
            .listRowBackground(Color.brandBackground)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsListView()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
    }
}
