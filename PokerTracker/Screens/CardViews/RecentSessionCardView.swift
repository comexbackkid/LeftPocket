//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct RecentSessionCardView: View {
    
    var pokerSession: PokerSession
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    let width = UIScreen.main.bounds.width * 0.8
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            VStack (alignment: .leading) {
                
                if pokerSession.location.imageURL != "" {
                    
                    downloadedImage
                    
                } else { localImage }
                
                Spacer()
                
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        Text(pokerSession.location.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        Text("See your most recent session to review hand notes & other details.")
                            .font(.subheadline)
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
                    
                    if pokerSession.location.imageURL != "" {
                        
                        downloadedImage.overlay(.ultraThinMaterial)
                        
                    } else { localImage.overlay(.ultraThinMaterial) }
                })
            
            VStack (alignment: .leading) {
                
                Text("REVIEW")
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.5)
                
                Text("Last Session")
                    .font(.title)
                    .fontWeight(.semibold)
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
        
        AsyncImage(url: URL(string: pokerSession.location.imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
            //                            .frame(width: 340, height: 240)
                .frame(width: width)
                .clipped()
            
        } placeholder: {
            PlaceholderView()
            //                            .frame(width: 340, height: 240)
                .clipped()
        }
    }
    
    var localImage: some View {
        
        Image(pokerSession.location.localImage != "" ? pokerSession.location.localImage : "default-header")
            .resizable()
            .aspectRatio(contentMode: .fill)
        //                        .frame(width: 340, height: 240)
            .frame(width: width)
            .clipped()
    }
}

struct RecentSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionCardView(pokerSession: MockData.sampleSession).environmentObject(SessionsListViewModel())
    }
}
