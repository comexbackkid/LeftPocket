////
////  BestLocationView.swift
////  LeftPocket
////
////  Created by Christian Nachtrieb on 12/16/22.
////

import SwiftUI

struct BestLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let location: LocationModel_v2
    
    var body: some View {
        
        VStack (spacing: 12) {
            
            HStack {
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text("Best Location")
                        .calloutStyle()
                    
                    Text(location.name)
                        .headlineStyle()
                        .lineLimit(1)
                        .font(.headline)
                }
                
                Spacer()
                
                if let localImage = location.localImage {
                    Image(localImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(12)
                        .padding(.leading)
                    
                } else if let importedImagePath = location.importedImage {
                    if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(12)
                            .padding(.leading)
                        
                    } else {
                        Image("defaultlocation-header")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(12)
                            .padding(.leading)
                    }
                    
                } else {
                    Image("defaultlocation-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(12)
                        .padding(.leading)
                }
            }
        }
        .padding(30)
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 120)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

struct BestLocationView_Previews: PreviewProvider {
    static var previews: some View {
        BestLocationView(location: MockData.mockLocation)
//            .preferredColorScheme(.dark)
    }
}
