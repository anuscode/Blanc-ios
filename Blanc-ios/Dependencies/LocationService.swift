import CoreLocation
import Foundation
import RxSwift
import MapKit

enum Result<T> {
    case success(T)
    case failure(Error)
}

final class LocationService: NSObject {

    static var shared: LocationService = LocationService()

    private var location: ReplaySubject = ReplaySubject<Coordinate>.create(bufferSize: 1)

    private let isReady: ReplaySubject = ReplaySubject<Void>.create(bufferSize: 1)

    private let manager: CLLocationManager

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func getCurrentLocation() -> Single<Coordinate> {
        location = ReplaySubject<Coordinate>.create(bufferSize: 1)
        let isLocationEnabled = CLLocationManager.locationServicesEnabled()
        let isLocationAuthorized = CLLocationManager.authorizationStatus().rawValue > 2

        if isLocationEnabled && isLocationAuthorized {
            manager.startUpdatingLocation()
        } else {
            manager.requestAlwaysAuthorization()
        }
        return location.take(1).asSingle()
    }

    func getAddress(by coordinate: Coordinate?) -> Single<String> {
        let unknown: String = "알 수 없음"
        let address = CLGeocoder.init()
        let subject: ReplaySubject = ReplaySubject<String>.create(bufferSize: 1)
        if (coordinate == nil || coordinate?.isValid() != true) {
            subject.onNext(unknown)
        }
        let latitude = coordinate!.latitude
        let longitude = coordinate!.longitude

        if (latitude == nil || longitude == nil) {
            subject.onNext(unknown)
            return subject.take(1).asSingle()
        }

        address.reverseGeocodeLocation(CLLocation.init(latitude: latitude!, longitude: longitude!)) { (places, error) in
            if error != nil {
                log.error(error as Any)
                subject.onNext(unknown)
                return
            }
            guard let place = places?.first,
                  let addrList = place.addressDictionary?["FormattedAddressLines"] as? [String] else {
                subject.onNext(unknown)
                return
            }
            // addressList example:
            // addressList[0] => "대한민국"
            // addressList[1] => "서울특별시 송파구 석촌동 220"
            let addressComponents = (addrList.first ?? "").components(separatedBy: [" "])
            let component: String? = addressComponents.count > 2 ? addressComponents[1] : addressComponents.first
            let address = component ?? unknown
            subject.onNext(address)
        }
        return subject.take(1).asSingle()
    }

    deinit {
        manager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        location.onNext(Coordinate(nil))
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let current = locations.sorted(by: { $0.timestamp > $1.timestamp }).first {
            location.onNext(Coordinate(current))
        } else {
            location.onNext(Coordinate(nil))
        }
        manager.stopUpdatingLocation()
    }

    /*
     *  locationManagerDidChangeAuthorization:
     *
     *  Discussion:
     *    Invoked when either the authorizationStatus or
     *    accuracyAuthorization properties change
     */
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined, .restricted, .denied:
            location.onNext(Coordinate(nil))
            manager.stopUpdatingLocation()
        default:
            manager.startUpdatingLocation()
        }
        isReady.onNext(Void())
    }
}
