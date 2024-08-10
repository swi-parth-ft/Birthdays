//
//  DetailScreen.swift
//  Birthdays
//
//  Created by Parth Antala on 8/9/24.
//

import SwiftUI

struct DetailScreen: View {
    var contact: Contact
    
    var body: some View {
        ZStack {
            VStack {
                Text(contact.name)
                    .font(.title)
                Text(contact.birthday!.description)
                
                if contact.phoneNumber != nil {
                    
                    Text(contact.phoneNumber ?? "6478060801")
                    
                    Button("Call") {
                        callPhoneNumber(contact.phoneNumber!)
                    }
                    
                    Button("Message") {
                        messagePhoneNumber(contact.phoneNumber!)
                    }
                }
                
                Button("Wish") {
                    
                }
            }
        }
    }
    
    func callPhoneNumber(_ phoneNumber: String) {
        let phoneURL = URL(string: "tel://\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            // Handle error if the phone cannot open the URL
            print("Cannot make a call on this device.")
        }
    }
    
    func messagePhoneNumber(_ phoneNumber: String) {
        let messageURL = URL(string: "sms:\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(messageURL) {
            UIApplication.shared.open(messageURL, options: [:], completionHandler: nil)
        } else {
            print("Cannot send a message on this device.")
        }
    }
}

#Preview {
    DetailScreen(contact: Contact(id: UUID(), name: "Parth", birthday: Date(), phoneNumber: "6478060801"))
}
