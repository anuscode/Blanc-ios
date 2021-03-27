import Foundation
import UIKit

class LeftMessageTableViewCell: UITableViewCell {

    static var identifier: String = "LeftMessageTableViewCell"

    private weak var message: MessageDTO?

    private class Const {
        static let imageDiameter: CGFloat = CGFloat(40)
    }

    lazy private var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Const.imageDiameter / 2
        imageView.layer.masksToBounds = true
        imageView.width(Const.imageDiameter)
        imageView.height(Const.imageDiameter)
        return imageView
    }()

    lazy private var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 91 / 255, green: 98 / 255, blue: 107 / 255, alpha: 1.0)
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    lazy private var messageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "F0F0F0")
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(6)
        }

        return view
    }()

    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black3
        return label
    }()

    lazy private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 8, weight: .thin)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        contentView.addSubview(userImage)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(messageView)
        contentView.addSubview(timeLabel)
    }

    private func configureConstraints() {
        userImage.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(Const.imageDiameter)
            make.height.equalTo(Const.imageDiameter)
        }

        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.top)
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
        }

        messageView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).inset(-3)
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.bottom.equalToSuperview().inset(5)
        }

        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(messageView.snp.trailing).inset(-5)
            make.bottom.equalTo(messageView.snp.bottom)
        }
    }

    func bind(user: UserDTO?, message: MessageDTO?) {
        self.message = message
        let avatar = user?.avatar
        let nickname = user?.nickname ?? "알 수 없음"
        let message = message?.message ?? ""
        let time = self.message?.createdAt?.asHourMinute() ?? ""
        let messageViewSize = getMessageViewSize(message, horizontalPadding: 12, verticalPadding: 8)
        let imageSize = CGSize(width: Const.imageDiameter, height: Const.imageDiameter)

        userImage.url(avatar, size: imageSize)
        nicknameLabel.text = nickname
        messageLabel.text = message
        timeLabel.text = time

        messageView.width(messageViewSize.width)
        messageView.height(messageViewSize.height)
    }

    private func getMessageViewSize(_ text: String, horizontalPadding: CGFloat, verticalPadding: CGFloat) -> CGSize {
        let imageDiameter: CGFloat = Const.imageDiameter
        let imageLeftPadding: CGFloat = 10
        let imageRightPadding: CGFloat = 10
        let safeWidth = imageDiameter + imageLeftPadding + imageRightPadding
        let maxWidth = UIScreen.main.bounds.size.width * 3 / 4 - safeWidth
        let maxSize = CGSize(width: maxWidth, height: 0)
        var rect = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: messageLabel.font], context: nil)
        rect.size = CGSize(
            width: ceil(rect.size.width) + 2 * horizontalPadding,
            height: ceil(rect.size.height) + 2 * verticalPadding
        )
        return rect.size
    }
}
