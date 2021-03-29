import Foundation
import UIKit

protocol SmallUserProfileTableViewCellDelegate {
    func presentUserSingleView(user: UserDTO?) -> Void
}

class SmallUserProfileTableViewCell: UITableViewCell {

    static var identifier: String = "SmallUserProfileTableViewCell"

    private var comment: CommentDTO?

    private let ripple: Ripple = Ripple()

    private var user: UserDTO?

    private class Const {
        static let diameter: CGFloat = CGFloat(75)
    }

    private var delegate: SmallUserProfileTableViewCellDelegate?

    lazy private var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.width(Const.diameter)
        imageView.height(Const.diameter)
        return imageView
    }()

    lazy private var line1: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    lazy private var line2: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    lazy private var line3: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSelf()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.squircle(22.0)
    }

    private func configureSelf() {
        contentView.backgroundColor = .clear
        contentView.isUserInteractionEnabled = true
        ripple.activate(to: contentView)
        contentView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTableViewCell))
    }

    private func configureSubviews() {
        contentView.addSubview(userImage)
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(line3)
    }

    private func configureConstraints() {
        userImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(Const.diameter)
            make.height.equalTo(Const.diameter)
            make.centerY.equalToSuperview()
        }

        line1.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.bottom.equalTo(line2.snp.top).inset(-1)
        }

        line2.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.centerY.equalToSuperview().multipliedBy(1.05)
        }

        line3.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.top.equalTo(line2.snp.bottom).inset(-2)
        }
    }

    func bind(user: UserDTO?, delegate: SmallUserProfileTableViewCellDelegate?) {
        self.user = user
        self.delegate = delegate

        let diameter = Const.diameter
        userImage.url(user?.avatar, cornerRadius: 0, size: CGSize(width: diameter, height: diameter))
        line1.text = "\(user?.nickname ?? "알 수 없음"), \(user?.age ?? -1)"
        line2.text = "\(user?.area ?? "알 수 없음") · \(user?.relationship?.distance ?? "알 수 없음")"
        line3.text = "\(user?.occupation ?? "알 수 없음") · \(user?.education ?? "알 수 없음")"
    }

    @objc func didTapTableViewCell() {
        delegate?.presentUserSingleView(user: user)
    }
}
