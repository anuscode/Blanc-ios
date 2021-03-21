import Foundation
import UIKit

protocol PostHeaderDelegate: class {
    func didTapUserImage(user: UserDTO?) -> Void
    func didTapOption(user: UserDTO?) -> Void
}

class PostListHeader: UIView {

    class Constant {
        static let headerImageDiameter: CGFloat = 40
        static let headerHeight: Int = 55
        static let optionImageDiameter: CGFloat = 28
    }

    private let ripple: Ripple = Ripple()

    private weak var user: UserDTO?

    private weak var delegate: PostHeaderDelegate?

    lazy private var headerImage: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.layer.cornerRadius = Constant.headerImageDiameter / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapUserImage))
        return imageView
    }()

    lazy private var headerLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkText
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

    lazy private var optionImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_more_vert")
        imageView.image = image
        imageView.layer.cornerRadius = Constant.optionImageDiameter / 2
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapOptionImageView))
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var header: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerImage)
        view.addSubview(verticalCenterGuideLine)
        view.addSubview(headerLabel1)
        view.addSubview(headerLabel2)
        view.addSubview(optionImageView)

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
            make.leading.equalTo(headerImage.snp.trailing).inset(-12)
            make.top.equalToSuperview()
            make.bottom.equalTo(verticalCenterGuideLine.snp.top).inset(11)
        }

        headerLabel2.snp.makeConstraints { make in
            make.leading.equalTo(headerImage.snp.trailing).inset(-12)
            make.top.equalTo(verticalCenterGuideLine.snp.bottom).inset(9)
            make.bottom.equalToSuperview()
        }

        optionImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(Constant.optionImageDiameter)
            make.height.equalTo(Constant.optionImageDiameter)
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

        let url = user?.avatar
        let size = CGSize(width: Constant.headerImageDiameter, height: Constant.headerImageDiameter)
        let text1 = "\(user?.nickname ?? "알 수 없음") · \(user?.age ?? -1)"
        let text2 = "\(user?.occupation ?? "알 수 없음") · \(user?.area ?? "알 수 없음")"

        headerImage.url(url, size: size)
        headerLabel1.text = text1
        headerLabel2.text = text2
    }

    @objc func didTapUserImage() {
        log.info("Touched header user image: \(user?.nickname ?? "")")
        delegate?.didTapUserImage(user: user)
    }

    @objc func didTapOptionImageView() {
        delegate?.didTapOption(user: user)
    }
}