import Foundation
import RxSwift
import FirebaseAuth

class UserSingleModel {

    private class Repository {
        var user: UserDTO!
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private let repository: Repository = Repository()

    private let session: Session

    private let userService: UserService

    private let postService: PostService

    private let requestService: RequestService

    init(session: Session,
         userService: UserService,
         postService: PostService,
         requestService: RequestService) {
        self.session = session
        self.userService = userService
        self.postService = postService
        self.requestService = requestService
        populate()
    }

    deinit {
        log.info("deinit UserSingleModel..")
    }

    func publish() {
        user.onNext(repository.user)
    }

    func populate() {
        Channel
            .user
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [unowned self]  user in
                user.relationship = session.relationship(with: user)
            })
            .subscribe(onNext: { [unowned self] user in
                repository.user = user
                publish()
                populateUserPosts(user: user)
                pushLookup()
                subscribeSession()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func populateUserPosts(user: UserDTO?) {
        guard let uid = auth.uid,
              let userId = user?.id else {
            return
        }
        userService
            .listAllUserPosts(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] posts in
                repository.user.posts = posts
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func subscribeSession() {
        session
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .skip(1)
            .subscribe(onNext: { [unowned self] _ in
                log.info("subscribe session in user single model..")
                // TODO: make new instance..
                repository.user.relationship = session.relationship(with: repository.user)
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func createRequest(onSuccess: @escaping (_ request: RequestDTO) -> Void, onError: @escaping () -> Void) {
        guard let uid = auth.uid,
              let user = repository.user,
              let userId = user.id,
              let currentUser = auth.currentUser else {
            onError()
            return
        }
        requestService
            .createRequest(
                currentUser: currentUser,
                uid: uid,
                userId: userId,
                requestType: .FRIEND
            )
            .do(onSuccess: onSuccess)
            .flatMap({ _ in self.session.refresh() })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self]  _ in
                user.relationship = session.relationship(with: user)
                publish()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func poke(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        guard let uid = auth.uid,
              let user = repository.user,
              let userId = user.id else {
            return
        }
        userService
            .pushPoke(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { data in
                RealmService.setPokeHistory(uid: uid, userId: userId)
                onSuccess()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func rate(_ score: Int, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        guard let uid = auth.uid,
              let user = repository.user,
              let userId = user.id else {
            onError()
            return
        }
        userService
            .updateUserStarRatingScore(uid: uid, userId: userId, score: score)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] _ in
                log.info("Successfully rated score \(score) at user: \(userId)")

                let starRating = StarRating(userId: userId, score: score)
                session.user?.starRatingsIRated?.append(starRating)
                session.publish()

                let relationship = session.relationship(with: user)
                user.relationship = relationship
                publish()

                onSuccess()
            }, onError: { err in
                onError()
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func pushLookup() {
        guard let uid = auth.uid,
              let user = repository.user,
              let userId = user.id else {
            return
        }
        userService
            .pushLookUp(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: {
                log.info("Successfully requested to push lookup..")
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func favorite(_ post: PostDTO?, onError: @escaping () -> Void) {
        if (isCurrentUserFavoritePost(post)) {
            deleteFavorite(post, onError: onError)
        } else {
            createFavorite(post, onError: onError)
        }
    }

    private func createFavorite(_ post: PostDTO?, onError: @escaping () -> Void) {
        guard let uid = auth.uid,
              let userId = session.id,
              let postId = post?.id else {
            return
        }
        if (post?.favoriteUserIds?.firstIndex(of: userId) == nil) {
            post?.favoriteUserIds?.append(userId)
        }
        if let index = repository.user.posts?.firstIndex(where: { $0.id == postId }) {
            repository.user.posts?.diffable(index)
        }
        publish()
        postService
            .createFavorite(uid: uid, postId: postId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully created favorite post..")
            }, onError: { [unowned self] err in
                log.error(err)
                onError()
                publish()
            })
            .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?, onError: (() -> Void)?) {
        guard let uid = auth.uid,
              let userId = session.id,
              let postId = post?.id else {
            return
        }
        if let index = post?.favoriteUserIds?.firstIndex(of: userId) {
            post?.favoriteUserIds?.remove(at: index)
        }
        if let index = repository.user.posts?.firstIndex(where: { $0.id == postId }) {
            repository.user.posts?.diffable(index)
        }
        publish()
        postService
            .deleteFavorite(uid: uid, postId: postId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully deleted favorite post..")
            }, onError: { [unowned self] err in
                log.info(err)
                onError?()
                publish()
            })
            .disposed(by: disposeBag)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        if let userId = session.id {
            return post?.favoriteUserIds?.firstIndex(of: userId) != nil
        }
        return false
    }
}