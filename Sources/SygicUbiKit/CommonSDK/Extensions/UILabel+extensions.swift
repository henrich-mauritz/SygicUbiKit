//
//  UILabel+extensions.swift
//  CommonSDK
//
//  Created by Juraj Antas on 25/04/2023.
//

import UIKit

public extension UILabel {
    static func trConstructLabel(text: String, font: UIFont, color: UIColor, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = alignment
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = color
        return label
    }
    
}
