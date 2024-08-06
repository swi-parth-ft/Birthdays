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
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contact]
    @State private var showingAddView = false
    @State private var defaultImageData: Data = UIImage(systemName: "person")!.jpegData(compressionQuality: 1.0)!
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM" // Set to display month and day only
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
               
                        VStack(alignment: .leading) {
                            Text(isBirthdayToday(birthday: contact.birthday!) ? "\(contact.name) 🎂" : contact.name)
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
    
    func isBirthdayToday(birthday: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.month, .day], from: today)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        
        return todayComponents.month == birthdayComponents.month && todayComponents.day == birthdayComponents.day
    }
    
    func deletePerson(at offsets: IndexSet) {
        for index in offsets {
            let person = upcomingContacts[index]
            print(index)
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
                            // Get the next day's date
                            let calendar = Calendar.current
                            if let nextDay = calendar.date(byAdding: .day, value: 1, to: birthdate) {
                                // Trim white spaces from the name
                                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                let newContact = Contact(id: UUID(), name: trimmedName, birthday: nextDay)
                                fetchedContacts.append(newContact)

                                let components = calendar.dateComponents([.month, .day], from: nextDay)
                                let month = components.month!
                                let day = components.day!

                                modelContext.insert(newContact)
                                addNotification(for: newContact, at: month, day: day)
                                try? modelContext.save()
                            }
                        }
                    }
                } catch {
                    print("Failed to fetch contacts: \(error)")
                }
            } else {
                print("Access to contacts was denied.")
            }
        }
    }
    
    func addNotification(for contact: Contact, at month: Int, day: Int) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "It's \(contact.name)'s Birthday today! 🎂"
            content.body = "let's pop some confetti 🎉"
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = 10
            dateComponents.minute = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView()
}
