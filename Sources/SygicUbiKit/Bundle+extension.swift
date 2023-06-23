//
//  Bundle+extension.swift
//  SygicUbiKit
//
//  Created by Juraj Antas on 23/06/2023.
//

import Foundation

extension Foundation.Bundle {
    static let module: Bundle = {
        return Bundle(for: CommonDefaultConfiguration.self)
    }()
}
