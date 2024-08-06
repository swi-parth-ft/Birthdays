//
//  AddContactView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//

import SwiftUI
import SwiftData
import WidgetKit
import UserNotifications

struct AddContactView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contact]
    @State private var name = ""
    @State private var birthday = Date()
    @State private var defaultImageData: Data = UIImage(systemName: "person")!.jpegData(compressionQuality: 1.0)!
    
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            Button("Add Contact") {
                let new = Contact(name: name, birthday: birthday)
                let calendar = Calendar.current
                let components = calendar.dateComponents([.month, .day], from: new.birthday!)
                let month = components.month!
                let day = components.day!
                
                modelContext.insert(new)
                addNotification(for: new, at: month, day: day)
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
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
    AddContactView()
}
