import CoreLocation
import Foundation
import RxSwift
import MapKit

enum Result<T> {
    case success(T)
    case failure(Error)
}

final class LocationService: NSObject {

    private let manager: CLLocationManager

    init(manager: CLLocationManager) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }

    var newLocation: ((Result<CLLocation>) -> Void)?

    var didChangeStatus: ((Bool) -> Void)?

    var status: CLAuthorizationStatus {
        CLLocationManager.authorizationStatus()
    }

    func requestLocationAuthorization() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func getCurrentLocation() -> Single<Coordinate> {
        let subject: ReplaySubject = ReplaySubject<Coordinate>.create(bufferSize: 1)
        newLocation = { result in
            switch result {
            case .success(let location):
                subject.onNext(Coordinate(location))
            case .failure(let _):
                subject.onNext(Coordinate(nil))
            }
        }
        requestLocation()
        return subject.take(1).asSingle()
    }

    func getAddressByCoordinate(coordinate: Coordinate?) -> Single<String> {
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
            guard let placemark = places?.first,
                  let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
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
        newLocation?(.failure(error))
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.sorted(by: { $0.timestamp > $1.timestamp }).first {
            newLocation?(.success(location))
        }
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            didChangeStatus?(false)
        default:
            didChangeStatus?(true)
        }
    }
}
