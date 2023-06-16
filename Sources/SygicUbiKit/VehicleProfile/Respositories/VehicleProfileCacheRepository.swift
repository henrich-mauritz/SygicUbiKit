import Foundation

// MARK: - VehicleProfilePersistentCacheType

protocol VehicleProfilePersistentCacheType {
    func loadProfiles() -> VehicleProfileDataType?
    func store(vehicleProfiles: VehicleProfileDataType)
    func clear()
}

// MARK: - VehicleProfileCacheRepository

class VehicleProfileCacheRepository: VehicleProfileCacheRepositoryType {
    private let persistanceCacheRepository: VehicleProfilePersistentCacheType = VehicleProfilePersistentCacheRepository()
    private var currentProfiles: VehicleProfileDataType? {
        didSet {
            guard let currentProfiles = currentProfiles else {
                return
            }
            persistanceCacheRepository.store(vehicleProfiles: currentProfiles)
        }
    }

    func loadProfiles() -> VehicleProfileDataType? {
        guard let currentProfiles = currentProfiles else {
            let profiles = persistanceCacheRepository.loadProfiles()
            currentProfiles = profiles
            return profiles
        }
        return currentProfiles
    }

    func update(with profile: VehicleProfileDataType) {
        currentProfiles = profile
        sync()
    }

    func cleanCache() {
        currentProfiles = nil
        persistanceCacheRepository.clear()
    }

    func addVehicle(with profile: NetworkVehicle) {
        guard let currentProfiles = currentProfiles else {
            return
        }
        currentProfiles.add(vehicle: profile)
        sync()
    }

    func patchVehicle(with profile: NetworkVehicle, updatedProfile: NetworkPostResponseVechileData) {
        if let matchVehicle = currentProfiles?.vehicles.first(where: { $0.publicId == profile.publicId }) {
            matchVehicle.name = updatedProfile.data.name
            matchVehicle.state = updatedProfile.data.state
        } else {
            currentProfiles?.add(vehicle: profile)
        }
        sync()
    }

    /// take current vehicles and store them again
    public func sync() {
        guard let currentProfiles = currentProfiles else {
            return
        }
        persistanceCacheRepository.store(vehicleProfiles: currentProfiles)
    }
}

// MARK: - VehicleProfilePersistentCacheRepository

class VehicleProfilePersistentCacheRepository: VehicleProfilePersistentCacheType {
    enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the
        //<Application_Home>/Documents directory
        case documents

        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory.
        //Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches
    }

    private static let cacheFileName: String = "vehicleCache"

    func loadProfiles() -> VehicleProfileDataType? {
        let storedProfiles = retrieve(Self.cacheFileName, from: .caches, as: NetworkVehicleProfile.self)
        return storedProfiles
    }

    func store(vehicleProfiles: VehicleProfileDataType) {
        guard let encodableVehicles = vehicleProfiles as? NetworkVehicleProfile else {
            return
        }
        //TODO: Je dost diskutabilny napad ukladat persistent subory do caches lebo OS moze caches premazat ked hlada volne miesto na disku. tj. prideme o nas subor. lepsie miesto pre tieto subory je v Library/<nas dir>/subor.data.
        store(encodableVehicles, to: .caches, as: Self.cacheFileName)
    }

    private func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory

        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }

        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }

    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    private func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    private func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)

        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }

        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }

    func clear() {
        //clear(Directory.caches)
        //zmazeme si len ten subor ktory sme vytvorili
        remove(VehicleProfilePersistentCacheRepository.cacheFileName, from: .caches)
    }

    /// Remove all files at specified directory
    //Troska divny napad mazat vsetko z caches, lebo nas subor je len jeden a uklada si tam data aj OS. Cize ked sa budeme snazit zmazat subor ktory patri inemu processu ale stale v ramci nasej apky tak dostaneme exception "access denied" a skoncime na fatalError(). Nase si nedame, cudzie nechceme!
    func clear(_ directory: Directory) {
        let url = getURL(for: directory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    /// Remove specified file from specified directory
    private func remove(_ fileName: String, from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    private func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
}
