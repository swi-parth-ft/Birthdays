//
//  BirthdaysApp.swift
//  Birthdays
//
//  Created by Parth Antala on 8/4/24.
//

import SwiftUI
import SwiftData

@main
struct BirthdaysApp: App {
    
    @State var contactToCall: Contact?
        @State var contactToMessage: Contact?
    @Query var contacts: [Contact]
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Contact.self)
                .onOpenURL { url in
                                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                                       let host = components.host,
                                       let queryItems = components.queryItems,
                                       let phoneNumber = queryItems.first(where: { $0.name == "phoneNumber" })?.value {
                                        if host == "call" {
                                            callPhoneNumber(phoneNumber)
                                        } else if host == "message" {
                                            messagePhoneNumber(phoneNumber)
                                        }
                                    }
                                }
                        }
                    }
                    
                    func callPhoneNumber(_ phoneNumber: String) {
                        let phoneURL = URL(string: "tel://\(phoneNumber)")!
                        if UIApplication.shared.canOpenURL(phoneURL) {
                            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                        }
                    }
                    
                    func messagePhoneNumber(_ phoneNumber: String) {
                        let messageURL = URL(string: "sms:\(phoneNumber)")!
                        if UIApplication.shared.canOpenURL(messageURL) {
                            UIApplication.shared.open(messageURL, options: [:], completionHandler: nil)
                        }
                    }
}
