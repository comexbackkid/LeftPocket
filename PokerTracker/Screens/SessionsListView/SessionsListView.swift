//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct SessionsView: View {
    
    @State var activeSheet: Sheet?
    @State var isPresented = false
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                
                if viewModel.sessions.isEmpty {
                    VStack {
                        EmptyState()
                        
                        Spacer()
                    }
                    
                } else {
                    List {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink(
                                destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session),
                                label: {
                                    CellView(pokerSession: session)
                                })
                        }
                        .onDelete(perform: { indexSet in
                            viewModel.sessions.remove(atOffsets: indexSet)
                        })
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("All Sessions")
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
        SessionsView().environmentObject(SessionsListViewModel())
    }
}
