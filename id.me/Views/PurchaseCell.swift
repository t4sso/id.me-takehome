//
//  PurchaseCell.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/5/21.
//

import Combine
import UIKit

/// Purchase view cell for a user's purchase
class PurchaseCell: UITableViewCell {
    
    private var itemImageView = UIImageView(cornerRadius: 25)
    private var purchaseDateLabel = UILabel()
    private var itemNameLabel = UILabel()
    private var priceLabel = UILabel()
    private var serialNumberLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var titleStackView = UIStackView()
    private var expandedStackView = UIStackView()
    
    var showFullDetails = false {
        didSet {
            if !showFullDetails {
                titleStackView.removeArrangedSubview(expandedStackView)
                expandedStackView.removeFromSuperview()
            } else {
                titleStackView.addArrangedSubview(expandedStackView)
            }
        }
    }

    
    var purchaseItemIdentifier: String?
    var previewImageCancellable: AnyCancellable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .white
            addSubview(itemImageView)
            
            configureViews()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        itemNameLabel.text = nil
        purchaseItemIdentifier = nil
        priceLabel.text = nil
        purchaseDateLabel.text = nil
        serialNumberLabel.text = nil
        descriptionLabel.text = nil
        
        showFullDetails = false
    }
    
    func configure(forPurchase purchase: Purchase, viewModel: UserPurchasesViewModel) {
        configureViews()
        itemNameLabel.text = purchase.itemName
        purchaseItemIdentifier = purchase.serialNumber
        priceLabel.text = "$\(purchase.price)"
        purchaseDateLabel.text = purchase.purchaseDate.dateStringFromISO8601String()
        if let serialText = purchase.serialNumber {
            serialNumberLabel.text = "Serial: \(serialText)"
        }
        if let descriptionText = purchase.description {
            descriptionLabel.text = "Description: \n\(descriptionText)"
        }
        
        itemImageView.image = UIImage(systemName: "camera")
        
        previewImageCancellable = viewModel.getPurchaseItemImage(purchase: purchase)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] image in
                guard let self = self else { return }
                if self.purchaseItemIdentifier == purchase.serialNumber {
                    self.itemImageView.image = image
                }
            })
    }
    
    private func configureViews() {
        selectionStyle = .none
        
        purchaseDateLabel.textColor = .darkGray
        serialNumberLabel.textColor = .darkGray
        descriptionLabel.textColor = .darkGray
        itemNameLabel.font = .boldSystemFont(ofSize: 16)
        purchaseDateLabel.font = .systemFont(ofSize: 16)
        priceLabel.font = .boldSystemFont(ofSize: 16)
        serialNumberLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0

        itemImageView.constrainWidth(constant: 50)
        itemImageView.constrainHeight(constant: 50)
        itemNameLabel.constrainWidth(constant: 220)
        descriptionLabel.constrainWidth(constant: 220)
        
        titleStackView.axis = .vertical
        titleStackView.spacing = 8
        titleStackView.alignment = .leading
        titleStackView.addArrangedSubview(itemNameLabel)
        titleStackView.addArrangedSubview(purchaseDateLabel)
        
        // Expanded stack view
        expandedStackView.axis = .vertical
        expandedStackView.spacing = 8
        expandedStackView.alignment = .leading
        let expandedInfoArrangedSubviews = [serialNumberLabel, descriptionLabel]
        for view in expandedInfoArrangedSubviews {
            expandedStackView.addArrangedSubview(view)
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .top
        let arrangedSubviews = [itemImageView, titleStackView, priceLabel]
        for view in arrangedSubviews {
            stackView.addArrangedSubview(view)
        }

        contentView.addSubview(stackView)
        stackView.fillSuperview(padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    /// Expand and collapse the cell
    func toggleFullView() {
        showFullDetails.toggle()
        // TODO: Set up a subject to broadcast the event toggleFullView to subscribers and avoid the manual cell expansion
    }
}
