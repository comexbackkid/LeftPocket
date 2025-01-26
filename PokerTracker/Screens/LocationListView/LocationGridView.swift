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
                
            } else {
                EmptyState(title: "No Locations", image: .locations)
                    .padding(.top, 150)
            }
        }
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            addLocationButton
            resetLocationsButton
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
    
    var resetLocationsButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            showAlert = true
            
        } label: {
            Image(systemName: "gobackward")
        }
        .foregroundColor(.brandPrimary)
        .alert(Text("Warning"), isPresented: $showAlert) {
            Button("OK", role: .destructive) {
                vm.mergeLocations()
            }
            Button("Cancel", role: .cancel) {
                print("User Canceled")
            }
        } message: {
            Text("This will restore the original Locations. Your custom Locations will NOT be affected.")
        }
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
