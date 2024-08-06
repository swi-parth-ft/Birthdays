//
//  BirthdayWidget.swift
//  BirthdayWidget
//
//  Created by Parth Antala on 8/4/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of entries that update every day at midnight
        let currentDate = Date()
        let calendar = Calendar.current
        let nextMidnight = calendar.nextDate(after: currentDate, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime)!
        
        // Create an entry for the current time
        let currentEntry = SimpleEntry(date: currentDate, configuration: configuration)
        entries.append(currentEntry)
        
        // Create an entry for the next midnight
        let midnightEntry = SimpleEntry(date: nextMidnight, configuration: configuration)
        entries.append(midnightEntry)
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}



struct BirthdayWidgetEntryView : View {
    var entry: Provider.Entry
    @Query(sort: \Contact.birthday, order: .reverse) var contact: [Contact]
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }
    
    var upcomingContacts: [Contact] {
        let today = Date()
        return Array(contact.filter { $0.birthday != nil }
            .sorted { (c1, c2) -> Bool in
                let calendar = Calendar.current
                guard let birthday1 = c1.birthday, let birthday2 = c2.birthday else {
                    return false
                }
                let components1 = calendar.dateComponents([.month, .day], from: birthday1)
                let components2 = calendar.dateComponents([.month, .day], from: birthday2)
                
                if let month1 = components1.month, let day1 = components1.day,
                   let month2 = components2.month, let day2 = components2.day {
                    if month1 == month2 {
                        return day1 < day2
                    } else {
                        return month1 < month2
                    }
                }
                return false
            }
            .filter {
                let birthdayComponents = Calendar.current.dateComponents([.month, .day], from: $0.birthday!)
                let todayComponents = Calendar.current.dateComponents([.month, .day], from: today)
                return (birthdayComponents.month! > todayComponents.month!) ||
                (birthdayComponents.month! == todayComponents.month! && birthdayComponents.day! >= todayComponents.day!)
            }
            .prefix(4))
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
            return calendar.weekdaySymbols[targetWeekday - 1]
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
    
    
    
    var body: some View {
        ZStack {
            VStack {
                if let todayBirthdayContact = upcomingContacts.first(where: {
                    Calendar.current.isDateInToday($0.birthday!)
                }) {
                    // Display the contact whose birthday is today
                    HStack(alignment: .bottom) {
                        VStack {
                            Text("Today is,")
                                .font(.subheadline)
                                .shadow(radius: 5)
                            Text("\(todayBirthdayContact.name.trimmingCharacters(in: .whitespacesAndNewlines))'s Birthday")
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .shadow(radius: 5)
                        }
                    }
                    .padding([.top, .bottom], 0.1)
                    
                    Spacer()
                    
                    // Display the next two contacts
                    ForEach(Array(upcomingContacts.prefix(2).enumerated()), id: \.element.id) { index, con in
                        if con.id != todayBirthdayContact.id {
                            HStack(alignment: .bottom) {
                                Text(con.name)
                                Spacer()
                                Text(birthdayText(for: con.birthday ?? Date()))
                            }
                            
                        }
                    }
                } else {
                    Text("Next Birthdays, 🎈")
                    Spacer()
                    VStack(alignment: .leading, spacing: 2) {
                
                    ForEach(Array(upcomingContacts.enumerated()), id: \.element.id) { index, con in
                      
                        Text("\(con.name)'s,  \(birthdayText(for: con.birthday ?? Date()))")
                            .font(.system(size: 25 - CGFloat(index * 5)))
                            .fontWeight(.semibold)
                            .opacity(1 - (0.75 * Double(index) / Double(upcomingContacts.count - 1)))
                            .shadow(radius: 5)
                            .alignmentGuide(.leading) { d in d[.leading] }
                        
                        if index < upcomingContacts.count - 1 {
                                        Divider()
                                            .background(Color.gray)
                                           
                                    }
                    }
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .foregroundColor(.white)
        }
        
        .widgetBackground {
            Group {
                if upcomingContacts.contains(where: { Calendar.current.isDateInToday($0.birthday!) }) {
                    Image("BirthdayBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFill()
                        .clipped()
                        .overlay(
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                        )
                } else {
                    LinearGradient(colors: [Color(hex: "#D2FFDC"), Color(hex: "#1B231C")], startPoint: .top, endPoint: .bottom)
                }
            }
        }
        
    }
}

struct BirthdayWidget: Widget {
    let kind: String = "BirthdayWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BirthdayWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modelContainer(for: [Contact.self])
        }
        
        
        
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

struct BirthdayWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let today = Date()
        let mockContacts = [
            Contact(id: UUID(), name: "Alice", birthday: today),
            Contact(id: UUID(), name: "Bob", birthday: Calendar.current.date(byAdding: .day, value: 1, to: today)!),
            Contact(id: UUID(), name: "Charlie", birthday: Calendar.current.date(byAdding: .day, value: 2, to: today)!),
            Contact(id: UUID(), name: "David", birthday: Calendar.current.date(byAdding: .day, value: 3, to: today)!),
            Contact(id: UUID(), name: "Eve", birthday: Calendar.current.date(byAdding: .day, value: 4, to: today)!)
        ]
        
        let entry = SimpleEntry(date: .now, configuration: .smiley)
        let view = BirthdayWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        return view
        // Simulate providing data for the preview
        
    }
}



extension View {
    @ViewBuilder func widgetBackground<T: View>(@ViewBuilder content: () -> T) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget, content: content)
        }else {
            background(content())
        }
    }
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
