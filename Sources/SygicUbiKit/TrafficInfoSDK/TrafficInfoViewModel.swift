//
//  TrafficInfoViewModel.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 25/10/2022.
//

import Foundation
import CoreLocation

protocol TrafficInfoViewModelDelegate: AnyObject {
    func viewModelUpdated(error: Error?)
    func viewModelFiltered(zoomMode: TRMapZoomMode)
}

enum TRMapZoomMode {
    case allVisiblePins
    case location(location: CLLocation)
    case region(region: CLCircularRegion)
    case noChange
}

public class TrafficInfoViewModel {
    weak var delegate: TrafficInfoViewModelDelegate?
    var items: [TrafficInfoData] = []
    var selectedItems: [TrafficInfoData] = []
    
    var filterModel = TrafficInfoFilterModel()
    
    var userCoordinate = CLLocationCoordinate2D(latitude: 46.061569, longitude: 14.507713)
    
    public required init() {}
    
    func reloadData() {
        NetworkManager.shared.requestAPI(TrafficInfoApiRouter.trafficInfo) { [weak self] (result:Result<TrafficInfoResponse,Error>) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let result):
                self.items = result.data
                self.delegate?.viewModelUpdated(error: nil)
                self.filter(coordinate: self.userCoordinate,zoomMode: .allVisiblePins)
            case .failure(let error):
                self.delegate?.viewModelUpdated(error: error)
            }
        }
    }
    
    func filter(coordinate: CLLocationCoordinate2D, zoomMode: TRMapZoomMode) {
        userCoordinate = coordinate
        
        var filteredTrafficInfo: [TrafficInfoData] = []
        for info in items {
            var passed: Bool = false
            for item in filterModel.model {
                if item.state == true {
                    let result = info.type == item.type ? true : false
                    if result {
                        passed = true
                        break
                    }
                }
            }
            
            if passed {
                filteredTrafficInfo.append(info)
            }
        }
        
        selectedItems = filteredTrafficInfo
        delegate?.viewModelFiltered(zoomMode: zoomMode)
    }
    
    func includeAtLeastOneBranch(region: CLCircularRegion) -> CLCircularRegion {
        if selectedItems.count == 0 {
            return region
        }
        
        let regionLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        var minDistance = 1000_000_000.0
        
        for trafficInfo in selectedItems {
            let location = CLLocation(latitude: trafficInfo.payload.position.latitude, longitude: trafficInfo.payload.position.longitude)
            let distance = location.distance(from: regionLocation)
            if distance < minDistance {
                minDistance = distance
            }
        }
        
        if minDistance < region.radius {
            return region
        }
        
        return CLCircularRegion(center: region.center, radius: minDistance * 2, identifier: "XXX")
    }
    
}
