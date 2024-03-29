import Foundation
import CoreLocation

struct UserGlobal: Codable {
    static let bodyTypes = ["마른", "슬림 근육", "보통", "균형 잡힌", "통통", "덩치 큼", "글래머", "비밀"]
    static let occupations = [
        "학생", "경영·사무", "영업·고객상담", "금융직", "연구·기술직", "IT·인터넷", "디자인", "서비스", "전문직", "의료",
        "생산제조", "건설", "유통무역", "미디어", "교육", "공무원", "사업가", "군인", "백수", "직접입력"
    ]
    static let educations = ["고졸", "전문학사", "학사", "석사", "박사", "기타", "비밀", "직접입력"]
    static let religions = ["무교", "천주교", "기독교", "불교", "원불교", "통일교", "부두교", "기타"]
    static let drinks = ["안함", "가끔 모임에서", "선호함", "병만 팔아도 집삼"]
    static let smokings = ["비 흡연자", "전자 담배", "가끔", "애연가"]
    static let bloodTypes = ["A 형", "B 형", "O 형", "AB 형"]

    static let charms: [String] = [
        "나만의 재주", "큰 눈", "경제력", "손이 예뻐요", "피부가 좋아요", "소통을 잘해요", "애플 엉덩이",
        "다정다감", "섬세 해요", "장난을 꾸러기", "커리어", "솔직한 성격", "영리해요", "타투",
        "편식하지 않아요", "쌍거풀", "비율", "길쭉한 다리", "자주 표현해요", "유머감각",
        "동안외모", "매력적인 눈썹", "털털한 성격", "웃는 모습이 예뻐요", "인싸에요",
        "자취", "매력적인목소리", "자주 웃어요", "요리 실력", "보조개", "매력적 취미", "패션 센스"
    ]

    static let idealTypes: [String] = [
        "운동을 좋아하는", "허세가 없는", "예의가 바른", "연락 자주 하는", "티키타카가 되는", "자주 표현하는", "솔직한", "피부가 좋은",
        "바람 안피는", "자기 일에 열정적인", "귀여운", "유머감각 있는", "섹시한", "배려심 깊은", "착한", "자주 만날 수 있는", "미소가 예쁜",
        "털털한", "개방적인", "말이 많은", "바른", "다정한", "잘 노는", "패션감각이 좋은", "애교 많은", "착하게 말하는", "편식 않하는",
        "목소리가좋은"
    ]

    static let interests: [String] = [
        "자전거", "드라이브", "커피", "웹툰", "전시회", "드라마", "그림", "여행", "패션", "쇼핑", "독서", "사진", "문학", "정치",
        "반려동물", "영화보기", "글쓰기", "외국어/어학", "맛집탐방", "IT", "미용", "술", "댄스", "애니", "자기계발", "스포츠/운동",
        "악기연주", "피트니스", "레져", "봉사활동", "인테리어", "재테크", "게임", "공연 관람", "요리", "음악", "덕질", "산책", "노래"
    ]
}

struct Coordinate: Codable {

    init(_ location: CLLocation?) {
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
    }

    var latitude: Double?
    var longitude: Double?

    func isValid() -> Bool {
        (latitude != nil && longitude != nil)
    }
}

struct Location: Codable {
    var coordinates: Array<Double>?
    var type: String?
}

extension Location {
    func toCLLocation() -> CLLocation? {
        guard coordinates?.count ?? 0 == 2 else {
            return nil
        }
        let latitude = coordinates?[1] ?? 0.0
        let longitude = coordinates?[0] ?? 0.0
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

enum Sex: String, Codable {
    case MALE = "M", FEMALE = "F"
}

struct StarRating: Codable {
    init(userId: String, score: Int) {
        self.userId = userId
        self.score = score
    }

    var userId: String?
    var score: Int? = 0
}

struct ImageDTO: Codable {
    var index: Int?
    var url: String?
}

enum Status: String, Codable {
    case OPENED = "OPENED",
         PENDING = "PENDING",
         APPROVED = "APPROVED",
         REJECTED = "REJECTED",
         BLOCKED = "BLOCKED"
}

class UserDTO: Hashable, Codable {

    class Relationship: Codable {

        enum Match {
            case isMatched,
                 isUnmatched,
                 isWhoSentMe,
                 isWhoISent,
                 nothing
        }

        var isMatched: Bool = false
        var isUnmatched: Bool = false
        var isWhoSentMe: Bool = false
        var isWhoISent: Bool = false

        var starRating: StarRating? = nil
        var distance: String?
        var match: Match {
            get {
                if (isMatched) {
                    return .isMatched
                }
                if (isUnmatched) {
                    return .isUnmatched
                }
                if (isWhoSentMe) {
                    return .isWhoSentMe
                }
                if (isWhoISent) {
                    return .isWhoISent
                }
                return .nothing
            }
        }

        func isDifferent(_ relationship: Relationship?) -> Bool {
            guard let relationship = relationship else {
                return true
            }
            return match != relationship.match ||
                starRating?.score != relationship.starRating?.score ||
                distance != relationship.distance
        }
    }

    var uuid: UUID? = UUID()
    var _id: String?
    var id: String? {
        get {
            _id
        }
        set {
            _id = newValue
        }
    }
    var uid: String?
    var nickname: String?
    var sex: Sex?
    var birthedAt: Int?
    var height: Int?
    var bodyId: Int?
    var bodyType: String {
        get {
            let count = UserGlobal.bodyTypes.count
            if (bodyId != nil && bodyId ?? count < count) {
                return UserGlobal.bodyTypes[bodyId!]
            } else {
                return "알 수 없음"
            }
        }
    }
    var occupation: String?
    var education: String?
    var religionId: Int?
    var religion: String {
        get {
            let count = UserGlobal.religions.count
            if (religionId != nil && religionId ?? count < count) {
                return UserGlobal.religions[religionId!]
            } else {
                return "알 수 없음"
            }
        }
    }
    var drinkId: Int?
    var drink: String {
        get {
            let count = UserGlobal.drinks.count
            if (drinkId != nil && drinkId ?? count < count) {
                return UserGlobal.drinks[drinkId!]
            } else {
                return "알 수 없음"
            }
        }
    }
    var smokingId: Int?
    var smoking: String {
        get {
            let count = UserGlobal.smokings.count
            if (smokingId != nil && smokingId ?? count < count) {
                return UserGlobal.smokings[smokingId!]
            } else {
                return "알 수 없음"
            }
        }
    }
    var bloodId: Int?
    var blood: String {
        get {
            let count = UserGlobal.bloodTypes.count
            if (bloodId != nil && bloodId ?? count < count) {
                return UserGlobal.bloodTypes[bloodId!]
            } else {
                return "알 수 없음"
            }
        }
    }
    var deviceToken: String?
    var location: Location?
    var introduction: String?
    var joinedAt: Int?
    var lastLoginAt: Int?
    var job: String?
    var area: String?
    var phone: String?
    var charmIds: [Int]?
    var idealTypeIds: [Int]?
    var interestIds: [Int]?
    var personalities: [Int]?

    var userImages: [ImageDTO]?
    var userImagesTemp: [ImageDTO]?

    var userIdsSentMeRequest: [String]?
    var userIdsISentRequest: [String]?
    var userIdsMatched: [String]?
    var userIdsUnmatched: [String]?
    var userIdsBlocked: [String]?
    var starRatingsIRated: [StarRating]?

    var starRatingAvg: Float?
    var freePassTokens: [Int]?
    var freeOpenTokens: [Int]?
    var available: Bool?
    var status: Status?
    var exists: Bool? = false

    /** remaining paid point. **/
    var point: Float?

    var avatar: String? {
        get {
            let image = userImages?.min(by: { $0.index ?? 7 < $1.index ?? 7 })
            return image?.url
        }
    }

    var age: Int? {
        get {
            birthedAt.asAge()
        }
    }

    /** relationship with current user. **/
    var relationship: Relationship?

    var posts: [PostDTO]? = []

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: UserDTO, rhs: UserDTO) -> Bool {
        lhs.uuid?.hashValue == rhs.uuid?.hashValue
    }
}

extension UserDTO {
    func getTempImageUrl(index: Int) -> String {
        let imageDTOs = userImagesTemp
        let imageDTO = imageDTOs?.first(where: { $0.index == index })
        return imageDTO?.url ?? ""
    }

    func getImageUrl(index: Int) -> String {
        let imageDTOs = userImages
        let imageDTO = imageDTOs?.first(where: { $0.index == index })
        return imageDTO?.url ?? ""
    }

    func distance(from: UserDTO?) -> Double? {
        let user1 = self
        let user2 = from

        guard let coordinate1 = user1.location?.toCLLocation(),
              let coordinate2 = user2?.location?.toCLLocation() else {
            return nil
        }

        var distance = coordinate1.distance(from: coordinate2)
        distance = round(distance / 100) / 10
        distance = max(distance, 1.0)
        return distance
    }

    func distance(from: UserDTO?, type: String.Type) -> String {
        let distance = self.distance(from: from)
        return distance != nil ? "\(distance!) km" : "알 수 없음"
    }
}

extension UserDTO {
    func copy() -> UserDTO {
        do {
            let jsonData = try JSONEncoder().encode(self)
            let userDTO = try JSONDecoder().decode(UserDTO.self, from: jsonData)
            return userDTO
        } catch {
            log.error("Failed to deep copy..")
            return UserDTO()
        }
    }
}

extension Array where Element: Codable {
    mutating func diffable(_ index: Int) {
        let item = self[index]
        do {
            let encoded = try JSONEncoder().encode(item)
            let decoded = try JSONDecoder().decode(Element.self, from: encoded)
            self[index] = decoded
        } catch {
            log.error("Failed to deep copy..")
        }
    }
}