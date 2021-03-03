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
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    lazy private var messageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "F0F0F0")
        view.layer.cornerRadius = 10
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        return view
    }()

    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.textColor = .lightBlack
        return label
    }()

    lazy private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 10, weight: .thin)
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
            make.leading.equalTo(userImage.snp.trailing).inset(-5)
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
        let textSize = getTextSize(message, padding: 12)
        let imageSize = CGSize(width: Const.imageDiameter, height: Const.imageDiameter)

        userImage.url(avatar, size: imageSize)
        nicknameLabel.text = nickname
        messageLabel.text = message
        timeLabel.text = time

        messageView.width(textSize.width)
        messageView.height(textSize.height)
    }

    private func getTextSize(_ text: String, padding: CGFloat) -> CGSize {
        let maxWidth = UIScreen.main.bounds.size.width * 3 / 4
        let maxSize = CGSize(width: maxWidth, height: 0)
        var rect = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: messageLabel.font], context: nil)
        rect.size = CGSize(width: ceil(rect.size.width) + 2 * padding, height: ceil(rect.size.height) + 2 * padding)
        return rect.size
    }
}
