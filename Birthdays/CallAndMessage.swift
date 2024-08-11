//
//  CallAndMessage.swift
//  Birthdays
//
//  Created by Parth Antala on 8/10/24.
//

import Foundation
import UIKit

class CallAndMessage {
    func callPhoneNumber(_ phoneNumber: String) {
        let phoneURL = URL(string: "tel://\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            // Handle error if the phone cannot open the URL
            print("Cannot make a call on this device.")
        }
    }
    
    func messagePhoneNumber(_ phoneNumber: String, withText text: String) {
        // Encode the text to be URL-safe
        
        let messageURLString = "sms:\(phoneNumber)&body=\(text)"
        
        if let messageURL = URL(string: messageURLString) {
            if UIApplication.shared.canOpenURL(messageURL) {
                UIApplication.shared.open(messageURL, options: [:], completionHandler: nil)
            } else {
                print("Cannot send a message on this device.")
            }
        } else {
            print("Invalid URL.")
        }
    }
}
