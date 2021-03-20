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

    // GET
    func report(uid: String?,
                reporterId: String?,
                reporteeId: String?,
                files: [UIImage],
                description: String) -> Single<Void> {

        provider.rx
            .request(.report(
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
}