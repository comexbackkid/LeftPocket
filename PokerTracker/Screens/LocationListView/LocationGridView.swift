//
//  LocationGridView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/16/23.
//

import SwiftUI

struct LocationGridView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State var addLocationIsShowing = false
    @State var showAlert = false
    
    let deleteTip = DeleteLocationTip()
    let columns = [GridItem(.fixed(165), spacing: 20), GridItem(.fixed(165))]
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            HStack {
                
                Text("My Locations")
                    .titleStyle()
                    .padding(.top, -37)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            if vm.locations.isEmpty {
                
                EmptyState(image: .locations)
                
            } else {
                
                LazyVGrid(columns: columns) {
                    ForEach(vm.locations) { location in
                        LocationGridItem(location: location)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
        }
        .background(Color.brandBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            addLocationButton
                
            resetLocationsButton
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
}

struct LocationGridItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: SessionsListViewModel

    let location: LocationModel
    let deleteTip = DeleteLocationTip()
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            if location.localImage != "" {
                
                // If the Location has a local image associated with it, just display tha image
                Image(location.localImage)
                    .locationGridThumbnail(colorScheme: colorScheme)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete()
                        } label: {
                            Label("Delete Location", systemImage: "trash")
                        }
                    }
                    .popoverTip(deleteTip)
                
            } else if location.imageURL != "" {
                
                // If the provided link is not empty, go ahead and fetch the image from the URL provided by user
                fetchLocationImage(location: location)
                
            } else if location.importedImage != nil {
                
                // If user imported their own image, call it up here by converting data to UIImage
                if let photoData = location.importedImage,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .locationGridThumbnail(colorScheme: colorScheme)
                        .contextMenu {
                            Button(role: .destructive) {
                                delete()
                            } label: { Label("Delete Location", systemImage: "trash") }
                        }
                }
                
            } else {
                
                // Otherwise, if the Location has no local image, no provided URL, show the default header
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
            
            Text("\(vm.uniqueLocationCount(location: location))" + " Sessions")
                .captionStyle()
                .opacity(0.75)
                .lineLimit(1)
                .padding(.bottom, 20)
        }
        
    }
    
    // Need to set up testing with broken image links to make sure this works
    func fetchLocationImage(location: LocationModel) -> some View {
        
        AsyncImage(url: URL(string: location.imageURL), scale: 1, transaction: Transaction(animation: .easeIn)) { phase in
            
            if let image = phase.image {
                
                image
                    .locationGridThumbnail(colorScheme: colorScheme)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete()
                        } label: {
                            Label("Delete Location", systemImage: "trash")
                        }
                    }
                
            } else if phase.error != nil {
                
                FailureView()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 165, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 4))
                    .shadow(color: .gray.opacity(colorScheme == .light ? 0.5 : 0.0), radius: 7)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete()
                        } label: {
                            Label("Delete Location", systemImage: "trash")
                        }
                    }
                
            } else {
                
                PlaceholderView()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 165, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 4))
                    .shadow(color: .gray.opacity(colorScheme == .light ? 0.5 : 0.0), radius: 7)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete()
                        } label: {
                            Label("Delete Location", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    func delete() {
        withAnimation {
            vm.delete(location)
        }
    }
}

struct LocationGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationGridView()
                .environmentObject(SessionsListViewModel())
            //            LocationGridItem(image: "encore-header", name: "Encore Boston Harbor", count: 3)
            //                            .preferredColorScheme(.dark)
        }
    }
}


