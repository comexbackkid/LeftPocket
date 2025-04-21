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
    
    var pokerSession: PokerSession_v2
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading) {

                VStack {
                    if let localImage = pokerSession.location.localImage {
                        Image(localImage)
                            .centerCropped()
                        
                    } else if let importedImagePath = pokerSession.location.importedImage {
                        if let uiImage = loadImage(from: importedImagePath) {
                            Image(uiImage: uiImage)
                                .centerCropped()
                            
                        } else {
                            Image("defaultlocation-header")
                                .centerCropped()
                        }
                        
                    } else {
                        Image("defaultlocation-header")
                            .centerCropped()
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
                        
                        Text("Tap here to quickly review your last Session, hand notes, and key stats.")
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                    }
                    .padding()
                    .padding(.top, -8)
                    .dynamicTypeSize(...DynamicTypeSize.large)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .background(
                ZStack {
                    if let localImage = pokerSession.location.localImage {
                        Image(localImage)
                            .overlay(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                        
                    } else if let importedImagePath = pokerSession.location.importedImage {
                        if let uiImage = loadImage(from: importedImagePath) {
                            Image(uiImage: uiImage)
                                .overlay(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                            
                        } else {
                            Image("defaultlocation-header")
                                .overlay(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                        }
                        
                    } else {
                        Image("defaultlocation-header")
                            .overlay(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                    }
                }
            )
            
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
        .frame(height: 360)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    func loadImage(from path: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("LocationImages").appendingPathComponent(path)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

struct RecentSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionCardView(pokerSession: MockData.sampleSession).environmentObject(SessionsListViewModel())
    }
}


