//
//  Contacts.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//

import Foundation
import SwiftData

@Model
class Contacts: Identifiable {
    var id = UUID()
    var name: String
    var birthday: Date
    
    init(id: UUID = UUID(), name: String, birthday: Date) {
        self.id = id
        self.name = name
        self.birthday = birthday
    }
}
