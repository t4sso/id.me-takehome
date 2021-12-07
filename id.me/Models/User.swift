//
//  User.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/4/21.
//

import Foundation

struct User: Hashable, Equatable {
    let name: String
    let userName: String
    let fullName: String
    let phoneNumber: String?
    let registration: String?
    let imageURL: String?
}
