//
//  Extensions.swift
//  id.me
//
//  Created by Tassos Chouliaras on 12/4/21.
//

import UIKit
import Contacts

// MARK: - Layout
extension UIView {
    
    func constrainWidth(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: constant).isActive = true
    }

    func constrainHeight(constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }

        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func centerInView(size: CGSize = .zero) {
        centerHorizontallyInView()
        centerVerticallyInView()
    }
    
    func centerHorizontallyInView(size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
    
    func centerVerticallyInView(size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}

// MARK: - UIImageView

extension UIImageView {
    convenience init(cornerRadius: CGFloat) {
        self.init(image: nil)
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
}

// MARK: - Date

extension String {
    /// To convert API result date (ISO8601) to `Date`
    var inDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        return dateFormatter
    }
        
    /// To convert `Date` to readable date format
    var outDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }
    
    func dateFromISO8601String() -> Date {
        guard let date = inDateFormatter.date(from: self) else { return Date() }
        return date
    }
    
    func dateStringFromISO8601String() -> String {
        guard let date = inDateFormatter.date(from: self) else { return "" }
        let formattedString = outDateFormatter.string(from: date)
        
        return formattedString
    }
    
    
    func componentsFromFullName() -> (givenName: String?, middleName: String?, familyName: String?) {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: self) {
            return (components.givenName, components.middleName, components.familyName)
        }
        return (nil, nil, nil)
        
    }
    
    func formatPhoneNumber() -> String {
        // Only supports US numbers, some formatter like libPhoneNumber is needed for international use
        guard count == 11 else { return self }
        
        var result = "+" + self
        result.insert(contentsOf: " (", at: result.index(result.startIndex, offsetBy: 2))
        result.insert(contentsOf: ") ", at: result.index(result.startIndex, offsetBy: 7))
        result.insert(contentsOf: "-", at: result.index(result.endIndex, offsetBy: -4))
        
        return result
    }
    
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil)
            .string
        
        return decoded ?? self
    }
    
    
}
