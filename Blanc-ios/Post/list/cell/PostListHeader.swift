import Foundation
import UIKit

protocol PostHeaderDelegate: class {
    func didTapUserImage(user: UserDTO?) -> Void
}

class PostListHeader: UIView {

    class Constant {
        static let headerImageDiameter: Int = 40
        static let headerHeight: Int = 55
    }

    weak var user: UserDTO?

    weak var delegate: PostHeaderDelegate?

    lazy var headerImage: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.layer.cornerRadius = CGFloat(Constant.headerImageDiameter / 2)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapUserImage))
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

    lazy var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerImage)
        view.addSubview(verticalCenterGuideLine)
        view.addSubview(headerLabel1)
        view.addSubview(headerLabel2)

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

    func bind(user: UserDTO?, delegate: PostHeaderDelegate? = nil) {
        self.user = user
        self.delegate = delegate
        headerImage.url(user?.avatar, size: CGSize(width: Constant.headerImageDiameter, height: Constant.headerImageDiameter))
        headerLabel1.text = "\(user?.nickName ?? "알 수 없음") · \(user?.age ?? -1)"
        headerLabel2.text = "\(user?.occupation ?? "알 수 없음") · \(user?.area ?? "알 수 없음")"
    }

    @objc func didTapUserImage() {
        log.info("Touched header user image: \(user?.nickName ?? "")")
        delegate?.didTapUserImage(user: user)
    }
}