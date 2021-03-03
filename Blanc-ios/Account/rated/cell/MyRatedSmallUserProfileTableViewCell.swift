import Foundation
import UIKit

class MyRatedSmallUserProfileTableViewCell: UITableViewCell {

    static var identifier: String = "MyRatedSmallUserProfileTableViewCell"

    private var comment: CommentDTO?

    let ripple: Ripple = Ripple()

    private var rater: RaterDTO?

    private class Const {
        static let imageDiameter: CGFloat = CGFloat(75)
    }

    private var delegate: SmallUserProfileTableViewCellDelegate?

    lazy private var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.width(Const.imageDiameter, priority: 800)
        imageView.height(Const.imageDiameter, priority: 800)
        return imageView
    }()

    lazy private var line1: UILabel = {
        let label = UILabel()
        label.text = "핑크겅듀, 37"
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    lazy private var line2: UILabel = {
        let label = UILabel()
        label.text = "서울특별시, 1km"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()

    lazy private var line3: UILabel = {
        let label = UILabel()
        label.text = "공무원, 대학교"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()

    lazy private var starsView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true

        view.addSubview(star1)
        view.addSubview(star2)
        view.addSubview(star3)
        view.addSubview(star4)
        view.addSubview(star5)

        let size = 15

        star1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(star2.snp.leading)
            make.top.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star2.snp.makeConstraints { make in
            make.trailing.equalTo(star3.snp.leading)
            make.top.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star3.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star4.snp.makeConstraints { make in
            make.leading.equalTo(star3.snp.trailing)
            make.top.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star5.snp.makeConstraints { make in
            make.leading.equalTo(star4.snp.trailing)
            make.top.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
            make.trailing.equalToSuperview()
        }

        return view
    }()

    lazy private var stars: [UIImageView] = {
        [star1, star2, star3, star4, star5]
    }()

    lazy private var star1: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy private var star2: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy private var star3: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy private var star4: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy private var star5: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy private var activatedStar: UIImage? = {
        let image = UIImage(named: "ic_star_bumble_r")
        return image
    }()

    lazy private var inactivatedStar: UIImage? = {
        let image = UIImage(named: "ic_star_gray_r")
        return image
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
        userImage.squircle(22.0)
    }

    private func configureSelf() {
        contentView.isUserInteractionEnabled = true
        ripple.activate(to: contentView)
    }

    private func configureSubviews() {
        contentView.addSubview(userImage)
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(line3)
        contentView.addSubview(starsView)
    }

    private func configureConstraints() {
        userImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
        }

        line1.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.bottom.equalTo(line2.snp.top).inset(-1)
        }

        line2.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.centerY.equalTo(userImage.snp.centerY)
        }

        line3.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.top.equalTo(line2.snp.bottom).inset(-1)
        }

        starsView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    func bind(rater: RaterDTO?) {
        self.rater = rater

        let diameter = Const.imageDiameter
        userImage.url(rater?.user?.avatar, cornerRadius: 0, size: CGSize(width: diameter, height: diameter))
        line1.text = "\(rater?.user?.nickname ?? "알 수 없음"), \(rater?.user?.age ?? -1)"
        line2.text = "\(rater?.user?.area ?? "알 수 없음") · \(rater?.user?.distance ?? "알 수 없음")"
        line3.text = "\(rater?.user?.occupation ?? "알 수 없음") · \(rater?.user?.education ?? "알 수 없음")"
        stars.enumerated().forEach { index, star in
            star.image = (index + 1 <= Int(rater?.score ?? 0.0) ? activatedStar : inactivatedStar)
        }
    }
}
