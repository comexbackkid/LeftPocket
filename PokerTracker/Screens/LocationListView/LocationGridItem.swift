//
//  LocationGridItem.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/30/25.
//

import SwiftUI

struct LocationGridItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showEditLocation = false
    @State private var showDeleteWarning = false

    let location: LocationModel_v2
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            if let localImage = location.localImage {
                Image(localImage)
                    .locationGridThumbnail(colorScheme: colorScheme)
                    .contextMenu {
                        Button(role: .destructive) {
                            showDeleteWarning = true
                        } label: { Label("Delete Location", systemImage: "trash") }
                    }
                
            } else if let importedImagePath = location.importedImage {
                if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                    Image(uiImage: uiImage)
                        .locationGridThumbnail(colorScheme: colorScheme)
                        .contextMenu {
                            Button(role: .destructive) {
                                showDeleteWarning = true
                            } label: { Label("Delete Location", systemImage: "trash") }
                            
                            Button {
                                showEditLocation = true
                            } label: { Label("Edit Location", systemImage: "pencil") }
                        }
                    
                } else {
                    Image("defaultlocation-header")
                        .locationGridThumbnail(colorScheme: colorScheme)
                        .contextMenu {
                            Button(role: .destructive) {
                                showDeleteWarning = true
                            } label: { Label("Delete Location", systemImage: "trash") }
                            
                            Button {
                                showEditLocation = true
                            } label: { Label("Edit Location", systemImage: "pencil") }
                        }
                }
                
            } else {
                Image("defaultlocation-header")
                    .locationGridThumbnail(colorScheme: colorScheme)
                    .contextMenu {
                        Button(role: .destructive) {
                            showDeleteWarning = true
                        } label: { Label("Delete Location", systemImage: "trash") }
                        
                        Button {
                            showEditLocation = true
                        } label: { Label("Edit Location", systemImage: "pencil") }
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
        .sheet(isPresented: $showEditLocation) {
            EditLocation(location: location)
                .presentationDragIndicator(.visible)
        }
        .confirmationDialog("Are you sure you want to delete?", isPresented: $showDeleteWarning, titleVisibility: .visible) {
            Button("Delete Location", role: .destructive) {
                delete()
            }
        }
    }
    
    func delete() {
        withAnimation {
            vm.delete(location)
        }
    }
}

#Preview {
    LocationGridItem(location: MockData.mockLocation)
        .environmentObject(SessionsListViewModel())
}
