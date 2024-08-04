//
//  ContentView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//

import SwiftUI
import SwiftData
import Contacts
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contact]
    @State private var showingAddView = false
    
    var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd" // Set to display month and day only
            return formatter
        }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(contacts) { contact in
                    VStack(alignment: .leading) {
                        Text(contact.name)
                            .font(.headline)
                        Text("\(contact.birthday ?? Date.now, formatter: dateFormatter)")
                            .font(.subheadline)
                    }
                }
                .onDelete(perform: deletePerson)
            }
            .navigationTitle("Birthdays")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    showingAddView = true
                }
                Button("Sync") {
                    fetchContacts()
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddContactView()
            }
        }
    }
    
    func deletePerson(at offsets: IndexSet) {
        for index in offsets {
            let person = contacts[index]
            modelContext.delete(person)
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func fetchContacts() {
           let store = CNContactStore()
           store.requestAccess(for: .contacts) { granted, error in
               if granted {
                   let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey] as [CNKeyDescriptor]
                   let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                   
                   var fetchedContacts: [Contact] = []
                   do {
                       try store.enumerateContacts(with: request) { contact, stop in
                           let name = "\(contact.givenName) \(contact.familyName)"
                           if let birthdate = contact.birthday?.date {
                               let new = Contact(id: UUID(), name: name, birthday: birthdate)
                               fetchedContacts.append(new)
                          
                                       modelContext.insert(new)
                                       try? modelContext.save()
                                   
                               
                               
                           }
                       }
//                       DispatchQueue.main.async {
//                           self.contacts = fetchedContacts
//                       }
                   } catch {
                       print("Failed to fetch contacts: \(error)")
                   }
               } else {
                   print("Access to contacts was denied.")
               }
           }
       }
}



#Preview {
    ContentView()
}
