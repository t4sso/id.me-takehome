//
//  UserPurchasesResponse.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/5/21.
//

import Foundation

struct APIPurchase: Decodable {
    
    let imageURL: String
    let purchaseDate: String
    let itemName: String
    let price: String
    let serialNumber: String?
    let description: String?
    
    private enum CodingKeys: String, CodingKey {
        case imageURL = "image"
        case purchaseDate = "purchase_date"
        case itemName = "item_name"
        case price
        case serialNumber = "serial"
        case description
    }
}

// MARK: - Data model conversion

extension APIPurchase {
    
    /// Convert the APIPurchase type to a domain model purchase.
    func toUserPurchase() -> Purchase? {
        // Establish required fields for the user
        
        return Purchase(imageURL: imageURL,
                        purchaseDate: purchaseDate,
                        itemName: itemName.htmlDecoded,
                        price: price,
                        serialNumber: serialNumber,
                        description: description?.htmlDecoded)
    }
}

