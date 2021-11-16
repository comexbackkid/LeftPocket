//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct SessionsView: View {
    
    @State private var isPresented = false
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                
                if viewModel.sessions.isEmpty {
                    EmptyState()
                    
                    VStack {
                        Spacer()
                        Button(action: {
                            isPresented.toggle()
                        }, label: {
                            SecondaryButton()
                        })
                        .sheet(isPresented: $isPresented, content: {
                            NewSessionView(isPresented: $isPresented)
                        })
                    }
                    .padding(.bottom)
                    
                } else {
                    
                    List {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink(
                                destination: SessionDetailView(pokerSession: session),
                                label: {
                                    RecentSessionsCellView(pokerSession: session)
                                })
                        }
                        .onDelete(perform: { indexSet in
                            viewModel.sessions.remove(atOffsets: indexSet)
                        })
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("All Sessions")
                    
                    
                    
                    VStack {
                        Spacer()
                        Button(action: {
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
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView().environmentObject(SessionsListViewModel())
    }
}
