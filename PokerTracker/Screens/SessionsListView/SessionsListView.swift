//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct SessionsView: View {
    
    @State private var isPresented = false
    @EnvironmentObject var sessionsListViewModel: SessionsListModel
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(sessionsListViewModel.sessions ) { session in
                        NavigationLink(
                            destination: SessionDetailView(viewModel: SessionDetailViewModel(pokerSession: session)),
                            label: {
                                RecentSessionsCellView(pokerSession: session)
                            })
                    }
                }
                .navigationTitle("Recent Sessions").accentColor(.white)

                VStack {
                    Spacer()
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        Text("Add New Session")
                            .font(.title3)
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color("brandPrimary"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    })
                    .sheet(isPresented: $isPresented, content: {
                        NewSessionView(isPresented: $isPresented)
                    })
                }
            }
        }
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView().environmentObject(SessionsListModel())
    }
}



// TODO
//
// Need to add dates or sort by dates to this List
// This will eventually involve an EnvironmentObject where this view has access to
// EnvironmentObject I'm guessing will be our poker sessions data, an array of the different sessions
