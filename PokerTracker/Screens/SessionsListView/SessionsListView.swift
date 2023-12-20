//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct SessionsListView: View {
    
    enum SessionFilter: String, CaseIterable {
        case all, cash, tournament
    }
    
    @State var activeSheet: Sheet?
    @State var isPresented = false
    @State var sessionFilter: SessionFilter = .all
    @EnvironmentObject var vm: SessionsListViewModel
    
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
                        EmptyState(screen: .sessions)
                        Spacer()
                    }
                    
                } else {
                    
                    List {
                        
                        Text("All Sessions")
                            .titleStyle()
                            .padding(.top, -38)
                            .padding(.horizontal)
                            .listRowBackground(Color.brandBlack)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
                        ForEach(filteredSessions) { session in
                            NavigationLink(
                                destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session),
                                label: {
                                    CellView(pokerSession: session)
                                }).listRowBackground(Color.brandBlack)
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
                }
            }
            .accentColor(.brandPrimary)
            .background(Color.brandBlack)
        }
        .accentColor(.brandPrimary)
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsListView().environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
