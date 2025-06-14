//
//  LocationGridView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/16/23.
//

import SwiftUI
import TipKit
import RevenueCatUI
import RevenueCat

struct LocationGridView: View {
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var addLocationIsShowing = false
    @State private var showAlert = false
    @State private var showPaywall = false
    
    let columns = [GridItem(.adaptive(minimum: 160, maximum: 360), spacing: 10)]
    let deleteTip = DeleteLocationTip()
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            title
            
            locationTip
            
            if !vm.locations.isEmpty {
                LazyVGrid(columns: columns) {
                    ForEach(vm.locations) { location in
                        LocationGridItem(location: location)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
        }
        .overlay {
            VStack {
                if vm.locations.isEmpty {
                    emptyState
                }
            }
        }
        .scrollDisabled(vm.locations.isEmpty ? true : false)
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { addLocationButton }
    }
    
    var title: some View {
        
        HStack {
            
            Text("My Locations")
                .titleStyle()
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var emptyState: some View {
        
        VStack (spacing: 5) {
            
            Image("locationvectorart-transparent")
                .resizable()
                .frame(width: 125, height: 125)
            
            Text("No Locations")
                .cardTitleStyle()
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Tap the \(Image(systemName: "plus.circle.fill")) button above to get started\nwith adding your own locations.")
                .foregroundColor(.secondary)
                .subHeadlineStyle()
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        
    }
    
    var addLocationButton: some View {
        
        Group {
            
            let locationCount = vm.locations.count
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                if subManager.isSubscribed || locationCount < 2 {
                    addLocationIsShowing.toggle()
                    
                } else {
                    showPaywall = true
                }
                deleteTip.invalidate(reason: .actionPerformed)
                
            } label: {
                Image(systemName: "plus.circle.fill")
                    .fontWeight(.black)
            }
            .foregroundColor(.brandPrimary)
            .sheet(isPresented: $addLocationIsShowing, content: {
                NewLocationView(addLocationIsShowing: $addLocationIsShowing)
                    .presentationDragIndicator(.visible)
            })
        }
        .fullScreenCover(isPresented: $showPaywall, content: {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                .dynamicTypeSize(.large)
                .overlay {
                    HStack {
                        Spacer()
                        VStack {
                            DismissButton()
                                .padding(.horizontal)
                                .onTapGesture {
                                    showPaywall = false
                            }
                            Spacer()
                        }
                    }
                }
        })
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }
    
    var locationTip: some View {
        
        VStack {
            TipView(deleteTip)
                .tipViewStyle(CustomTipViewStyle())
                .padding(.horizontal, 20)
                .padding(.bottom)
        }
    }
}

extension SessionsListViewModel {
    
    // TODO: PERHAPS USE $0.LOCATION.NAME INSTEAD INCASE MIGRATION HAS AN ISSUE
    // This is only working when you filter by .name versus the .id not sure why? Does it matter? What if the name is changed by the user?
    func uniqueLocationCount(location: LocationModel_v2) -> Int {
        let array = self.allSessions.filter({ $0.location.id == location.id })
        return array.count
    }
}

struct LocationGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LocationGridView()
                .environmentObject(SessionsListViewModel())
                .environmentObject(SubscriptionManager())
        }
    }
}
