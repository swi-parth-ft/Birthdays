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
        NavigationStack {
            ZStack {
                
                LinearGradient(colors: [Color(hex: "#D2FFDC"), Color(hex: "#1B231C")], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                Form {
                    Section("Details") {
                        TextField("Name", text: $name)
                        TextField("Number", text: $number)
                            .keyboardType(.numberPad)
                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    }
                    .listRowBackground(Color.white.opacity(0.4))
                    
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Add new Birthday")
            .toolbar {
                Button("", systemImage: "plus") {
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
                .tint(.green)
            }
        }
    }
    
    
    
    
}

#Preview {
    AddContactView()
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
