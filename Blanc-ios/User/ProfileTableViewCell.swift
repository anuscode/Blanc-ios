import Foundation
import UIKit
import RxSwift
import FSPagerView
import TTGTagCollectionView

protocol ProfileCellDelegate: class {
    func rate(user: UserDTO?, score: Int)
}

class ProfileTableViewCell: UITableViewCell {
    static let identifier: String = "ProfileCell"

    private let fontSize: CGFloat = 14

    private let itemMargin: Int = -15

    private let valueColor: UIColor = .darkText

    private let titleColor: UIColor = .darkGray

    private weak var user: UserDTO?

    private weak var delegate: ProfileCellDelegate?

    lazy private var introductionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.text = "fuck"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var heightTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "키"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var heightValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "키 value"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bodyTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "체형"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bodyTypeValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "체형 value"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var educationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "학력"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var educationValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "학력 value"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var occupationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "교육"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var occupationValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "교육 값"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var religionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "종교"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var religionValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "종교 값"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var drinkTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "주량"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var drinkValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "주량 값"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var smokingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "흡연"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var smokingValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "흡연 값"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bloodTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "혈액형"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bloodTypeValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = valueColor
        label.numberOfLines = 0
        label.text = "혈액형 값"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var border1: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()

    lazy private var starLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.text = "핑크겅듀님의 매력을 평가해 주세요."
        label.textAlignment = .center
        label.textColor = titleColor
        return label
    }()

    lazy private var stars: [UIImageView] = {
        [star1, star2, star3, star4, star5]
    }()

    lazy private var star1: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_gray_r")
        let gesture = StarTapGesture(target: self, action: #selector(didTapStarImage))
        gesture.index = 0
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()

    lazy private var star2: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_gray_r")
        let gesture = StarTapGesture(target: self, action: #selector(didTapStarImage))
        gesture.index = 1
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()

    lazy private var star3: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_gray_r")
        let gesture = StarTapGesture(target: self, action: #selector(didTapStarImage))
        gesture.index = 2
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()

    lazy private var star4: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_gray_r")
        let gesture = StarTapGesture(target: self, action: #selector(didTapStarImage))
        gesture.index = 3
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()

    lazy private var star5: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_gray_r")
        let gesture = StarTapGesture(target: self, action: #selector(didTapStarImage))
        gesture.index = 4
        imageView.addGestureRecognizer(gesture)
        return imageView
    }()

    lazy private var starsView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true

        view.addSubview(starLabel)
        view.addSubview(star1)
        view.addSubview(star2)
        view.addSubview(star3)
        view.addSubview(star4)
        view.addSubview(star5)

        let size = 40
        let margin = -6

        starLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        star1.snp.makeConstraints { make in
            make.trailing.equalTo(star2.snp.leading).inset(margin)
            make.top.equalTo(starLabel.snp.bottom)
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star2.snp.makeConstraints { make in
            make.trailing.equalTo(star3.snp.leading).inset(margin)
            make.top.equalTo(starLabel.snp.bottom)
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star3.snp.makeConstraints { make in
            make.top.equalTo(starLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star4.snp.makeConstraints { make in
            make.leading.equalTo(star3.snp.trailing).inset(margin)
            make.top.equalTo(starLabel.snp.bottom)
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star5.snp.makeConstraints { make in
            make.leading.equalTo(star4.snp.trailing).inset(margin)
            make.top.equalTo(starLabel.snp.bottom)
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        return view
    }()

    lazy private var border2: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()

    private let config: TTGTextTagConfig = {
        let config = TTGTextTagConfig()
        config.backgroundColor = .secondarySystemBackground
        config.cornerRadius = 8
        config.textColor = .black
        config.textFont = UIFont.systemFont(ofSize: 13)
        config.borderColor = .secondarySystemBackground
        config.shadowOpacity = 0
        config.selectedBackgroundColor = .secondarySystemBackground
        config.selectedCornerRadius = 8
        config.selectedTextColor = .black
        config.exactHeight = 30
        config.extraSpace = CGSize(width: 20, height: 0)
        return config
    }()

    lazy private var charmTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "매력어필"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var charmValueView: UIView = {
        let view = UIView()
        view.addSubview(charmCollectionView)
        charmCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var charmCollectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        return collectionView
    }()

    lazy private var idealTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "이상형"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var idealTypeValueView: UIView = {
        let view = UIView()
        view.addSubview(idealTypeCollectionView)
        idealTypeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var idealTypeCollectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        return collectionView
    }()

    lazy private var interestsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .left
        label.textColor = titleColor
        label.text = "관심사"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var interestsValueView: UIView = {
        let view = UIView()
        view.addSubview(interestsCollectionView)
        interestsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var interestsCollectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        return collectionView
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
        contentView.addSubview(introductionLabel)
        contentView.addSubview(heightTitleLabel)
        contentView.addSubview(heightValueLabel)
        contentView.addSubview(bodyTypeTitleLabel)
        contentView.addSubview(bodyTypeValueLabel)
        contentView.addSubview(occupationTitleLabel)
        contentView.addSubview(occupationValueLabel)
        contentView.addSubview(educationTitleLabel)
        contentView.addSubview(educationValueLabel)
        contentView.addSubview(religionTitleLabel)
        contentView.addSubview(religionValueLabel)
        contentView.addSubview(drinkTitleLabel)
        contentView.addSubview(drinkValueLabel)
        contentView.addSubview(smokingTitleLabel)
        contentView.addSubview(smokingValueLabel)
        contentView.addSubview(bloodTypeTitleLabel)
        contentView.addSubview(bloodTypeValueLabel)
        contentView.addSubview(border1)
        contentView.addSubview(starsView)
        contentView.addSubview(border2)
        contentView.addSubview(charmTitleLabel)
        contentView.addSubview(charmValueView)
        contentView.addSubview(idealTypeTitleLabel)
        contentView.addSubview(idealTypeValueView)
        contentView.addSubview(interestsTitleLabel)
        contentView.addSubview(interestsValueView)
    }

    private func configureConstraints() {
        introductionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(heightTitleLabel.snp.top).inset(itemMargin)
        }

        heightTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(introductionLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(bodyTypeTitleLabel.snp.top).inset(itemMargin)
        }

        heightValueLabel.snp.makeConstraints { make in
            make.top.equalTo(heightTitleLabel.snp.top)
            make.bottom.equalTo(heightTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        bodyTypeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(heightTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(educationTitleLabel.snp.top).inset(itemMargin)
        }

        bodyTypeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(bodyTypeTitleLabel.snp.top)
            make.bottom.equalTo(bodyTypeTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        educationTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bodyTypeTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(occupationTitleLabel.snp.top).inset(itemMargin)
        }

        educationValueLabel.snp.makeConstraints { make in
            make.top.equalTo(educationTitleLabel.snp.top)
            make.bottom.equalTo(educationTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        occupationTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(educationTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(religionTitleLabel.snp.top).inset(itemMargin)
        }

        occupationValueLabel.snp.makeConstraints { make in
            make.top.equalTo(occupationTitleLabel.snp.top)
            make.bottom.equalTo(occupationTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        religionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(occupationTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(drinkTitleLabel.snp.top).inset(itemMargin)
        }

        religionValueLabel.snp.makeConstraints { make in
            make.top.equalTo(religionTitleLabel.snp.top)
            make.bottom.equalTo(religionTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        drinkTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(religionTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(smokingTitleLabel.snp.top).inset(itemMargin)
        }

        drinkValueLabel.snp.makeConstraints { make in
            make.top.equalTo(drinkTitleLabel.snp.top)
            make.bottom.equalTo(drinkTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        smokingTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(drinkTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(bloodTypeTitleLabel.snp.top).inset(itemMargin)
        }

        smokingValueLabel.snp.makeConstraints { make in
            make.top.equalTo(smokingTitleLabel.snp.top)
            make.bottom.equalTo(smokingTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        bloodTypeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(smokingTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(border1.snp.top).inset(itemMargin)
        }

        bloodTypeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(bloodTypeTitleLabel.snp.top)
            make.bottom.equalTo(bloodTypeTitleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(120)
        }

        border1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(bloodTypeTitleLabel.snp.bottom)
            make.bottom.equalTo(starsView.snp.top).inset(itemMargin)
        }

        starsView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(border1.snp.bottom)
            make.bottom.equalTo(border2.snp.top).inset(itemMargin)
        }

        border2.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(starsView.snp.bottom)
            make.bottom.equalTo(charmTitleLabel.snp.top).inset(itemMargin)
        }

        charmTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(border2.snp.bottom)
            make.leading.equalToSuperview().inset(20)
        }

        charmValueView.snp.makeConstraints { make in
            make.top.equalTo(charmTitleLabel.snp.top)
            make.bottom.equalTo(idealTypeTitleLabel.snp.top).inset(itemMargin)
            make.leading.equalToSuperview().inset(120)
            make.trailing.equalToSuperview().inset(20)
        }

        idealTypeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(charmValueView.snp.bottom)
            make.leading.equalToSuperview().inset(20)
        }

        idealTypeValueView.snp.makeConstraints { make in
            make.top.equalTo(idealTypeTitleLabel.snp.top)
            make.bottom.equalTo(interestsTitleLabel.snp.top).inset(itemMargin)
            make.leading.equalToSuperview().inset(120)
            make.trailing.equalToSuperview().inset(20)
        }

        interestsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(idealTypeValueView.snp.bottom)
            make.leading.equalToSuperview().inset(20)
        }

        interestsValueView.snp.makeConstraints { make in
            make.top.equalTo(interestsTitleLabel.snp.top)
            make.bottom.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(120)
            make.trailing.equalToSuperview().inset(20)
        }
    }

    private func configureLabelValues() {
        let introduction = user?.introduction.isNotEmpty() == true ? user?.introduction : "\n등록 된 자기소개가 없습니다.\n"
        introductionLabel.text = introduction
        heightValueLabel.text = "\(user?.height ?? 0) cm"
        bodyTypeValueLabel.text = user?.bodyType
        occupationValueLabel.text = user?.occupation
        educationValueLabel.text = user?.education
        religionValueLabel.text = user?.religion
        drinkValueLabel.text = user?.drink
        smokingValueLabel.text = user?.smoking
        bloodTypeValueLabel.text = user?.blood
    }

    private func configureTagValues() {
        charmCollectionView.removeAllTags()
        if (user?.charmIds != nil && (user?.charmIds?.count ?? 0) > 0) {
            charmCollectionView.addTags(user?.charmIds?.map({ (index: Int) -> String in
                UserGlobal.charms[index]
            }), with: config)
        }

        idealTypeCollectionView.removeAllTags()
        if (user?.idealTypeIds != nil && (user?.idealTypeIds?.count ?? 0) > 0) {
            idealTypeCollectionView.addTags(user?.idealTypeIds?.map({ (index: Int) -> String in
                UserGlobal.idealTypes[index]
            }), with: config)
        }

        interestsCollectionView.removeAllTags()
        if (user?.interestIds != nil && (user?.interestIds?.count ?? 0) > 0) {
            interestsCollectionView.addTags(user?.interestIds?.map({ (index: Int) -> String in
                UserGlobal.interests[index]
            }), with: config)
        }
    }

    private func configureStarRatingValues() {
        let starRating = user?.relationship?.starRating
        let score = user?.relationship?.starRating?.score
        rate(score: score)
        if (starRating?.score != nil && starRating!.score! > 0) {
            log.info("removing star tap listener..")
            stars.forEach { star in
                star.isUserInteractionEnabled = false
            }
        }
    }

    func bind(user: UserDTO?, delegate: ProfileCellDelegate) {
        self.user = user
        self.delegate = delegate
        configureLabelValues()
        configureTagValues()
        configureStarRatingValues()
    }

    private func rate(score: Int?) {
        let threshold = (score ?? -1)
        let bumbleStar = UIImage(named: "ic_star_bumble_r")
        let whiteStar = UIImage(named: "ic_star_gray_r")
        for i in 0...4 {
            let star = stars[i]
            if (i < threshold) {
                star.image = bumbleStar
            } else {
                star.image = whiteStar
            }
        }
    }

    @objc func didTapStarImage(sender: StarTapGesture) {
        let score = sender.index! + 1
        log.info("didTapStarImage(sender: StarTapGesture)")
        // update view first.
        rate(score: score)
        // update model and server side.
        delegate?.rate(user: user, score: score)
    }
}