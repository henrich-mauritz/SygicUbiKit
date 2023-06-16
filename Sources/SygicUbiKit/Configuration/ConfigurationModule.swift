import Foundation
import UIKit


// MARK: - ConfigurationModule

public final class ConfigurationModule {
    public enum ConfigurationFetchError: Error {
        case unknown
        case unreachable
    }

    public static var currentStoredConfiguration: NetworkConfig? {
        guard let storedThresholds = UserDefaults.standard.object(forKey: "NetworkStoredConfig") as? Data else {
            return nil
        }

        let decoder = JSONDecoder()
        if let loadedThresholds = try? decoder.decode(NetworkConfig.self, from: storedThresholds) {
            return loadedThresholds
        }
        return nil
    }

    public static func fetchConfiguration(completion: @escaping (Result<NetworkConfig, Error>) -> ()) {
        guard let storedThresholds = UserDefaults.standard.object(forKey: "NetworkStoredConfig") as? Data else {
            makeNetworkRequest(completion: completion)
            return
        }
        if let lastStoredThresholdDate = UserDefaults.standard.value(forKey: "LastStoredNetworkThresholdDate") as? Date {
            let diffComponents = Calendar.current.dateComponents([.hour], from: lastStoredThresholdDate, to: Date())
            if let hours = diffComponents.hour, hours > 24 {
                makeNetworkRequest(completion: completion)
                return
            }
        }
        let decoder = JSONDecoder()
        if let loadedThresholds = try? decoder.decode(NetworkConfig.self, from: storedThresholds) {
            completion(.success(loadedThresholds))
            return
        }
        completion(.failure(ConfigurationFetchError.unknown))
    }

    private static func makeNetworkRequest(completion: @escaping (Result<NetworkConfig, Error>) -> ()) {
        let networkManager = NetworkManager.shared
        networkManager.requestAPI(ApiRouterConfiguration.vehicleConfigurations) {(result: Result<NetworkConfig, Error>) in
            switch result {
            case let .success(value):
                UserDefaults.standard.setValue(Date(), forKey: "LastStoredNetworkThresholdDate")
                let encoder = JSONEncoder()
                if let encodedThresholds = try? encoder.encode(value) {
                    UserDefaults.standard.set(encodedThresholds, forKey: "NetworkStoredConfig")
                }
                completion(.success(value))
            case let .failure(error):
                print("No config comming back, will fall back to defaults from error:  \(error)")
                loadDefaults(completion: completion)
            }
        }
    }

    private static func loadDefaults(completion: @escaping (Result<NetworkConfig, Error>) -> ()) {
        guard let url = Bundle(for: ConfigurationModule.self).url(forResource: "mockConfiguration", withExtension: "json") else {
            completion(.failure(ConfigurationFetchError.unknown))
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            completion(.failure(ConfigurationFetchError.unknown))
            return
        }
        do {
            let mockConfig: NetworkConfig? = try NetworkManager.shared.decodeData(data: data)
            if let mockConfig = mockConfig {
                completion(.success(mockConfig))
            }
        } catch {
            print(error)
            completion(.failure(ConfigurationFetchError.unknown))
            return
        }
    }
}
