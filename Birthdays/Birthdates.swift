//
//  Birthdates.swift
//  Birthdays
//
//  Created by Parth Antala on 8/10/24.
//

import Foundation

class Birthdates {
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM" // Set to display month and day only
        return formatter
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
    
    func isBirthdayToday(birthday: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.month, .day], from: today)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        
        return todayComponents.month == birthdayComponents.month && todayComponents.day == birthdayComponents.day
    }
}
