import Foundation
import UIKit

class RightMessageTableViewCell: UITableViewCell {

    static var identifier: String = "RightMessageTableViewCell"

    private weak var message: MessageDTO?

    lazy private var messageView: UIView = {
        let view = UIView()
        view.backgroundColor = .tinderPink
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
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
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
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
        backgroundColor = .clear
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        contentView.addSubview(messageView)
        contentView.addSubview(timeLabel)
    }

    private func configureConstraints() {
        messageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }

        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(messageView.snp.leading).inset(-5)
            make.bottom.equalTo(messageView.snp.bottom)
        }
    }

    func bind(message: MessageDTO?) {
        self.message = message
        let message = message?.message ?? ""
        let time = self.message?.createdAt?.asHourMinute() ?? ""
        let messageViewSize = getMessageViewSize(message, horizontalPadding: 12, verticalPadding: 8)

        messageLabel.text = message
        timeLabel.text = time

        messageView.width(messageViewSize.width)
        messageView.height(messageViewSize.height)
    }

    private func getMessageViewSize(_ text: String, horizontalPadding: CGFloat, verticalPadding: CGFloat) -> CGSize {
        let maxWidth = UIScreen.main.bounds.size.width * 3 / 4
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
