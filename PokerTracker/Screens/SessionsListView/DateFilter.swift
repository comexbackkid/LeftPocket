//
//  DateFilter.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/26/24.
//

import SwiftUI

struct DateFilter: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        
        VStack {
            
            title
                
            instructions

            dateFilters
            
            saveButton
           
            Spacer()
        }
        .dynamicTypeSize(.medium)
        .ignoresSafeArea()
    }
    
    var title: some View {
        
        HStack {
            
            Text("Date Range")
                .titleStyle()
                .padding(.horizontal)
                .padding(.bottom, -20)
            
            Spacer()
        }
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Use the pickers below to filter your sessions by a specific date range & then press Submit.")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var dateFilters: some View {
        
        VStack {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                    .padding(.leading, 4)
                    .font(.custom("Asap-Regular", size: 18))
                    .datePickerStyle(.compact)
            }
            
            HStack {
                Image(systemName: "hourglass.tophalf.filled")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                    .padding(.leading, 4)
                    .font(.custom("Asap-Regular", size: 18))
                    .datePickerStyle(.compact)
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .tint(.brandPrimary)
    }
    
    var saveButton: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                dismiss()
                
            } label: { PrimaryButton(title: "Submit") }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                startDate = viewModel.sessions.last?.date ?? Date().modifyDays(days: 1460)
                endDate = Date.now
                dismiss()
                
            } label: {
                Text("Reset")
                    .bodyStyle()
            }
            .tint(.red)
        }
    }
}

#Preview {
    DateFilter(startDate: .constant(Date().modifyDays(days: -365)), endDate: .constant(Date()))
        .environmentObject(SessionsListViewModel())
}
