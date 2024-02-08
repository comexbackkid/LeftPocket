//
//  ImportView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/5/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @State private var showFileImporter = false
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack {
                
                title
                
                bodyText
                
                importButton
                
            }
        }
        .background(Color.brandBackground)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Import Data")
                .titleStyle()
                .padding(.top, -37)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var bodyText: some View {
        
        VStack (alignment: .leading) {
            
            Text("Please Read Carefully")
                .subtitleStyle()
                .bold()
                .padding(.top, 50)
            
            Text("Currently, Left Pocket only supports data in CSV format exported from Poker Bankroll Tracker. DO NOT modify their CSV file. The file should be set to 'UTF-8' and field separator set to 'comma.' Make sure to follow the steps below.\n")
                .calloutStyle()
                .opacity(0.8)
                .padding(.top, 1)
            
            VStack (alignment: .leading) {
                
                Text("__1.__ Export CSV from Poker Bankroll Tracker\n__2.__ Save file to a folder in your iCloud Drive\n__3.__ Click the Import CSV Data button below\n__4.__ Your old poker data should populate and appear in the Sessions List view, using the default header image.")
                    .calloutStyle()
                    .opacity(0.8)
                    .lineSpacing(5)
                    .padding(.vertical, 20)
            }
        }
        .padding(.horizontal)
        
    }
    
    var importButton: some View {
        
        Button {
            
            showFileImporter = true
            
        } label: {
            
            PrimaryButton(title: "Import CSV Data")
            
        }
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.plainText, .commaSeparatedText],
                      onCompletion: { result in
            
            do {
                let selectedURL = try result.get()
                let csvData = try Data(contentsOf: selectedURL)
                let csvImporter = CSVImporter()
                let importedSessions = try csvImporter.importCSV(data: csvData)
                vm.sessions = importedSessions
                
            } catch {
                print("Error importing file: \(error)")
            }
        })
        
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView()
            .preferredColorScheme(.dark)
    }
}
