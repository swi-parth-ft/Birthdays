//
//  AddNotifications.swift
//  Birthdays
//
//  Created by Parth Antala on 8/6/24.
//

import Foundation
import UserNotifications

class AddNotifications {
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
            dateComponents.minute = 09
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
