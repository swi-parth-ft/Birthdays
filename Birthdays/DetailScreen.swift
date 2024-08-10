//
//  DetailScreen.swift
//  Birthdays
//
//  Created by Parth Antala on 8/9/24.
//

import SwiftUI

struct DetailScreen: View {
    var contact: Contact
    
    var birthdates = Birthdates()
    var birthdayText: String
    init(contact: Contact) {
        self.contact = contact
            birthdayText = birthdates.birthdayText(for: contact.birthday!)
        
    }
    var body: some View {
        NavigationStack {
            ZStack {
                
                LinearGradient(colors: [Color(hex: "#D2FFDC"), Color(hex: "#1B231C")], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 22)
                    .padding()
                    .foregroundColor(Color.white.opacity(0.5))
                    .frame(width: 400, height: 400)
                    .shadow(radius: 10)
                
                VStack(alignment: .center) {
                    if birthdayText == "Today" {
                        Text("Birthday's \(birthdayText)!")
                            .font(.title)
                            .fontWeight(.semibold)
                          
                            .foregroundColor(.white)
                        Text("Let's pop some confetti 🎉")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom)
                        
                    } else if birthdayText == "Tomorrow" {
                        Text("Birthday's \(birthdayText)")
                            .font(.title)
                            .fontWeight(.semibold)
                          
                            .foregroundColor(.white)
                        Text("Let's plan ahead by preparing wishes for \(contact.name)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom)
                    } else {
                        Text("Birthday's on \(birthdayText)")
                            .font(.title)
                            .fontWeight(.semibold)
                          
                            .foregroundColor(.white)
                        Text("Let's plan ahead by preparing wishes for \(contact.name)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom)
                    }
                    
                    Spacer()
                    
                    if contact.phoneNumber != nil {
                        
                        VStack {
                            Button("Call", systemImage: "phone") {
                                callPhoneNumber(contact.phoneNumber!)
                            }
                            .padding()
                            .frame(width: 200)
                            .background(Color.green)
                            .cornerRadius(22)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            
                            
                            Button("Message", systemImage: "message") {
                                messagePhoneNumber(contact.phoneNumber!)
                            }
                            .padding()
                            .frame(width: 200)
                            .background(.blue)
                            .cornerRadius(22)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                        }
                    }
                    NavigationLink(destination: WishView(contact: contact)) {
                        Button("Wish", systemImage: "sparkles") { }
                            .padding()
                            .frame(width: 200)
                            .background(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(22)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                }
                .frame(width: 350, height: 300)
            }
            .navigationTitle(contact.name)
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
