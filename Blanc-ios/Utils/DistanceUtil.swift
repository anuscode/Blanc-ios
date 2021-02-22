import CoreLocation

class DistanceUtil {

    static func distance() {
        let coordinate1 = CLLocation(latitude: 5.0, longitude: 5.0)
        let coordinate2 = CLLocation(latitude: 5.0, longitude: 3.0)
        let distanceInMeters = coordinate1.distance(from: coordinate2)
    }

}
