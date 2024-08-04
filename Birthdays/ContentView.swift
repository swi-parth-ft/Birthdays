//
//  ContentView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//

import SwiftUI
import SwiftData
import Contacts

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var contacts: [Contact]
    @State private var showingAddView = false
    @State private var defaultImageData: Data = UIImage(systemName: "person")!.jpegData(compressionQuality: 1.0)!
    
    var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd" // Set to display month and day only
            return formatter
        }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(contacts) { contact in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(.headline)
                            Text("\(contact.birthday ?? Date.now, formatter: dateFormatter)")
                                .font(.subheadline)
                        }
                        Spacer()
                        Image(uiImage: UIImage(data: contact.image)!)
                            .resizable()
                            .frame(width: 50, height: 50)
                            
                    }
                }
                .onDelete(perform: deleteBirthday)
            }
            .navigationTitle("Birthdays")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    showingAddView = true
                }
                Button("Sync") {
                    fetchContacts()
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddContactView()
            }
        }
    }
    
    func deleteBirthday(at offsets: IndexSet) {
        for index in offsets {
            let contact = contacts[index]
            modelContext.delete(contact)
        }
    }
    
    
    private func fetchContacts() {
           let store = CNContactStore()
           store.requestAccess(for: .contacts) { granted, error in
               if granted {
                   let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactImageDataKey] as [CNKeyDescriptor]
                   let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                   
                   var fetchedContacts: [Contact] = []
                   do {
                       try store.enumerateContacts(with: request) { contact, stop in
                           let name = "\(contact.givenName) \(contact.familyName)"
                           if let birthdate = contact.birthday?.date {
                               let image = contact.imageData
                               let new = Contact(id: UUID(), name: name, birthday: birthdate, image: image ?? defaultImageData)
                                   fetchedContacts.append(new)
                                   
                                   modelContext.insert(new)
                                   try? modelContext.save()
                               
                                   
                               
                               
                           }
                       }
                   
                   } catch {
                       print("Failed to fetch contacts: \(error)")
                   }
                   
               } else {
                   print("Access to contacts was denied.")
               }
           }
       }
}



#Preview {
    ContentView()
}
