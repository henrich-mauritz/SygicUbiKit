//
//  UIControl+extensions.swift
//  CommonSDK
//
//  Created by Juraj Antas on 25/04/2023.
//

import Foundation
import UIKit

public extension UIControl {
    func onTapped(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping()->()) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
    
}

