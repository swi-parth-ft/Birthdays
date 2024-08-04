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
    @State private var defaultImageData: Data = UIImage(systemName: "person")!.jpegData(compressionQuality: 1.0)!
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd" // Set to display month and day only
        return formatter
    }
    
    var upcomingContacts: [Contact] {
        let today = Date()
        let calendar = Calendar.current
        
        return Array(contacts.filter { $0.birthday != nil }
            .sorted { (c1, c2) -> Bool in
                guard let birthday1 = c1.birthday, let birthday2 = c2.birthday else {
                    return false
                }
                
                let todayComponents = calendar.dateComponents([.month, .day], from: today)
                let todayMonth = todayComponents.month!
                let todayDay = todayComponents.day!
                
                let components1 = calendar.dateComponents([.month, .day], from: birthday1)
                let month1 = components1.month!
                let day1 = components1.day!
                
                let components2 = calendar.dateComponents([.month, .day], from: birthday2)
                let month2 = components2.month!
                let day2 = components2.day!
                
                var daysFromToday1 = (month1 - todayMonth) * 30 + (day1 - todayDay)
                var daysFromToday2 = (month2 - todayMonth) * 30 + (day2 - todayDay)
                
                if daysFromToday1 < 0 { // If birthday1 is before today, adjust to next year
                    daysFromToday1 += 365
                }
                
                if daysFromToday2 < 0 { // If birthday2 is before today, adjust to next year
                    daysFromToday2 += 365
                }
                
                return daysFromToday1 < daysFromToday2
            }
        )
    }


    
    var body: some View {
        NavigationStack {
            List {
                ForEach(upcomingContacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            Text("\(contact.birthday ?? Date.now, formatter: dateFormatter)")
                                .font(.subheadline)
                        }
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
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactImageDataKey] as [CNKeyDescriptor]
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
