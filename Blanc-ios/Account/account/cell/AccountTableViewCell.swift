import Foundation
import UIKit

class AccountTableViewCell: UITableViewCell {

    static var identifier: String = "AccountTableViewCell"

    let ripple: Ripple = Ripple()

    lazy private var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.width(20)
        imageView.height(20)
        imageView.tintColor = .black
        return imageView
    }()

    lazy private var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    lazy private var forward: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_forward")
        imageView.width(10)
        imageView.height(10)
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
        ripple.activate(to: contentView)
    }

    private func configureSubviews() {
        contentView.addSubview(icon)
        contentView.addSubview(label)
        contentView.addSubview(forward)
    }

    private func configureConstraints() {
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).inset(-10)
            make.centerY.equalToSuperview()
        }

        forward.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(15)
        }
    }

    func bind(_ data: AccountData) {
        label.text = data.title
        icon.image = UIImage(systemName: data.icon)
    }
}
