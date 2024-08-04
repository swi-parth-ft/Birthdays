//
//  ContentView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contacts]
    
    var body: some View {
        List {
            ForEach(contacts) { contact in
                Text(contact.name)
            }
        }
    }
}

#Preview {
    ContentView()
}
