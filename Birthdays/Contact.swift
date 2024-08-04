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
    var image: Data

    
    init(id: UUID = UUID(), name: String, birthday: Date, image: Data) {
        self.id = id
        self.name = name
        self.birthday = birthday
        self.image = image
    }
}
