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
                        EmptyState()
                            .padding(.top, 40)
                        
                        Spacer()
                    }
                    
                } else {
                    
                    List {
                        ForEach(filteredSessions) { session in
                            NavigationLink(
                                destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session),
                                label: {
                                    CellView(pokerSession: session)
                                })
                        }
                        .onDelete(perform: { indexSet in
                            vm.sessions.remove(atOffsets: indexSet)
                        })
                    }
                    .listStyle(PlainListStyle())
                    .navigationBarTitle("All Sessions")
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
                
                VStack {
                    
                    Spacer()
                    
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                        impact.impactOccurred()
                        isPresented.toggle()
                    }, label: {
                        SecondaryButton()
                    })
                        .sheet(isPresented: $isPresented, content: {
                            NewSessionView(isPresented: $isPresented)
                        })
                }
                .padding(.bottom)
            }
        }
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsListView().environmentObject(SessionsListViewModel())
    }
}
