import Foundation
import UIKit

class PostManagementHeader: UIView {

    class Constant {
        static let headerImageDiameter: Int = 40
        static let headerHeight: Int = 55
    }

    private weak var post: PostDTO?

    private weak var delegate: PostManagementTableViewCellDelegate?

    lazy private var headerImage: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.layer.cornerRadius = CGFloat(Constant.headerImageDiameter / 2)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy private var headerLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var headerLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var verticalCenterGuideLine: UIView = {
        let view = UIView()
        return view
    }()

    lazy private var deleteImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "trash")
        imageView.image = image
        imageView.tintColor = .black4
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(deletePost))
        return imageView
    }()

    lazy private var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerImage)
        view.addSubview(verticalCenterGuideLine)
        view.addSubview(headerLabel1)
        view.addSubview(headerLabel2)
        view.addSubview(deleteImageView)

        headerImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(Constant.headerImageDiameter)
            make.height.equalTo(Constant.headerImageDiameter)
        }

        verticalCenterGuideLine.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(0)
        }

        headerLabel1.snp.makeConstraints { make in
            make.leading.equalTo(headerImage.snp.trailing).inset(-11)
            make.top.equalToSuperview()
            make.bottom.equalTo(verticalCenterGuideLine.snp.top).inset(13)
        }

        headerLabel2.snp.makeConstraints { make in
            make.leading.equalTo(headerImage.snp.trailing).inset(-11)
            make.top.equalTo(verticalCenterGuideLine.snp.bottom).inset(11)
            make.bottom.equalToSuperview()
        }

        deleteImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureSubviews() {
        addSubview(header)
    }

    private func configureConstraints() {
        header.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc func deletePost() {
        delegate?.deletePost(postId: post?.id)
    }

    func bind(post: PostDTO?, delegate: PostManagementTableViewCellDelegate? = nil) {
        self.post = post
        self.delegate = delegate

        let url = post?.author?.avatar
        let calendar = (post?.createdAt ?? 0).asCalendar()

        headerImage.url(url, size: CGSize(width: Constant.headerImageDiameter, height: Constant.headerImageDiameter))
        headerLabel1.text = "\(post?.author?.nickname ?? "알 수 없음") · \(post?.author?.age ?? -1)"
        headerLabel2.text = "\(calendar.year)/\(calendar.month)/\(calendar.day) 일에 작성 된 게시물"
    }
}