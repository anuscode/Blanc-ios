import Foundation
import UIKit

class AvoidTableViewCell: UITableViewCell {

    static var identifier: String = "AvoidTableViewCell"

    private var contact: Contact?

    lazy private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    lazy private var phoneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()

    lazy private var checked: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_checked_bumble_4")
        return imageView
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
    }

    private func configureSelf() {
        selectionStyle = .none
    }

    private func configureSubviews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(checked)
    }

    private func configureConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).inset(-5)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }

        checked.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
    }

    func bind(contact: Contact) {
        self.contact = contact
        nameLabel.text = "\(contact.name)"
        phoneLabel.text = "\(contact.phoneNumber)"
    }
}
