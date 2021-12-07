//
//  AboutPurchasesInfoViewController.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/5/21.
//

import UIKit

class AboutPurchasesInfoViewController: UIViewController {
    
    private lazy var describtionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.text = NSLocalizedString("This screen contains your entire purchase history. You can sort it by date of purchase. You can sort it by price. And you can filter it with the search bar.", comment: "String that describes the purchase history and sorting options")
        return label
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        title = NSLocalizedString("About Purchases", comment: "title describing an informational view that informs the user about purchases")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(userDidTapDismissButton))
        configureViews()
    }
    
    private func configureViews() {
        view.addSubview(describtionLabel)
        
        describtionLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = describtionLabel.superview {
            describtionLabel.topAnchor.constraint(equalTo: superview.topAnchor, constant: 60).isActive = true
            describtionLabel.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16).isActive = true
            describtionLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16).isActive = true
        }
    }
    
    @objc private func userDidTapDismissButton() {
        dismiss(animated: true, completion: nil)
    }
}
