//
//  Contact.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//
import SwiftUI
import SwiftData

@Model
class Contact: Identifiable {
    var id = UUID()
    @Attribute(.unique) var name: String
    var birthday: Date?
    
    init(id: UUID = UUID(), name: String, birthday: Date) {
        self.id = id
        self.name = name
        self.birthday = birthday
    }
    
    static var upcomingBirthdaySortDescriptor: NSSortDescriptor {
            return NSSortDescriptor(key: "birthday", ascending: true, comparator: { (date1, date2) -> ComparisonResult in
                guard let birthday1 = date1 as? Date, let birthday2 = date2 as? Date else {
                    return .orderedSame
                }
                
                let calendar = Calendar.current
                let today = Date()
                
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
                
                if daysFromToday1 < daysFromToday2 {
                    return .orderedAscending
                } else if daysFromToday1 > daysFromToday2 {
                    return .orderedDescending
                } else {
                    return .orderedSame
                }
            })
        }
}

