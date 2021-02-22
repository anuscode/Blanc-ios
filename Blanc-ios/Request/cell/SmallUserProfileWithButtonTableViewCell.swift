import Foundation
import UIKit

protocol SmallUserProfileWithButtonTableViewCellDelegate: SmallUserProfileTableViewCellDelegate {
    func accept(request: RequestDTO?) -> Void
    func decline(request: RequestDTO?) -> Void
}

class SmallUserProfileWithButtonTableViewCell: SmallUserProfileTableViewCell {

    private var delegate: SmallUserProfileWithButtonTableViewCellDelegate?

    private var request: RequestDTO?

    lazy private var acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("수락", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        button.backgroundColor = .bumble3
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(accept), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var declineButton: UIButton = {
        let button = UIButton()
        button.setTitle("거절", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(self, action: #selector(decline), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(acceptButton)
        addSubview(declineButton)

        acceptButton.snp.makeConstraints { make in
            make.trailing.equalTo(declineButton.snp.leading).inset(-5)
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }

        declineButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(request: RequestDTO?, delegate: SmallUserProfileWithButtonTableViewCellDelegate?) {
        self.request = request
        self.delegate = delegate
        self.bind(user: request?.userFrom, delegate: delegate)
    }

    @objc func accept() {
        delegate?.accept(request: request)
    }

    @objc func decline() {
        delegate?.decline(request: request)
    }
}
