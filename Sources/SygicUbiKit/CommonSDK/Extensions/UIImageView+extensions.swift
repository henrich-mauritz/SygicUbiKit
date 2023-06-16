//
//  UIImageView+extensions.swift
//  CommonSDK
//
//  Created by Juraj Antas on 27/04/2023.
//

import UIKit

extension UIImageView {
    public func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit, downloadComplatedBlock:(()->Void)? = nil) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                if let self = self {
                    self.image = image
                    
                    //bez tohto to nepojde dobre lebo stack view bude mat height podla vysky obrazka a ten sa bude kreslit s obrovskymi marginami hore a dole. tj. mi chceme aby bol len taky velky kolko je treba, cize mu dame aspect ratio constraint.
                    let aspectRatioConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: Double(image.size.width)/Double(image.size.height), constant: 0)
                    aspectRatioConstraint.isActive = true
                    
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                    
                    downloadComplatedBlock?()
                }
            }
        }.resume()
    }
    
    public func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit, downloadComplatedBlock:(()->Void)? = nil) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode, downloadComplatedBlock: downloadComplatedBlock)
    }
    
}

