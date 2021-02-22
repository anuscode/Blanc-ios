import Foundation
import UIKit

class AccountProfileTableViewCell: UITableViewCell {

    static var identifier: String = "AccountProfileTableViewCell"

    let ripple: Ripple = Ripple()

    var session: Session?

    lazy var semiProfileView: UIView = {
        let view = UIView()
        view.addSubview(currentUserImage)
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(line3)

        currentUserImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }

        line1.snp.makeConstraints { make in
            make.leading.equalTo(currentUserImage.snp.trailing).inset(-15)
            make.bottom.equalTo(line2.snp.top)
        }

        line2.snp.makeConstraints { make in
            make.leading.equalTo(currentUserImage.snp.trailing).inset(-15)
            make.centerY.equalToSuperview()
        }

        line3.snp.makeConstraints { make in
            make.leading.equalTo(currentUserImage.snp.trailing).inset(-15)
            make.top.equalTo(line2.snp.bottom)
        }

        return view
    }()

    lazy var currentUserImage: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let imageView = UIImageView()
        imageView.layer.cornerRadius = screenWidth / 10
        imageView.layer.masksToBounds = true
        imageView.width(screenWidth / 5)
        imageView.height(screenWidth / 5)
        imageView.url(session?.user?.avatar)
        return imageView
    }()

    lazy var line1: UILabel = {
        let label = UILabel()
        label.text = "\(session?.user?.nickName ?? "등록되지 않은 항목")"
        label.font = .systemFont(ofSize: 22)
        return label
    }()

    lazy var line2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        let area = session?.user?.area ?? "등록되지 않은 항목"
        let age = session?.user?.age ?? -1
        label.text = "\(area) · \(age)"
        return label
    }()

    lazy var line3: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        let occupation = session?.user?.occupation ?? "등록되지 않은 항목"
        let education = session?.user?.education ?? "등록되지 않은 항목"
        label.text = "\(occupation) · \(education)"
        return label
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
        contentView.addSubview(semiProfileView)
    }

    private func configureConstraints() {
        semiProfileView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func bind(session: Session?) {
        self.session = session
    }
}
