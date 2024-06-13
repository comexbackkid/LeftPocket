//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import RevenueCatUI
import TipKit

enum ViewStyle: String, CaseIterable {
    case standard, compact
}
enum SessionFilter: String, CaseIterable {
    case all, cash, tournaments
}

struct SessionsListView: View {
    
    @AppStorage("viewStyle") var viewStyle: ViewStyle = .standard
    
    @State var activeSheet: Sheet?
    @State var isPresented = false
    @State var showPaywall = false
    @State var showTip = false
    @State var sessionFilter: SessionFilter = .all
    @State var locationFilter: LocationModel?
    
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    
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
        
        var result = vm.sessions
        
        switch sessionFilter {
        case .all: break
        case .cash: result = result.filter({ $0.isTournament == nil || $0.isTournament == false  })
        case .tournaments: result = result.filter({ $0.isTournament == true })
        }
        
        if let locationFilter = locationFilter {
            result = result.filter { $0.location.name == locationFilter.name }
        }
        
        return result
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                if vm.sessions.isEmpty {
                    
                    emptyView
                    
                } else {
                    
                    if !filteredSessions.isEmpty {

                        List {

                            screenTitle
                            
                            ForEach(filteredSessions) { session in
                                NavigationLink(
                                    destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session),
                                    label: {
                                        CellView(pokerSession: session, currency: vm.userCurrency, viewStyle: $viewStyle)
                                    })
                                .listRowBackground(Color.brandBackground)
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            }
                            .onDelete(perform: { indexSet in
                                let sessionIdsToDelete = indexSet.map { filteredSessions[$0].id }
                                for sessionId in sessionIdsToDelete {
                                    if let index = vm.sessions.firstIndex(where: { $0.id == sessionId }) {
                                        vm.sessions.remove(at: index)
                                    }
                                }
                            })
                        }
                        .listStyle(PlainListStyle())
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            toolbarLocationFilter
                            toolbarFilter
                        }
                        
                        if #available(iOS 17.0, *) {
                            
                            VStack {
                                let filterTip = FilterSessionsTip()
                                
                                TipView(filterTip)
                                    .tipViewStyle(CustomTipViewStyle())
                                    .padding(20)
                                
                                Spacer()
                            }
                        }
                        
                    } else {
                        
                        VStack (alignment: .leading) {
                            
                            screenTitle
                            
                            Spacer()
                            EmptyState(image: .sessions)
                            Spacer()
                        }
                        .toolbar {
                            toolbarLocationFilter
                            toolbarFilter
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
    
    var toolbarLocationFilter: some View {
        
        Menu {
            Button("All") {
                locationFilter = nil
            }
        
            Picker("", selection: $locationFilter) {
                ForEach(vm.sessions.map({ $0.location }).uniqued(), id: \.self) { location in
                    Text(location.name).tag(location as LocationModel?)
                }
            }
        } label: {
            Image(systemName: "mappin.and.ellipse")
        }
    }
    
    var toolbarFilter: some View {
        
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
