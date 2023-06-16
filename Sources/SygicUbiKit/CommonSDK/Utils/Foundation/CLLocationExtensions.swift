import CoreLocation

public extension CLLocation {
    var dmsFormat: String { latitude + " " + longitude }
    var ddFormat: String { String(format: "%.6f %.6f", coordinate.latitude, coordinate.longitude) }

    private var latitude: String {
        let (degrees, minutes, seconds) = coordinate.latitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "N" : "S")
    }

    private var longitude: String {
        let (degrees, minutes, seconds) = coordinate.longitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "E" : "W")
    }
}

extension BinaryFloatingPoint {
    var dms: (degrees: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self * 3600)
        let degrees = seconds / 3600
        seconds = abs(seconds % 3600)
        return (degrees, seconds / 60, seconds % 60)
    }
}
