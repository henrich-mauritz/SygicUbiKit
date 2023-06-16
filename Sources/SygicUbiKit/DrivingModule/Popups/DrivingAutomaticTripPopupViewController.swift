//
//  DrivingAutomaticTripPopupViewController.swift
//  DrivingModule
//
//  Created by Henrich Mauritz on 30/05/2023.
//

import CoreLocation
import CoreMotion
import UIKit

public class DrivingAutomaticTripPopupViewController: StylingPopupViewController {
    public func shouldShowAutomaticTripPopup(automaticTripDetection: Bool) -> Bool {
        if !automaticTripDetection && locationPermission && motionPermission && UserDefaults.standard.bool(forKey: "automaticTripShown") != true {
            // ak nemame zapnuty automatic trip a zaroven mame vsetky potrebne apkove permissions
            return true
        } else {
            return false
        }
    }
    
    private var locationPermission: Bool {
        locationAlwaysPermission || CLLocationManager().authorizationStatus == .authorizedWhenInUse
    }

    private var locationAlwaysPermission: Bool {
        return CLLocationManager().authorizationStatus == .authorizedAlways
    }

    private var motionPermission: Bool {
        CMMotionActivityManager.authorizationStatus() == .authorized
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(true, forKey: "automaticTripShown")
    }
    
    required public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
