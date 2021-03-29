import Foundation
import UIKit

class UserCollectionViewCell: UICollectionViewCell {

    static let identifier = "UserCollectionViewCell"

    private var user: UserDTO?

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    lazy private var line1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .black2
        return label
    }()

    lazy private var line2_1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()

    lazy private var bar: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .systemGray
        label.text = "|"
        return label
    }()

    lazy private var line2_2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSelf()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureSelf() {
        contentView.isUserInteractionEnabled = true
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
    }

    private func configureSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(line1)
        contentView.addSubview(line2_1)
        contentView.addSubview(bar)
        contentView.addSubview(line2_2)

    }

    private func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(contentView.snp.width)
        }
        line1.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).inset(-6)
            make.leading.equalToSuperview().inset(5)
            make.trailing.equalToSuperview()
        }
        line2_1.snp.makeConstraints { make in
            make.top.equalTo(line1.snp.bottom).inset(-4)
            make.leading.equalToSuperview().inset(5)
        }
        bar.snp.makeConstraints { make in
            make.centerY.equalTo(line2_1.snp.centerY)
            make.leading.equalTo(line2_1.snp.trailing)
        }
        line2_2.snp.makeConstraints { make in
            make.top.equalTo(line2_1.snp.top)
            make.leading.equalTo(bar.snp.trailing)
        }
    }

    public func bind(_ user: UserDTO) {
        self.user = user
        imageView.url(user.avatar)
        line1.text = user.nickname ?? ""
        line2_1.text = "\(user.age ?? 0) "
        line2_2.text = " \(user.area ?? "")"
    }
}