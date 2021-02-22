import Foundation
import UIKit

class PostCreateViewModel {

    var postCreateModel: PostCreateModel

    init(postCreateModel: PostCreateModel) {
        self.postCreateModel = postCreateModel
    }

    func createPost(files: [UIImage], description: String?, enableComment: Bool,
                    onCompleted: @escaping () -> Void, onError: @escaping () -> Void) {
        postCreateModel.createPost(
                files: files, description: description, enableComment: enableComment,
                onCompleted: onCompleted, onError: onError
        )
    }
}
