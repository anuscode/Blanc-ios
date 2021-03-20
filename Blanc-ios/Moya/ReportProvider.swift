import Moya

enum ReportProvider {
    case report(
        uid: String?,
        reporterId: String?,
        reporteeId: String?,
        files: [UIImage],
        description: String
    )
}


extension ReportProvider: TargetType {

    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {
        case .report(
            uid: _,
            reporterId: let reporterId,
            reporteeId: let reporteeId,
            files: _,
            description: _
        ): return "/report/reporter/\(reporterId ?? "")/reportee/\(reporteeId ?? "")"
        }
    }

    var method: Moya.Method {
        switch self {
        case .report(uid: _, reporterId: _, reporteeId: _, files: _, description: _):
            return .post
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .report(uid: _, reporterId: _, reporteeId: _, files: let files, description: let description):
            let descriptionData = description.data(using: String.Encoding.utf8) ?? Data()
            var formData: [Moya.MultipartFormData] = [
                Moya.MultipartFormData(provider: .data(descriptionData), name: "description"),
            ]
            files.enumerated().forEach { index, file in
                guard let imageData = file.jpegData(compressionQuality: 1) else {
                    return
                }
                formData.append(
                    Moya.MultipartFormData(
                        provider: .data(imageData),
                        name: "report_image_\(index)",
                        fileName: "report_image_\(index).jpeg",
                        mimeType: "image/jpeg"
                    )
                )
            }
            return .uploadMultipart(formData)
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        switch self {
        case .report(uid: let uid, reporterId: _, reporteeId: _, files: _, description: _):
            headers["uid"] = uid
            return headers
        }
    }
}
