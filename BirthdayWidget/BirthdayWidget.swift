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
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
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
            .prefix(5))
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
                ForEach(Array(upcomingContacts.enumerated()), id: \.element.id) { index, con in
                    HStack(alignment: .bottom) {
                        Text(con.name)
                            .font(.system(size: 20 - CGFloat(index * 2)))
                            .fontWeight(index == 0 ? .bold : (index == 1 ? .semibold : (index == 2 ? .medium : (index == 3 ? .regular : (index == 4 ? .light : .thin)))))
                        Spacer()
                        Text(birthdayText(for: con.birthday ?? Date()))
                            .font(.system(size: 20 - CGFloat(index * 2)))
                            .fontWeight(index == 0 ? .bold : (index == 1 ? .semibold : (index == 2 ? .medium : (index == 3 ? .regular : (index == 4 ? .light : .thin)))))
                    }
                    .padding([.top, .bottom], 0.1)
                }
            }
            .padding()
            .foregroundColor(.white)
        }
        .widgetBackground {
            LinearGradient(colors: [.pink, .orange, .yellow], startPoint: .topTrailing, endPoint: .bottomLeading)
        }
        
    }
}

struct BirthdayWidget: Widget {
    let kind: String = "BirthdayWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BirthdayWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !!q
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

#Preview(as: .systemSmall) {
    BirthdayWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
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

