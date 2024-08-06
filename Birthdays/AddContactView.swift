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
    @Environment(\.dismiss) var dismiss
    @Query var contacts: [Contact]
    @State private var name = ""
    @State private var birthday = Date()
    @State private var number = ""
    @State private var defaultImageData: Data = UIImage(systemName: "person")!.jpegData(compressionQuality: 1.0)!
    var notifications = AddNotifications()
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Number", text: $number)
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            Button("Add Contact") {
                let new: Contact
                if number.isEmpty {
                    new = Contact(name: name, birthday: birthday)
                } else {
                    new = Contact(name: name, birthday: birthday, phoneNumber: number)
                }
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.month, .day], from: new.birthday!)
                let month = components.month!
                let day = components.day!
                
                modelContext.insert(new)
                notifications.addNotification(for: new, at: month, day: day)
                try? modelContext.save()
                WidgetCenter.shared.reloadAllTimelines()
                dismiss()
            }
            
        }
    }
    
    
}

#Preview {
    AddContactView()
}
