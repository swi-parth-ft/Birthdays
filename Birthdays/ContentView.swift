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
    
    @State private var showingAddView = false
    @State private var bounce = false
    @State private var searchText = ""
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
                                                Text(isBirthdayToday(birthday: contact.birthday!) ? "\(contact.name) 🎂" : contact.name)
                                                    .font(.headline)
                                                Text("\(birthdayText(for: contact.birthday ?? Date()))")
                                                    .font(.subheadline)
                                            }
                                            Spacer()
                                            if let birthday = contact.birthday {
                                                HStack {
                                                    
                                                    Text("\(daysUntilBirthday(from: Date(), to: birthday)) days")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                    Image(systemName: "arrow.down")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                        .listRowBackground(Color.white.opacity(0.5))
                                        .swipeActions(edge: .leading) {
                                            if let phoneNumber = contact.phoneNumber {
                                                Button {
                                                    callPhoneNumber(phoneNumber)
                                                } label: {
                                                    Label("Call", systemImage: "phone.fill")
                                                }
                                                .tint(.green)
                                                
                                                Button {
                                                    messagePhoneNumber(phoneNumber)
                                                } label: {
                                                    Label("Message", systemImage: "message.fill")
                                                }
                                                .tint(.blue)
                                            }
                                        }
                                    }
                                    .onDelete(perform: deletePerson)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search for a item")
                }
                }
                    .scrollContentBackground(.hidden)
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
            }
        }
        
        func callPhoneNumber(_ phoneNumber: String) {
            let phoneURL = URL(string: "tel://\(phoneNumber)")!
            if UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            } else {
                // Handle error if the phone cannot open the URL
                print("Cannot make a call on this device.")
            }
        }
        
        func messagePhoneNumber(_ phoneNumber: String) {
            let messageURL = URL(string: "sms:\(phoneNumber)")!
            if UIApplication.shared.canOpenURL(messageURL) {
                UIApplication.shared.open(messageURL, options: [:], completionHandler: nil)
            } else {
                print("Cannot send a message on this device.")
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
        
        
        func birthdayText(for date: Date) -> String {
            let calendar = Calendar.current
            let today = Date()
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            let startOfWeek = calendar.nextDate(after: today, matching: .init(weekday: calendar.firstWeekday), matchingPolicy: .nextTime)!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            
            let birthdayComponents = calendar.dateComponents([.month, .day], from: date)
            let todayComponents = calendar.dateComponents([.month, .day], from: today)
            let tomorrowComponents = calendar.dateComponents([.month, .day], from: tomorrow)
            
            if birthdayComponents == todayComponents {
                return "Today"
            } else if birthdayComponents == tomorrowComponents {
                return "Tomorrow"
            } else if isDateInThisWeek(date) {
                let weekday = calendar.component(.weekday, from: today)
                let targetDate = calendar.nextDate(after: today, matching: birthdayComponents, matchingPolicy: .nextTimePreservingSmallerComponents) ?? date
                let targetWeekday = calendar.component(.weekday, from: targetDate)
                return "This \(calendar.weekdaySymbols[targetWeekday - 1])"
            } else {
                return dateFormatter.string(from: date)
            }
        }
        
        func isDateInThisWeek(_ date: Date) -> Bool {
            let calendar = Calendar.current
            let today = Date()
            
            guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
                return false
            }
            
            let startOfWeekComponents = calendar.dateComponents([.month, .day], from: startOfWeek)
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            let endOfWeekComponents = calendar.dateComponents([.month, .day], from: endOfWeek)
            let dateComponents = calendar.dateComponents([.month, .day], from: date)
            
            return (dateComponents.month! > startOfWeekComponents.month! ||
                    (dateComponents.month! == startOfWeekComponents.month! && dateComponents.day! >= startOfWeekComponents.day!)) &&
            (dateComponents.month! < endOfWeekComponents.month! ||
             (dateComponents.month! == endOfWeekComponents.month! && dateComponents.day! <= endOfWeekComponents.day!))
        }
        
        func daysUntilBirthday(from startDate: Date, to endDate: Date) -> Int {
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.month, .day], from: startDate)
            let endComponents = calendar.dateComponents([.month, .day], from: endDate)
            
            let startMonth = startComponents.month!
            let startDay = startComponents.day!
            let endMonth = endComponents.month!
            let endDay = endComponents.day!
            
            var daysUntil = (endMonth - startMonth) * 30 + (endDay - startDay)
            
            if daysUntil < 0 { // If the birthday is before today, adjust to next year
                daysUntil += 365
            }
            
            return daysUntil
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
