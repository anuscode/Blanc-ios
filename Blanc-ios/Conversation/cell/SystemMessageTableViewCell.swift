import Foundation
import UIKit


class SystemMessageTableViewCell: UITableViewCell {

    static var identifier: String = "SystemMessageTableViewCell"

    private weak var message: MessageDTO?

    lazy private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
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
        contentView.addSubview(timeLabel)
        contentView.addSubview(messageLabel)
    }

    private func configureConstraints() {
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).inset(4)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    func bind(message: MessageDTO?) {
        self.message = message
        let cal = (message?.createdAt ?? 0).asCalendar()
        timeLabel.text = "\(cal.year)/\(NSString(format: "%02d", cal.month))/\(cal.day)"
        messageLabel.text = message?.message ?? ""
    }
}
