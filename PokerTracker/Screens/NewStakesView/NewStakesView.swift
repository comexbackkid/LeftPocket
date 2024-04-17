//
//  NewStakesView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/17/24.
//

import SwiftUI

struct NewStakesView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var vm: SessionsListViewModel
    
    @StateObject var newStakesViewModel = NewStakesViewModel()
    @Binding var addStakesIsShowing: Bool
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("New Stakes")
                    .titleStyle()
                    .padding(.horizontal)
                
                Spacer()
            }
            
            Text("Use the pickers below to input your own stakes. They will then be added to the list of available stakes to choose from when logging your sessions.")
                .bodyStyle()
                .padding(.horizontal)
                .padding(.bottom, 40)
            
            HStack {
                VStack {
                    Picker("Picker", selection: $newStakesViewModel.smallBlind) {
                        Text(".05").tag(".05")
                        Text(".10").tag(".10")
                        Text(".20").tag(".20")
                        Text(".25").tag(".25")
                        Text(".5").tag(".5")
                        Text("1").tag("1")
                        Text("2").tag("2")
                        Text("3").tag("3")
                        Text("4").tag("4")
                        Text("5").tag("5")
                        Text("6").tag("6")
                        Text("7").tag("7")
                        Text("8").tag("8")
                        Text("9").tag("9")
                        Text("10").tag("10")
                        Text("20").tag("20")
                        Text("25").tag("25")
                        Text("30").tag("30")
                        Text("40").tag("40")
                        Text("50").tag("50")
                        
                    }
                    .pickerStyle(.wheel)
                    .background(RoundedRectangle(cornerRadius:15).stroke(Color.brandPrimary))
                    .padding(.trailing, 10)
                    .padding(.bottom)
                    
                    Text("Small Blind")
                        .bodyStyle()
                }
                
                VStack {
                    Picker("Picker", selection: $newStakesViewModel.bigBlind) {
                        Text(".10").tag(".10")
                        Text(".20").tag(".20")
                        Text(".25").tag(".25")
                        Text(".5").tag(".5")
                        Text("1").tag("1")
                        Text("2").tag("2")
                        Text("3").tag("3")
                        Text("4").tag("4")
                        Text("5").tag("5")
                        Text("6").tag("6")
                        Text("7").tag("7")
                        Text("8").tag("8")
                        Text("9").tag("9")
                        Text("10").tag("10")
                        Text("20").tag("20")
                        Text("25").tag("25")
                        Text("30").tag("30")
                        Text("35").tag("35")
                        Text("40").tag("40")
                        Text("50").tag("50")
                        Text("60").tag("60")
                        Text("75").tag("75")
                        Text("80").tag("80")
                        Text("100").tag("100")
                        
                    }
                    .pickerStyle(.wheel)
                    .background(RoundedRectangle(cornerRadius:15).stroke(Color.brandPrimary))
                    .padding(.leading, 10)
                    .padding(.bottom)
                    
                    Text("Big Blind")
                        .bodyStyle()
                }
            }
            .frame(maxHeight: 150)
            .padding(.horizontal, 25)
            .padding(.bottom, 50)
            
            VStack {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    newStakesViewModel.saveStakes(viewModel: vm)
                    addStakesIsShowing = newStakesViewModel.presentation ?? true
                } label: {
                    PrimaryButton(title: "Save Stakes")
                }
                .tint(Color.brandPrimary)
                
                Button(role: .cancel) {
                    addStakesIsShowing.toggle()
                } label: {
                    Text("Cancel")
                        .bodyStyle()
                }
                .tint(.red)
            }
            
            Spacer()
            
            
        }
        .background(Color.brandBackground)
        
    }
}


#Preview {
    NewStakesView(addStakesIsShowing: .constant(true))
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
