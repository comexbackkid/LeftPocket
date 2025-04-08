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
    
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    
    @State private var localStartDate: Date = Date().modifyDays(days: -365)
    @State private var localEndDate: Date = Date()
    
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
        .onAppear {
            let oldestSession = viewModel.allSessions.sorted(by: { $0.date < $1.date }).first?.date
            localStartDate = startDate ?? oldestSession ?? Date().modifyDays(days: -365)
            localEndDate = endDate ?? Date()
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("Date Range")
                .font(.custom("Asap-Black", size: 34))
                .bold()
                .padding(.bottom, 5)
                .padding(.top, 20)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Use the pickers below to filter your Sessions by a specific date range & then press Submit.")
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
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("Start Date", selection: $localStartDate, in: ...localEndDate, displayedComponents: [.date])
                    .padding(.leading, 4)
                    .font(.custom("Asap-Regular", size: 18))
                    .datePickerStyle(.compact)
            }
            
            HStack {
                Image(systemName: "hourglass.tophalf.filled")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(.systemGray3))
                    .frame(width: 30)
                
                DatePicker("End Date", selection: $localEndDate, in: localStartDate...Date.now, displayedComponents: [.date])
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
                startDate = localStartDate
                endDate = localEndDate
                dismiss()
                
            } label: { PrimaryButton(title: "Submit") }
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                startDate = nil
                endDate = nil
                dismiss()
                
            } label: {
                Text("Reset")
                    .bodyStyle()
            }
            .tint(.red)
        }
        .padding(.horizontal)
    }
}

#Preview {
    DateFilter(startDate: .constant(Date().modifyDays(days: -365)), endDate: .constant(Date()))
        .environmentObject(SessionsListViewModel())
}
