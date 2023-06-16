//
//  NSLayoutConstraint+extension.swift
//  Common
//
//  Created by Juraj Antas on 29/01/2023.
//

import UIKit

extension NSLayoutConstraint {
    public func withPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}

