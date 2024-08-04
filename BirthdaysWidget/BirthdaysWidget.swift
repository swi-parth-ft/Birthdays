import WidgetKit
import SwiftUI

struct BirthdaysEntry: TimelineEntry {
    let date: Date
    let contacts: [Contacts]
}

struct BirthdaysProvider: TimelineProvider {
    func placeholder(in context: Context) -> BirthdaysEntry {
        BirthdaysEntry(date: Date(), contacts: [
            Contacts(id: UUID(), name: "John Doe", birthday: Date())
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (BirthdaysEntry) -> Void) {
        let entry = BirthdaysEntry(date: Date(), contacts: fetchContacts())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BirthdaysEntry>) -> Void) {
        let entry = BirthdaysEntry(date: Date(), contacts: fetchContacts())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func fetchContacts() -> [Contacts] {
        // Fetch contacts from your data source
        // For now, returning static data
        let contacts = [
            Contacts(id: UUID(), name: "John Doe", birthday: Date()),
            Contacts(id: UUID(), name: "Jane Doe", birthday: Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
            Contacts(id: UUID(), name: "Sam Smith", birthday: Calendar.current.date(byAdding: .day, value: 2, to: Date())!)
        ]
        
        let sortedContacts = contacts.sorted { ($0.birthday ?? Date()) < ($1.birthday ?? Date()) }
        return Array(sortedContacts.prefix(3))
    }
}

struct BirthdaysWidgetEntryView : View {
    var entry: BirthdaysProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(entry.contacts) { contact in
                VStack(alignment: .leading) {
                    Text(contact.name)
                        .font(.headline)
                    if let birthday = contact.birthday {
                        Text("Birthday: \(birthday, formatter: DateFormatter.shortDate)")
                            .font(.subheadline)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding()
    }
}

@main
struct BirthdaysWidget: Widget {
    let kind: String = "BirthdaysWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BirthdaysProvider()) { entry in
            BirthdaysWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Latest Birthdays")
        .description("Displays the latest 3 birthdays from your contacts.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
