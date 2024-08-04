//
//  AddContactView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddContactView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contact]
    @State private var name = ""
    @State private var birthday = Date()
    
    
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            Button("Add Contact") {
                let newContact = Contact(name: name, birthday: birthday)
                modelContext.insert(newContact)
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
            }
            
        }
    }
}

#Preview {
    AddContactView()
}
