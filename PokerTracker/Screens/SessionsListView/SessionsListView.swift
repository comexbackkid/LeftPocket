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
    
//    let filteredData = viewModel.sessions.filter {
//        return Calendar.current.component(.month, from: $0.date) == ____?
//    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.sortedSessions) { session in
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
                .navigationTitle("Recent Sessions").accentColor(.white)
                
                if viewModel.sessions.isEmpty {
                    EmptyState()
                }

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

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView().environmentObject(SessionsListViewModel())
    }
}
