//
//  UIWindow+extensions.swift
//  Common
//
//  Created by Juraj Antas on 28/01/2023.
//

import UIKit

//iOS13+
//replacement pre UIApplication.shared.statusBarOrientation, to silent deprecation warning
//TODO: Rozmyslal som ze chcem keyWindow, ale pri testovani som zistil ze mam jedno okno a nie je keyWindow, huh?
extension UIWindow {
    public class var isLandscape: Bool {
        if let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
            if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    public class var isPortrait: Bool {
        return !isLandscape
    }
    
    public class var screenOrientation: UIInterfaceOrientation {
        if let interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
            return interfaceOrientation
        }
        else {
            return .portrait
        }
    }
    
    public class var windowWidth: CGFloat {
        if let bounds = UIApplication.shared.windows.first?.windowScene?.screen.bounds {
            return bounds.width
        }
        else {
            return 320
        }
    }
    
}
