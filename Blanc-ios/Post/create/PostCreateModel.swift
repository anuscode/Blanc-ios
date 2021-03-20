import Foundation
import UIKit
import RxSwift

class PostCreateModel {

    private let disposeBag = DisposeBag()

    private var session: Session

    private var postService: PostService

    init(session: Session, postService: PostService) {
        self.postService = postService
        self.session = session
    }

    func createPost(files: [UIImage], description: String?, enableComment: Bool) -> Single<Void> {
        postService.createPost(
            uid: session.uid,
            files: files,
            description: description,
            enableComment: enableComment
        )
    }
}
