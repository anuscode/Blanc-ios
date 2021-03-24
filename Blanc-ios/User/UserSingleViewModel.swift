import Foundation
import RxSwift
import FirebaseAuth


class UserSingleData {

    class Carousel: Hashable {
        var uuid: UUID = UUID()
        var user: UserDTO!

        static func ==(lhs: Carousel, rhs: Carousel) -> Bool {
            lhs === rhs
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
    }

    class Belt: Hashable {
        var uuid: UUID = UUID()
        var match: UserDTO.Relationship.Match = .nothing
        var message: String {
            get {
                switch match {
                case .isMatched:
                    return "이미 매칭 된 유저입니다."
                case .isUnmatched:
                    return "이미 친구신청을 보낸 상대입니다."
                case .isWhoSentMe:
                    return "내게 친구신청을 보낸 상대입니다."
                case .isWhoISent:
                    return "이미 친구신청을 보낸 상대입니다."
                default:
                    return "먼저 친구신청을 보내보세요."
                }
            }
        }

        static func ==(lhs: Belt, rhs: Belt) -> Bool {
            lhs === rhs
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid.hashValue)
        }
    }

    class Body: Hashable {
        var uuid: UUID = UUID()
        var user: UserDTO!

        static func ==(lhs: Body, rhs: Body) -> Bool {
            lhs === rhs
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }
    }

    var user: UserDTO? {
        didSet {
            setCarousel(user: user)
            setBelt(user: user)
            setBody(user: user)
            setPosts(user: user)
        }
    }
    var carousel: [Carousel] = [Carousel()]
    var belt: [Belt] = []
    var body: [Body] = [Body()]
    var posts: [PostDTO] = []

    func setCarousel(user: UserDTO?) {
        carousel[0].user = user
    }

    func setBelt(user: UserDTO?) {
        if let match = user?.relationship?.match, match != .nothing {
            let belt = Belt()
            belt.match = match
            self.belt = [belt]
        } else {
            belt = []
        }
    }

    func setBody(user: UserDTO?) {
        body[0].user = user
    }

    func setPosts(user: UserDTO?) {
        posts = user?.posts ?? []
    }
}

class UserSingleViewModel {

    private class Repository {
        var data: UserSingleData = UserSingleData()
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let repository: Repository = Repository()

    internal let data: ReplaySubject = ReplaySubject<UserSingleData>.create(bufferSize: 1)

    internal let loading: PublishSubject = PublishSubject<Bool>()

    internal let toast: PublishSubject = PublishSubject<String>()

    private var session: Session

    private var homeModel: HomeModel

    private var userSingleModel: UserSingleModel

    private var sendingModel: SendingModel

    private var requestsModel: RequestsModel

    private var conversationModel: ConversationModel

    init(session: Session,
         homeModel: HomeModel,
         userSingleModel: UserSingleModel,
         sendingModel: SendingModel,
         requestsModel: RequestsModel,
         conversationModel: ConversationModel
    ) {
        self.session = session
        self.homeModel = homeModel
        self.userSingleModel = userSingleModel
        self.sendingModel = sendingModel
        self.requestsModel = requestsModel
        self.conversationModel = conversationModel
        subscribeUserModel()
    }

    deinit {
        log.info("deinit UserSingleViewModel..")
    }

    func subscribeUserModel() {
        userSingleModel
            .user
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] user in
                repository.data.user = user
                data.onNext(repository.data)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func createRequest() {
        let onSuccess: (_ request: RequestDTO) -> Void = { [unowned self] request in
            // 아주 근소한 차이로 상대방이 먼저 요청을 보낸 경우 자동 수락 처리 됨.
            if (request.response == .ACCEPTED) {
                conversationModel.populate()
                requestsModel.populate()
            }
            // 홈 화면 유저 리스트 삭제.
            let user = repository.data.user
            homeModel.remove(user)
        }
        let onError: () -> Void = { [unowned self] in
            toast.onNext("친구신청 도중 에러가 발생 하였습니다.")
        }
        userSingleModel.createRequest(onSuccess: onSuccess, onError: onError)
    }

    func poke(onBegin: () -> Void) {
        guard let uid = auth.uid,
              let userId = repository.data.user?.id else {
            return
        }
        if (!RealmService.isPokeAvailable(uid: uid, userId: userId)) {
            toast.onNext("5분 이내에 같은 유저를 찌를 수 없습니다.")
            return
        }
        let onSuccess = { [unowned self] in
            toast.onNext("상대방 옆구리를 찔렀습니다.")
        }
        let onError = { [unowned self] in
            toast.onNext("찔러보기 도중 에러가 발생 하였습니다.")
        }
        onBegin()
        userSingleModel.poke(onSuccess: onSuccess, onError: onError)
    }

    func rate(_ score: Int) {
        let onSuccess = { [unowned self] in
            sendingModel.append(user: repository.data.user)
        }
        let onError = { [unowned self] in
            toast.onNext("별점주기 도중 에러가 발생 하였습니다.")
        }
        userSingleModel.rate(score, onSuccess: onSuccess, onError: onError)
    }

    func favorite(_ post: PostDTO?) {
        let onError = { [unowned self] in
            toast.onNext("게시물 좋아요 업데이트 도중 에러가 발생 하였습니다.")
        }
        userSingleModel.favorite(post, onError: onError)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        userSingleModel.isCurrentUserFavoritePost(post)
    }
}
