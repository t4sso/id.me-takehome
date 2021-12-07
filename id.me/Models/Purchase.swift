//
//  Purchase.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/5/21.
//

import Foundation

struct Purchase: Hashable, Equatable {
    let imageURL: String
    let purchaseDate: String
    let itemName: String
    let price: String
    let serialNumber: String?
    let description: String?
}
