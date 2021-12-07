//
//  UserProfileDataSource.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/4/21.
//

import Combine
import UIKit.UIImage

/// Specific error types that can be produced when accessing data from the API
enum DataSourceError: Error {
    case invalidURL
    case invalidArgument
    case requestFailed
    case decodingFailed
}

/// Provider of access to user information
protocol UserDataSource {
    
    var userID: String { get }
    func getUserInformation() -> AnyPublisher<User, Error>
    
    /**
     Access a preview image for a particular user
     
     - Parameter user: Associated user
     - Returns Combine publisher that will produce the resulting image once
     */
    func getUserPhoto(user: User) -> AnyPublisher<UIImage, Error>
}

/// Implements `UserDataSource` using requests to the id.me API and adapts the response to the `User` data model.
class IDUserDataSource: UserDataSource {
  
    var userID: String
    /// `URLSession` used for requests to the profile service
    let urlSession = URLSession.shared
    
    /// Base URL for Company user requests
    private let baseUrl = URL(string: "https://idme-takehome.proxy.beeceptor.com")
    private var userPath: String {
        return "profile/\(userID)"
    }
    
    init(userID: String) {
        self.userID = userID
    }
   
    /// Request user from the data source.
    func getUserInformation() -> AnyPublisher<User, Error> {
        guard let userUrl = baseUrl?.appendingPathComponent(userPath) else {
            return Fail(error: DataSourceError.invalidURL)
                .eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: userUrl)
            .map(\.data)
            .decode(type: APIUser.self, decoder: JSONDecoder())
            .tryMap { response in
                // Convert from the UserAPI model to the application model for user.
                guard let user = response.toUser() else {
                    throw DataSourceError.decodingFailed
                }
                return user
            }
            .eraseToAnyPublisher()
    }
    
    /// Access the profile photo for a particular user.
    func getUserPhoto(user: User) -> AnyPublisher<UIImage, Error> {
        
        guard let profileImageReference = user.imageURL,
              let photoURL = URL(string: profileImageReference) else {
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

