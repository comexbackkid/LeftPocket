//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI
import UIKit

struct RecentSessionCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var pokerSession: PokerSession
    let width = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading) {
                
                VStack {
                    if pokerSession.location.imageURL != "" {
                        
                        downloadedImage
                        
                    } else if pokerSession.location.importedImage != nil {
                        
                        if let photoData = pokerSession.location.importedImage,
                           let uiImage = UIImage(data: photoData) {
                            
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: width)
                                .clipped()
                        }
                    }
                    
                    else { 
                        localImage
                    }
                }
                .frame(maxHeight: 250)
                .clipped()
                
                Spacer()
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text(pokerSession.location.name)
                            .headlineStyle()
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                        Text("Tap here to quickly review your last session, hand notes, & key stats.")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                    }
                    .padding()
                    .padding(.top, -8)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .background(
                
                ZStack {
                    
                    if pokerSession.location.importedImage != nil {
                        
                        // If the importedImage property isn't nil, convert the data & show the image
                        importedImage.overlay(.thinMaterial)
                        
                    } else if pokerSession.location.imageURL != "" {
                        
                        // If the Location has an imageURL, most won't, then download & display the image
                        // It may not look great if the link is messed up
                        downloadedImage.overlay(.thinMaterial)
                        
                    } else {
                        
                        // Lastly, if none of the above pass then just display the localImage
                        localImage.overlay(.thinMaterial) }
                })
            
            VStack (alignment: .leading) {
                
                Text("REVIEW")
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.5)
                
                Text("Last Session")
                    .signInTitleStyle()
                    .fontWeight(.heavy)
                    .foregroundColor(Color(.white))
                
                Spacer()
            }
            
            .padding()
                
        }
        .frame(width: width, height: 360)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.23),
                radius: 12, x: 0, y: 5)
    }
    
    var downloadedImage: some View {
        
        AsyncImage(url: URL(string: pokerSession.location.imageURL), scale: 1, transaction: Transaction(animation: .easeIn)) { phase in
  
            if let image = phase.image {
                
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width)
                    .clipped()
                
            } else if phase.error != nil {
                
                FailureView()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width)
                    .clipped()
                
            } else {
                
                PlaceholderView()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width)
                    .clipped()
            }
        }
    }
    
    var localImage: some View {
        
        // We need this ternary operator as a final check to make sure no nil value for an image gets displayed
        Image(pokerSession.location.localImage != "" ? pokerSession.location.localImage : "defaultlocation-header")
            .resizable()
//            .aspectRatio(contentMode: .fill)
            .scaledToFill()
            .frame(width: width)
            .clipped()
    }
    
    var importedImage: some View {
        
        guard
            let imageData = pokerSession.location.importedImage,
            let uiImage = UIImage(data: imageData)
            
        else {
            
            return Image("defaullocation-header")
            
        }
        
        return Image(uiImage: uiImage)
        
    }
}

struct RecentSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionCardView(pokerSession: MockData.sampleSession).environmentObject(SessionsListViewModel())
    }
}
