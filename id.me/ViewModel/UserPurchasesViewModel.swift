//
//  UserPurchasesViewModel.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/5/21.
//

import UIKit.UIImage
import Combine

/// View model providing the bindings required to display user's purchases
class UserPurchasesViewModel: ObservableObject {
    
    private let userPurchasesDataSource: UserPurchasesDataSource
    
    /// User purchases  data with appropriate sorting and filtering.
    @Published private(set) var purchases: [Purchase]?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userID: String) {
        userPurchasesDataSource = IDUserPurchasesDataSource(userID: userID)
        userPurchasesDataSource
            .getUserPurchasesInformation()
            .sink { [weak self] (completion) in
                guard let self = self else { return }
                
                switch completion {
                case .failure(let err):
                    print("failed to load purchase data with: \(err)")
                    self.purchases = nil
                case .finished:
                    break
                }
            } receiveValue: { [weak self] purchases in
                guard let self = self else { return }
                self.purchases = purchases
            }.store(in: &cancellables)
    }
    /**
     Access the title image for the purchase.
     
     - Parameter purchase: user's purchase reference for accessing the image
    */
    func getPurchaseItemImage(purchase: Purchase) -> AnyPublisher<UIImage, Error> {
        return userPurchasesDataSource.getUserPurchaseItemPhoto(purchase: purchase)
    }
}



