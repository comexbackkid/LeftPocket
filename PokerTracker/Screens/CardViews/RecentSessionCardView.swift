//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct RecentSessionCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var pokerSession: PokerSession
    let width = UIScreen.main.bounds.width * 0.9
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading) {
                
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
                
                else { localImage }
                
                Spacer()
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text(pokerSession.location.name)
                            .headlineStyle()
                            .foregroundStyle(.white)
                        
                        Text("Quickly review your most recent session, hand notes, & profitability.")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    .padding()
                    .padding(.top, -8)
                }
                
                Spacer()
            }
            .background(
                
                ZStack {
                    
                    if pokerSession.location.importedImage != nil {
                        
                        backgroundImage().overlay(.thinMaterial)
                        
                    } else { localImage.overlay(.thinMaterial) }
                })
            
            VStack (alignment: .leading) {
                
                Text("REVIEW")
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.5)
                
                Text("Last Session")
                    .signInTitleStyle()
                    .fontWeight(.heavy)
                    .foregroundColor(Color(.white))
            }
            .offset(y: -135)
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
        
        Image(pokerSession.location.localImage != "" ? pokerSession.location.localImage : "defaultlocation-header")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width)
            .clipped()
    }
    
    func backgroundImage() -> Image {
        
        if pokerSession.location.imageURL != "" {
            
            return Image("encore-header")
            
        } else {
            
            guard
                let imageData = pokerSession.location.importedImage,
                let uiImage = UIImage(data: imageData)
                    
            else {
                
                return Image("encore-header")
            }
            
            return Image(uiImage: uiImage)
                
        }
    }
}

struct RecentSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionCardView(pokerSession: MockData.sampleSession).environmentObject(SessionsListViewModel())
    }
}
