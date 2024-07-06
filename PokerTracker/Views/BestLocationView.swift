//
//  BestLocationView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/16/22.
//

import SwiftUI

struct BestLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let location: LocationModel
    
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
                
                if location.imageURL != "" {
                    
                    AsyncImage(url: URL(string: location.imageURL), scale: 1, transaction: Transaction(animation: .easeIn)) { imagePhase in
                        
                        switch imagePhase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(20)
                                .padding(.leading)
                            
                        case .failure:
                            FailureView()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(20)
                                .padding(.leading)
                            
                        case .empty:
                            PlaceholderView()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(20)
                                .padding(.leading)
                            
                        @unknown default:
                            PlaceholderView()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(20)
                                .padding(.leading)
                        }
                    }
                    
                } else if location.importedImage != nil {
                    
                    if let photoData = location.importedImage,
                       let uiImage = UIImage(data: photoData) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(20)
                            .padding(.leading)
                    }
                    
                } else {
                    
                    Image(location.localImage != "" ? location.localImage : "defaultlocation-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(20)
                        .padding(.leading)
                }
            }
        }
        .padding(30)
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 120)
        .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
    }
}

struct BestLocationView_Previews: PreviewProvider {
    static var previews: some View {
        BestLocationView(location: MockData.mockLocation)
//            .preferredColorScheme(.dark)
    }
}
