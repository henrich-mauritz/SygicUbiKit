//
//  ApiEndpoint.swift
//  TrafficInfoSDK
//
//  Created by Juraj Antas on 25/04/2023.
//

import Foundation

public enum TrafficInfoApiRouter: ApiEndpoints {
    case trafficInfo
    
    public var endpoint: String {
        switch self {
        case .trafficInfo:
            return "traffic"
        }
    }
    
    public var version: Int { 3 }
}


public struct TrafficInfoResponse: Codable {
    var data: [TrafficInfoData]
}

public enum TrafficInfoType: String, Codable {
    case roadworks
    case congestion
    case accident
    case trafficIncident
    case roadCamera
    case wind
}


public struct TrafficInfoData: Codable {
    var type: TrafficInfoType
    var payload: TrafficInfoPayload
}

public struct TrafficInfoPosition: Codable {
    var latitude: Double
    var longitude: Double
}

public struct TrafficInfoPayload: Codable {
    var position: TrafficInfoPosition
    var description: String?
    var uri: String?
}

extension TrafficInfoType {
    func localizedString() -> String {
        switch self {
        case .accident:
            return "trafficInfo.type.accident".localized
        case .congestion:
            return "trafficInfo.type.congestion".localized
        case .roadCamera:
            return "trafficInfo.type.roadCamera".localized
        case .roadworks:
            return "trafficInfo.type.roadWork".localized
        case .trafficIncident:
            return "trafficInfo.type.trafficIncident".localized
        case .wind:
            return "trafficInfo.type.wind".localized
        }
    }
    
}
