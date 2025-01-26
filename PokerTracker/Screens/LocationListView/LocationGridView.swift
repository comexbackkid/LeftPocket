//
//  LocationGridView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/16/23.
//

import SwiftUI
import TipKit

struct LocationGridView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State var addLocationIsShowing = false
    @State var showAlert = false
    
    let columns = [GridItem(.fixed(165), spacing: 20), GridItem(.fixed(165))]
    
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
        .toolbar {
            addLocationButton
        }
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
            
            Text("Tap the \(Image(systemName: "plus")) button above to get started\nwith adding your own locations.")
                .foregroundColor(.secondary)
                .subHeadlineStyle()
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            
            
        }
        
    }
    
    var addLocationButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            addLocationIsShowing.toggle()
            
        } label: {
            Image(systemName: "plus")
        }
        .foregroundColor(.brandPrimary)
        .sheet(isPresented: $addLocationIsShowing, content: {
            NewLocationView(addLocationIsShowing: $addLocationIsShowing)
        })
    }
    
    var locationTip: some View {
        
        VStack {
            let deleteTip = DeleteLocationTip()
            TipView(deleteTip)
                .tipViewStyle(CustomTipViewStyle())
                .padding(.horizontal, 20)
                .padding(.bottom)
        }
    }
}

struct LocationGridItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: SessionsListViewModel

    let location: LocationModel_v2
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            if let localImage = location.localImage {
                Image(localImage)
                    .locationGridThumbnail(colorScheme: colorScheme)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete()
                        } label: { Label("Delete Location", systemImage: "trash") }
                    }
                
            } else if let importedImagePath = location.importedImage {
                if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                    Image(uiImage: uiImage)
                        .locationGridThumbnail(colorScheme: colorScheme)
                        .contextMenu {
                            Button(role: .destructive) {
                                delete()
                            } label: { Label("Delete Location", systemImage: "trash") }
                        }
                    
                } else {
                    Image("defaultlocation-header")
                        .locationGridThumbnail(colorScheme: colorScheme)
                        .contextMenu {
                            Button(role: .destructive) {
                                delete()
                            } label: { Label("Delete Location", systemImage: "trash") }
                        }
                }
                
            } else {
                Image("defaultlocation-header")
                    .locationGridThumbnail(colorScheme: colorScheme)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete()
                        } label: { Label("Delete Location", systemImage: "trash") }
                    }
            }
            
            Text(location.name)
                .calloutStyle()
                .lineLimit(1)
                .fontWeight(.semibold)
                .padding(.top, 7)
            
            Text("\(vm.uniqueLocationCount(location: location))" + " Visits")
                .captionStyle()
                .opacity(0.75)
                .lineLimit(1)
                .padding(.bottom, 20)
        }
        
    }
    
    func delete() {
        withAnimation {
            vm.delete(location)
        }
    }
}

extension SessionsListViewModel {
    
    // TODO: PERHAPS USE $0.LOCATION.NAME INSTEAD INCASE MIGRATION HAS AN ISSUE
    // This is only working when you filter by .name versus the .id not sure why? Does it matter? What if the name is changed by the user?
    func uniqueLocationCount(location: LocationModel_v2) -> Int {
        let array = self.sessions.filter({ $0.location.id == location.id })
        return array.count
    }
}

struct LocationGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationGridView()
                .environmentObject(SessionsListViewModel())
        }
    }
}
