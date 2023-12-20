//
//  LocationsListView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/27/22.
//

import SwiftUI

struct LocationsListView: View {

    @EnvironmentObject var viewModel: SessionsListViewModel
    @State var addLocationIsShowing = false
    @State var editLocationIsShowing = false

    var body: some View {

        VStack {

            form

        }
        .background(Color.brandBlack)
        .accentColor(.brandPrimary)
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("My Locations")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            addLocationIsShowing.toggle()

        }, label: {
            Image(systemName: "plus")
        }))
        .sheet(isPresented: $addLocationIsShowing, content: {
            NewLocationView(addLocationIsShowing: $addLocationIsShowing)
        })
    }

    var form: some View {

        Form {
            Section(header: Text("Current Locations"),
                    footer: Text("Add your own location, casino, or home game, by clicking the + button in the upper right corner of the screen. Swipe left on a Location to modify or delete it.")) {

                List(viewModel.locations.indices, id: \.self) { index in
                    LocationsRowView(location: $viewModel.locations[index])
                }}
        }
        .scrollContentBackground(.hidden)
    }
}

struct LocationsRowView: View {
    @State var editing = false
    @Binding var location: LocationModel
    @EnvironmentObject var viewModel: SessionsListViewModel

    func delete() {
        withAnimation {
            viewModel.delete(location)
        }
    }

    var body: some View {

        Text(location.name)
            .frame(maxWidth: .infinity, alignment: .leading)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {

                Button(role: .destructive) {
                    delete()
                } label: { Image(systemName: "trash.fill") }

                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    editing.toggle()
                } label: { Image(systemName: "pencil") }
                    .tint(.yellow)
            }
            .background {
                NavigationLink(isActive: $editing,
                               destination: { EditLocationView(location: $location) }) { EmptyView() }.opacity(0)
            }
    }
}

struct LocationsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationsListView()
                .environmentObject(SessionsListViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
