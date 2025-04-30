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

#Preview {
    LocationGridItem(location: MockData.mockLocation)
        .environmentObject(SessionsListViewModel())
}
