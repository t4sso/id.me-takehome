//
//  UserResponse.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/4/21.
//

import Foundation

struct APIUser: Decodable {
    
    let name: String
    let userName: String
    let fullName: String
    let phoneNumber: String?
    let registration: String?
    let imageURL: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case userName = "user_name"
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case registration
        case imageURL = "image"
    }
}

// MARK: - Data model conversion

extension APIUser {

    /// Convert the APIUser type to a domain model user.
    func toUser() -> User? {
        // Establish required fields for the user

        return User(name: name,
                    userName: userName,
                    fullName: fullName,
                    phoneNumber: phoneNumber,
                    registration: registration,
                    imageURL: imageURL)

    }
}

