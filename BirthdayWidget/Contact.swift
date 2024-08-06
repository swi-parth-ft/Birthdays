//
//  Contact.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//
import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

@Model
class Contact: Identifiable {
    var id = UUID()
        @Attribute(.unique) var name: String
        var birthday: Date?
        var phoneNumber: String?

    init(id: UUID = UUID(), name: String, birthday: Date, phoneNumber: String? = nil) {
            self.id = id
            self.name = name
            self.birthday = birthday
            self.phoneNumber = phoneNumber
        }
}
