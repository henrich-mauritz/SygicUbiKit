//
//  TrafficInfoFilterModel.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 03/11/2022.
//

import Foundation

class TrafficInfoFilterItem {
    required init(type: TrafficInfoType, state: Bool, title: String ) {
        self.type = type
        self.state = state
        self.title = title
    }
    
    var type: TrafficInfoType
    var state: Bool
    var title: String
    
}

class TrafficInfoFilterModel {
    //persist this in UserDefaults
    /*
    var model: [TrafficInfoFilterItem] = [
        TrafficInfoFilterItem(type: .congestion, state: true, title: "trafficInfo.type.congestion".localized),
        TrafficInfoFilterItem(type: .accident, state: true, title: "trafficInfo.type.accident".localized),
        TrafficInfoFilterItem(type: .roadworks, state: true, title: "trafficInfo.type.roadWork".localized),
        TrafficInfoFilterItem(type: .trafficIncident, state: true, title: "trafficInfo.type.trafficIncident".localized),
        TrafficInfoFilterItem(type: .roadCamera, state: false, title: "trafficInfo.type.roadCamera".localized),
        TrafficInfoFilterItem(type: .wind, state: false, title: "trafficInfo.type.wind".localized),
        ]
    */
    
    var model: [TrafficInfoFilterItem] {
        get {
            setDefaultValuesIfNotSetYet()
            
            var result: [TrafficInfoFilterItem] = []
            
            result.append(TrafficInfoFilterItem(type: .congestion, state: UserDefaults.standard.bool(forKey: keyForTraficInfoType(type: .congestion)), title: "trafficInfo.type.congestion".localized))
            
            result.append(TrafficInfoFilterItem(type: .accident, state: UserDefaults.standard.bool(forKey: keyForTraficInfoType(type: .accident)), title: "trafficInfo.type.accident".localized))
            
            result.append(TrafficInfoFilterItem(type: .roadworks, state: UserDefaults.standard.bool(forKey: keyForTraficInfoType(type: .roadworks)), title: "trafficInfo.type.roadWork".localized))
            
            result.append(TrafficInfoFilterItem(type: .trafficIncident, state: UserDefaults.standard.bool(forKey: keyForTraficInfoType(type: .trafficIncident)), title: "trafficInfo.type.trafficIncident".localized))
            
            result.append(TrafficInfoFilterItem(type: .roadCamera, state: UserDefaults.standard.bool(forKey: keyForTraficInfoType(type: .roadCamera)), title: "trafficInfo.type.roadCamera".localized))
            
            result.append(TrafficInfoFilterItem(type: .wind, state: UserDefaults.standard.bool(forKey: keyForTraficInfoType(type: .wind)), title: "trafficInfo.type.wind".localized))
            
            return result
        }
    }
    
    func keyForTraficInfoType(type: TrafficInfoType) -> String {
        return "TrafficInfoType-" + type.rawValue
    }
    
    func setDefaultValuesIfNotSetYet() {
        if UserDefaults.standard.object(forKey: keyForTraficInfoType(type: .congestion)) == nil {
            UserDefaults.standard.setValue(true, forKey: keyForTraficInfoType(type: .congestion))
        }
        
        if UserDefaults.standard.object(forKey: keyForTraficInfoType(type: .accident)) == nil {
            UserDefaults.standard.setValue(true, forKey: keyForTraficInfoType(type: .accident))
        }
        
        if UserDefaults.standard.object(forKey: keyForTraficInfoType(type: .roadworks)) == nil {
            UserDefaults.standard.setValue(true, forKey: keyForTraficInfoType(type: .roadworks))
        }
        
        if UserDefaults.standard.object(forKey: keyForTraficInfoType(type: .trafficIncident)) == nil {
            UserDefaults.standard.setValue(true, forKey: keyForTraficInfoType(type: .trafficIncident))
        }
        
        if UserDefaults.standard.object(forKey: keyForTraficInfoType(type: .roadCamera)) == nil {
            UserDefaults.standard.setValue(false, forKey: keyForTraficInfoType(type: .roadCamera))
        }
        
        if UserDefaults.standard.object(forKey: keyForTraficInfoType(type: .wind)) == nil {
            UserDefaults.standard.setValue(false, forKey: keyForTraficInfoType(type: .wind))
        }
    }
    
    func updateModel(type: TrafficInfoType, state: Bool) {
        for item in model {
            if item.type == type {
                item.state = state
                break
            }
        }
        
        //also persist selection in user defaults
        UserDefaults.standard.setValue(state, forKey: keyForTraficInfoType(type: type))
    }
    
}
