//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import RevenueCatUI

struct SessionsListView: View {
    
    enum SessionFilter: String, CaseIterable {
        case all, cash, tournament
    }
    
    @State var activeSheet: Sheet?
    @State var isPresented = false
    @State var showPaywall = false
    @State var sessionFilter: SessionFilter = .all
    
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    
    var filteredSessions: [PokerSession] {
        
        switch sessionFilter {
        case .all: return vm.sessions
        case .cash: return vm.sessions.filter({ $0.isTournament == nil || $0.isTournament == false  })
        case .tournament: return vm.sessions.filter({ $0.isTournament == true })
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                if vm.sessions.isEmpty {
                    
                    VStack {
                        
                        Spacer()
                        EmptyState(image: .sessions)
                        Spacer()
                    }
                    
                } else {
                    
                    if !filteredSessions.isEmpty {
                        
                        List {
                            
                            Text("All Sessions")
                                .titleStyle()
                                .padding(.top, -38)
                                .padding(.horizontal)
                                .listRowBackground(Color.brandBackground)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            
                            // With Paywall offering, we're only prompting them to subscribe with the New Session Button
                            // They can still view all their Sessions if they were previously free users. They just can't add new Sessions
                            
                            ForEach(filteredSessions) { session in
                                NavigationLink(
                                    destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session),
                                    label: {
                                        CellView(pokerSession: session)
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
                            Menu {
                                Picker("", selection: $sessionFilter) {
                                    ForEach(SessionFilter.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                            } label: { Image(systemName: "slider.horizontal.3") }
                        }
                        
                    } else {
                        
                        VStack (alignment: .leading) {
                            
                            Text("All Sessions")
                                .titleStyle()
                                .padding(.top, -38)
                                .padding(.horizontal)
                                .listRowBackground(Color.brandBackground)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            
                            Spacer()
                            EmptyState(image: .sessions)
                            Spacer()
                        }
                        .toolbar {
                            Menu {
                                Picker("", selection: $sessionFilter) {
                                    ForEach(SessionFilter.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized).tag($0)
                                    }
                                }
                            } label: { Image(systemName: "slider.horizontal.3") }
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
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsListView()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
    }
}
