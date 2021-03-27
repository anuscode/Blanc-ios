import Foundation
import Contacts
import RxSwift
import FirebaseAuth

class Contact: NSObject, Codable {
    var phoneNumber: String
    var name: String

    init(name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
    }
}

class AvoidModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[Contact]>.create(bufferSize: 1)

    private let session: Session

    private let userService: UserService

    private let phoneRegex = try! NSRegularExpression(pattern: "^(\\+82)?[\\s-]?(0?10)[\\s-]?[0-9]{3,4}[\\s-]?[0-9]{4}$")

    private let extractRegex = try! NSRegularExpression(pattern: "[+0-9]")

    private var contacts: [Contact] = []

    private let auth: Auth = Auth.auth()

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
    }

    func observe() -> Observable<[Contact]> {
        observable
    }

    private func publish() {
        observable.onNext(contacts)
    }

    func populate(onError: @escaping () -> Void) {
        var contacts = [CNContact]()
        var result = [Contact]()

        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        let contactStore = CNContactStore()

        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                contacts.append(contact)
            }
            contacts.forEach { [unowned self] contact in
                if (contact.phoneNumbers.count == 0) {
                    return
                }

                let name = contact.givenName + contact.familyName
                var phoneNumber = contact.phoneNumbers[0].value.stringValue
                phoneNumber = extract(for: extractRegex, in: phoneNumber)
                let isValid = self.isValid(phone: phoneNumber)

                if (!isValid) {
                    return
                }
                phoneNumber = fit(phone: phoneNumber)
                result.append(Contact(name: name, phoneNumber: phoneNumber))
            }
            self.contacts = result
            publish()
        } catch {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }

    private func extract(for regex: NSRegularExpression, in text: String) -> String {
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }.joined()
    }

    private func isValid(phone: String) -> Bool {
        let range = NSRange(location: 0, length: phone.utf16.count)
        let result = phoneRegex.firstMatch(in: phone, range: range)
        return result != nil
    }

    private func fit(phone: String) -> String {
        let hasCountryCode = phone.contains("+82")
        var converted = phone
        if (!hasCountryCode) {
            converted = "+82" + phone
        }
        converted = converted.replacingOccurrences(of: "010", with: "10")
        return converted
    }

    func updateUserContacts() -> Single<Void> {

        guard let currentUser = auth.currentUser,
              let uid = session.uid,
              let userId = session.id else {
            return Single
                .just(Void())
                .do(onSuccess: {
                    throw NSError(domain: "not found required values..", code: 42, userInfo: nil)
                })
        }

        let phones = contacts.map {
            $0.phoneNumber
        }

        return userService
            .updateUserContacts(
                currentUser: currentUser,
                uid: uid,
                userId: userId,
                phones: phones
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }
}
