//
//  LocationGridView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/16/23.
//

import SwiftUI

struct LocationGridView: View {
    
    let columns = [GridItem(.fixed(165), spacing: 20), GridItem(.fixed(165))]
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State var addLocationIsShowing = false
    
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
                
                EmptyState(screen: .locations)
                
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
        .background(Color.brandBlack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
    }
}

struct LocationGridItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: SessionsListViewModel
    
    let location: LocationModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            if location.localImage != "" {
                
                Image(location.localImage)
                    .resizable()
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
                fetchLocationImage(location: location)
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
            
            switch phase {
            case .success(let image):
                image
                    .resizable()
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
                
            case .failure:
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
                
            case .empty:
                PlaceholderView()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 165, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 4))
                    .shadow(color: .gray.opacity(colorScheme == .light ? 0.5 : 0.0), radius: 7)
                
            @unknown default:
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


