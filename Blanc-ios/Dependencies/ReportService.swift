import Foundation
import Moya
import RxSwift


class ReportService {

    let provider = MoyaProvider<ReportProvider>(plugins: [])

    private enum CodingKeys: String, CodingKey {
        case number
    }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    // Post
    func report(uid: String?,
                reporterId: String?,
                reporteeId: String?,
                files: [UIImage],
                description: String) -> Single<Void> {
        provider.rx
            .request(.reportUser(
                uid: uid,
                reporterId: reporterId,
                reporteeId: reporteeId,
                files: files,
                description: description)
            )
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in
                Void()
            })
    }

    // Post
    func report(uid: String?,
                reporterId: String?,
                postId: String?,
                files: [UIImage],
                description: String) -> Single<Void> {
        provider.rx
            .request(.reportPost(
                uid: uid,
                reporterId: reporterId,
                postId: postId,
                files: files,
                description: description)
            )
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in
                Void()
            })
    }
}