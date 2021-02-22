import Foundation
import UIKit

class RightMessageTableViewCell: UITableViewCell {

    static var identifier: String = "RightMessageTableViewCell"

    private weak var message: MessageDTO?

    lazy private var messageView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryPink
        view.layer.cornerRadius = 8
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        return view
    }()

    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    lazy private var time: UILabel = {
        let label = UILabel()
        label.text = "11:05"
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

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureSubviews() {
        contentView.addSubview(messageView)
        contentView.addSubview(time)
    }

    private func configureConstraints() {
        messageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }

        time.snp.makeConstraints { make in
            make.trailing.equalTo(messageView.snp.leading).inset(-5)
            make.bottom.equalTo(messageView.snp.bottom)
        }
    }

    func bind(message: MessageDTO?) {
        self.message = message
        let text = message?.message ?? ""
        let size = getTextSize(text, padding: 12)
        messageLabel.text = text
        messageView.width(size.width)
        messageView.height(size.height)
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
