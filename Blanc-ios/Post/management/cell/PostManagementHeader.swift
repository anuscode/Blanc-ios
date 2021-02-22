import Foundation
import UIKit

class PostManagementHeader: UIView {

    class Constant {
        static let headerImageDiameter: Int = 40
        static let headerHeight: Int = 55
    }

    lazy var headerImage: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.layer.cornerRadius = CGFloat(Constant.headerImageDiameter / 2)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var headerLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var headerLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var verticalCenterGuideLine: UIView = {
        let view = UIView()
        return view
    }()

    lazy var deleteLabel: UILabel = {
        let label = UILabel()
        label.text = "삭제"
        label.textColor = .systemBlue
        return label
    }()

    lazy var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerImage)
        view.addSubview(verticalCenterGuideLine)
        view.addSubview(headerLabel1)
        view.addSubview(headerLabel2)
        view.addSubview(deleteLabel)

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
            make.bottom.equalTo(verticalCenterGuideLine.snp.top).inset(9)
        }

        headerLabel2.snp.makeConstraints { make in
            make.leading.equalTo(headerImage.snp.trailing).inset(-11)
            make.top.equalTo(verticalCenterGuideLine.snp.bottom).inset(7)
            make.bottom.equalToSuperview()
        }

        deleteLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
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

    func bind(post: PostDTO?) {
        headerImage.url(post?.author?.avatar, size: CGSize(width: Constant.headerImageDiameter, height: Constant.headerImageDiameter))
        headerLabel1.text = "\(post?.author?.nickName ?? "알 수 없음") · \(post?.author?.age ?? -1)"
        let calendar = Time.convertTimestampToCalendar(timestamp: post?.createdAt ?? 0)
        headerLabel2.text = "\(calendar.year)/\(calendar.month)/\(calendar.day) 일에 작성 된 게시물"
    }
}