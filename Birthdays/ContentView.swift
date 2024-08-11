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
    var notifications = AddNotifications()
    @State private var selectedContact: Contact? = nil
    @State private var showingAddView = false
    @State private var bounce = false
    @State private var searchText = ""
    @State private var defaultImageData: Data = UIImage(systemName: "person")!.jpegData(compressionQuality: 1.0)!
    
    @State private var isShowingDetail = false
    var birthdates = Birthdates()
    var callAndMessage = CallAndMessage()
    
    
    
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
    
    var groupedContacts: [Int: [Contact]] {
        Dictionary(grouping: upcomingContacts, by: { Calendar.current.component(.month, from: $0.birthday ?? Date()) })
    }
    
    var months: [Int] {
        let monthsInYear = (1...12).map { $0 }
        let todayMonth = Calendar.current.component(.month, from: Date())
        let upcomingMonths = monthsInYear.filter { $0 >= todayMonth }
        let remainingMonths = monthsInYear.filter { $0 < todayMonth }
        return upcomingMonths + remainingMonths
    }
    
    
    var filteredContacts: [Int: [Contact]] {
        if searchText.isEmpty {
            return groupedContacts
        } else {
            var filtered = [Int: [Contact]]()
            for (month, contacts) in groupedContacts {
                filtered[month] = contacts.filter { contact in
                    contact.name.lowercased().contains(searchText.lowercased())
                }
            }
            return filtered
        }
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "#D2FFDC"), Color(hex: "#1B231C")], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                if groupedContacts.isEmpty {
                    ContentUnavailableView("No Birthdays", systemImage: "birthday.cake.fill", description: Text("Tap \(Image(systemName: "plus")) to add a birthday or tap \(Image(systemName: "person.crop.circle.fill.badge.plus")) to sync birthdays from contacts."))
                } else {
                    List {
                        ForEach(months, id: \.self) { month in
                            if let contactsForMonth = filteredContacts[month], !contactsForMonth.isEmpty {
                                Section(header: Text(DateFormatter().monthSymbols[month - 1])) {
                                    ForEach(contactsForMonth) { contact in
                                        
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(birthdates.isBirthdayToday(birthday: contact.birthday!) ? "\(contact.name) 🎂" : contact.name)
                                                    .font(.headline)
                                                Text("\(birthdates.birthdayText(for: contact.birthday ?? Date()))")
                                                    .font(.subheadline)
                                                
                                              
                                            }
                                            .foregroundStyle(.black)
                                            Spacer()
                                            if birthdates.birthdayText(for: contact.birthday!) == "Today" {
                                                Button {
                                                    if selectedContact == contact {
                                                        // Reset the selected person to nil before reassigning
                                                        selectedContact = nil
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                            selectedContact = contact
                                                        
                                                        }
                                                    } else {
                                                        selectedContact = contact
                                                        
                                                    }
                                                } label: {
                                                    Label("", systemImage: "sparkles")
                                                        .foregroundStyle(.purple)
                                                        .symbolEffect(.breathe)
                                                }
                                                
                                            }
                                                
                                            
                                            if let birthday = contact.birthday {
                                                if birthdates.birthdayText(for: contact.birthday!) != "Today" {
                                                    HStack {
                                                        Text("\(birthdates.daysUntilBirthday(from: Date(), to: birthday)) days")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                        Image(systemName: "arrow.down")
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        .swipeActions(edge: .leading) {
                                            if let phoneNumber = contact.phoneNumber {
                                                Button {
                                                    callAndMessage.callPhoneNumber(phoneNumber)
                                                } label: {
                                                    Label("Call", systemImage: "phone.fill")
                                                }
                                                .tint(.green)
                                                
                                                Button {
                                                    callAndMessage.messagePhoneNumber(phoneNumber, withText: "Happy Birthday, \(contact.name) 🎂🎈")
                                                } label: {
                                                    Label("Message", systemImage: "message.fill")
                                                }
                                                .tint(.blue)
                                            }
                                            Button {
                                                if selectedContact == contact {
                                                    // Reset the selected person to nil before reassigning
                                                    selectedContact = nil
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        selectedContact = contact
                                                    
                                                    }
                                                } else {
                                                    selectedContact = contact
                                                    
                                                }
                                            } label: {
                                                Label("Wish", systemImage: "sparkles")
                                            }
                                            .tint(.purple)
                                        }
                                        
                                        .listRowBackground(Color.white.opacity(0.5))
                                    }
                                    .onDelete(perform: deletePerson)
                                }
                            }
                            
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search for a Birthday...")
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Birthdays")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddView = true
                        } label: {
                            Label("Add Birthday", systemImage: "person.crop.circle.fill.badge.plus")
                        }
                        
                        Button {
                            bounce.toggle()
                            fetchContacts()
                        } label: {
                            Label("Sync Contacts", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                        }
                    } label: {
                        Label("Menu", systemImage: "plus")
                        
                    }
                    .tint(.green)
                }
                
            }
            .sheet(isPresented: $showingAddView) {
                AddContactView()
            }
            .sheet(isPresented: $isShowingDetail) {
                if let selectedContact = selectedContact {
                    WishView(contact: selectedContact)
                        .presentationDetents([.fraction(0.7), .medium])
                }
            }
            .onChange(of: selectedContact) { _ in
                isShowingDetail = selectedContact != nil
            }
        }
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
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                
                var fetchedContacts: [Contact] = []
                do {
                    try store.enumerateContacts(with: request) { contact, stop in
                        let name = "\(contact.givenName) \(contact.familyName)"
                        let number = contact.phoneNumbers.first?.value.stringValue
                        if let birthdate = contact.birthday?.date {
                            // Get the next day's date
                            let calendar = Calendar.current
                            if let nextDay = calendar.date(byAdding: .day, value: 1, to: birthdate) {
                                // Trim white spaces from the name
                                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                let newContact: Contact
                                if number == nil {
                                    newContact = Contact(id: UUID(), name: trimmedName, birthday: nextDay)
                                } else {
                                    newContact = Contact(id: UUID(), name: trimmedName, birthday: nextDay, phoneNumber: number)
                                }
                                
                                fetchedContacts.append(newContact)
                                
                                let components = calendar.dateComponents([.month, .day], from: nextDay)
                                let month = components.month!
                                let day = components.day!
                                
                                modelContext.insert(newContact)
                                notifications.addNotification(for: newContact, at: month, day: day)
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
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    
}



#Preview {
    ContentView()
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
