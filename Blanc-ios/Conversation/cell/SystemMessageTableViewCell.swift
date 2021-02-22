import Foundation
import UIKit


class SystemMessageTableViewCell: UITableViewCell {

    static var identifier: String = "SystemMessageTableViewCell"

    private weak var message: MessageDTO?

    lazy private var timeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().inset(15)
        }
        return view
    }()

    lazy private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .light)
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
        contentView.addSubview(timeView)
        contentView.addSubview(messageLabel)
    }

    private func configureConstraints() {
        timeView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    func bind(message: MessageDTO?) {
        self.message = message
        let cal = Time.convertTimestampToCalendar(timestamp: message?.createdAt ?? 0)
        timeLabel.text = "\(cal.year)/\(NSString(format: "%02d", cal.month))/\(cal.day)"
        messageLabel.text = message?.message ?? ""
    }
}
