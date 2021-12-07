//
//  UserViewModel.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/4/21.
//

import Combine
import UIKit.UIImage

/// View model providing the bindings required to display the user data
class UserProfileViewModel: ObservableObject {
    
    private let userProfileDataSource: UserDataSource
    let userID: String
    
    /// User profile data
    @Published private(set) var user: User?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userID: String) {
        self.userID = userID
        userProfileDataSource = IDUserDataSource(userID: userID)
    }
    /**
     Access the profile image for the user.
     
     - Parameter user: user reference for accessing the image
     - Parameter maxWidth: maximum width of the image, used to drive requested level of detail of the returned image
    */
    func getUserPhoto(user: User) -> AnyPublisher<UIImage, Error> {
        return userProfileDataSource.getUserPhoto(user: user)
    }
    
    /**
     Fetch a user profile. Results are published to the user property

     */
    func getUserInformation() {

        userProfileDataSource
            .getUserInformation()
            .sink { [weak self] (completion) in
                guard let self = self else { return }

                switch completion {
                case .failure(let err):
                    print("failed to load user data with: \(err)")
                    self.user = nil
                case .finished:
                    break
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                self.user = user
            }.store(in: &cancellables)
    }
}
