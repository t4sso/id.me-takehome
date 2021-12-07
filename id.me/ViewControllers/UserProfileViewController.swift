//
//  UserProfileViewController.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/4/21.
//

import Combine
import UIKit

/// Container view controller definition that embeds the results list and map views as well as providing search and filtering UI support
class UserProfileViewController: UIViewController {
    
    private let userID: String
    private var user: User?
    private var viewModel: UserProfileViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var previewImageCancellable: AnyCancellable?
    
    private var secondaryFont: UIFont = .systemFont(ofSize: 16)
    private var primaryFont: UIFont = .systemFont(ofSize: 24)
    private var titleFont: UIFont = .systemFont(ofSize: 40)
    
    private lazy var firstLastNameLabel: UILabel = {
        let label = UILabel()
        label.font = titleFont
        return label
    }()
    
    private lazy var personalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = secondaryFont
        return label
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = primaryFont
        return label
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = primaryFont
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.font = primaryFont
        return label
    }()
   
    private lazy var registrationDateLabel: UILabel = {
        let label = UILabel()
        label.font = primaryFont
        return label
    }()
    
    private lazy var userProfileImage: UIImageView = {
        let imageView = UIImageView(cornerRadius: 100/2)
        return imageView
    }()
    
    private lazy var userProfileDataStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var viewPurchasesButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.backgroundColor = .blue
        button.titleLabel?.textColor = .white
        let buttonTitle = NSLocalizedString("View Purchases", comment: "title for button that allows users to view their purchases when pressed")
        button.setTitle(buttonTitle, for: .normal)
        return button
    }()
    
    init(viewModel: UserProfileViewModel) {
        self.userID = viewModel.userID
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getUserInformation()
        configureViews()
        bindViewModel()
    }
    
    private func configureViews() {
        view.backgroundColor = .white
        view.addSubview(userProfileDataStackView)
        userProfileImage.constrainHeight(constant: 100)
        userProfileImage.constrainWidth(constant: 100)

        userProfileDataStackView.fillSuperview(padding: UIEdgeInsets(top: 50, left: 8, bottom: 50, right: 8))
        let viewWidth = UIScreen.main.bounds.width
        personalLabel.constrainWidth(constant: viewWidth)
        userNameLabel.constrainWidth(constant: viewWidth)
        fullNameLabel.constrainWidth(constant: viewWidth)
        phoneNumberLabel.constrainWidth(constant: viewWidth)
        registrationDateLabel.constrainWidth(constant: viewWidth)
        viewPurchasesButton.constrainWidth(constant: 200)
        viewPurchasesButton.constrainHeight(constant: 40)

        viewPurchasesButton.addTarget(self, action: #selector(userDidTapViewPurchases), for: .touchUpInside)
        configureStackView()
        
    }
    
    private func configureStackView() {
       
        let arrangedSubviews = [userProfileImage, firstLastNameLabel, personalLabel, userNameLabel, fullNameLabel, phoneNumberLabel, registrationDateLabel, viewPurchasesButton, UIView()]
        for view in arrangedSubviews {
            userProfileDataStackView.addArrangedSubview(view)
        }
    }
    
    private func loadData() {
        
        let firstNameLastNameComponents = (viewModel.user?.fullName ?? "").componentsFromFullName()
        let firstNameValue = firstNameLastNameComponents.givenName ?? ""
        let lastNameValue = firstNameLastNameComponents.familyName ?? ""
        firstLastNameLabel.text = "\(firstNameValue) \(lastNameValue)"
        
        let personalLabelTitle = NSLocalizedString("Personal", comment: "Section title for user data")
        setAttributedTextForLabel(forLabel: personalLabel, title: personalLabelTitle, value: "")
        
        let userNameTitle = NSLocalizedString("Username", comment: "descriptive title describing username")
        let userNameValue = viewModel.user?.userName ?? ""
        setAttributedTextForLabel(forLabel: userNameLabel, title: userNameTitle, value: userNameValue)
        
        let fullNameTitle = NSLocalizedString("Full name", comment: "descriptive title describing user's full name")
        let fullNameValue = viewModel.user?.fullName ?? ""
        setAttributedTextForLabel(forLabel: fullNameLabel, title: fullNameTitle, value: fullNameValue)
        
        let phoneNumberTitle = NSLocalizedString("Phone number", comment: "descriptive title describing user's phone number")
        let phoneNumberValue = (viewModel.user?.phoneNumber ?? "").formatPhoneNumber()
        setAttributedTextForLabel(forLabel: phoneNumberLabel, title: phoneNumberTitle, value: phoneNumberValue)
        
        let iso8601String = viewModel.user?.registration ?? ""
        let registrationDateTitle = NSLocalizedString("Registration Date", comment: "descriptive title describing user's registration date")
        let registrationDateValue = iso8601String.dateStringFromISO8601String()
        setAttributedTextForLabel(forLabel: registrationDateLabel, title: registrationDateTitle, value: registrationDateValue)
        
        setUserProfilePhoto()
    }
    
    private func setUserProfilePhoto() {
        guard let user = user else { return }
        previewImageCancellable = viewModel.getUserPhoto(user: user)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] image in
                guard let self = self else { return }
                self.userProfileImage.image = image
            })
    }
    
    @objc private func userDidTapViewPurchases() {
        guard let navigationController = navigationController else { return }
        let userPurchasesViewModel = UserPurchasesViewModel(userID: userID)
        let userPurchasesViewController = UserPurchasesViewController(viewModel: userPurchasesViewModel)
        navigationController.pushViewController(userPurchasesViewController, animated: true)
    }
}

// MARK: - View Model Data Binding

extension UserProfileViewController {
    
    private func bindViewModel() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self else { return }
                self.user = user
                self.loadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private Helper Methods
extension UserProfileViewController {
    private func setAttributedTextForLabel(forLabel label: UILabel, title: String, value: String) {
        let text = "\(title)\n\(value)"
        let attributedString = NSMutableAttributedString(string: text)
        let leftAlignedParagraphStyle = NSMutableParagraphStyle()
        let rightAlignedParagraphStyle = NSMutableParagraphStyle()
        
        leftAlignedParagraphStyle.alignment = .left
        rightAlignedParagraphStyle.alignment = .right
        rightAlignedParagraphStyle.paragraphSpacingBefore = -label.font.lineHeight
        
        attributedString.addAttribute(.paragraphStyle, value: leftAlignedParagraphStyle, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.paragraphStyle, value: rightAlignedParagraphStyle, range: NSRange(location: title.count, length: value.count + 1))
        
        label.numberOfLines = 0
        label.attributedText = attributedString
    }
    
}
