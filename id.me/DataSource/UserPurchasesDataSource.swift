//
//  UserPurchasesDataSource.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/5/21.
//

import UIKit.UIImage
import Combine

/// Provider of access to user's purchase information
protocol UserPurchasesDataSource {
    
    var userID: String { get }
    func getUserPurchasesInformation() -> AnyPublisher<[Purchase], Error>
    
    /**
     Access a preview image for a particular purchase
     
     - Parameter item: Associated purchased item
     - Returns Combine publisher that will produce the resulting image once
     */
    func getUserPurchaseItemPhoto(purchase: Purchase) -> AnyPublisher<UIImage, Error>
}

/// Implements `UserPurchasesDataSource` using requests to the id.me API and adapts the response to the `User` data model.
class IDUserPurchasesDataSource: UserPurchasesDataSource {
    
    var userID: String
    /// `URLSession` used for requests to the purchases service
    let urlSession = URLSession.shared
    
    /// Base URL for Company user requests
    private let baseUrl = "https://idme-takehome.proxy.beeceptor.com"
    private var purchasesPath: String {
        return "/purchases/\(userID)"
    }
    
    init(userID: String) {
        self.userID = userID
    }
    
    /// Request user from the data source.
    func getUserPurchasesInformation() -> AnyPublisher<[Purchase], Error> {
        
        var urlComps = URLComponents()
        urlComps.scheme = "https"
        urlComps.host = "idme-takehome.proxy.beeceptor.com"
        urlComps.path = purchasesPath
        let queryItem = URLQueryItem(name: "page", value: "1") // TODO: Add pagination
        urlComps.queryItems = [queryItem]
        guard let usersPurchasesUrl = urlComps.url else {
            return Fail(error: DataSourceError.invalidArgument)
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: usersPurchasesUrl)
            .map(\.data)
            .decode(type: Array<APIPurchase>.self, decoder: JSONDecoder())
            .map { response in
                // Convert from the APIPurchase model to the application model for Purchases.
                return response
                    .map { $0.toUserPurchase() }
                    .compactMap{ $0 }
            }
            .eraseToAnyPublisher()
    }
    
    /// Access the profile photo for a particular user.
    func getUserPurchaseItemPhoto(purchase: Purchase) -> AnyPublisher<UIImage, Error> {
        
        guard let photoURL = URL(string: purchase.imageURL) else {
            return Fail(error: DataSourceError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: photoURL)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw DataSourceError.requestFailed
                }
                guard let image = UIImage(data: output.data) else {
                    throw DataSourceError.decodingFailed
                }
                return image
            }
            .eraseToAnyPublisher()
    }
}


