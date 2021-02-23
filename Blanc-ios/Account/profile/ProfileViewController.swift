import Foundation
import UIKit
import RxSwift
import SnapKit
import TTGTagCollectionView
import SwinjectStoryboard

class ProfileViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple = Ripple()

    var profileViewModel: ProfileViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "프로필 변경"))
    }()

    lazy private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let config: TTGTextTagConfig = {
        let config = TTGTextTagConfig()
        config.backgroundColor = .secondarySystemBackground
        config.cornerRadius = 5
        config.textColor = .black
        config.textFont = UIFont.systemFont(ofSize: 14)
        config.borderColor = .secondarySystemBackground
        config.shadowOpacity = 0
        config.selectedBackgroundColor = .secondarySystemBackground
        config.selectedCornerRadius = 5
        config.selectedTextColor = .black
        config.exactHeight = 36
        config.extraSpace = CGSize(width: 20, height: 0)
        return config
    }()

    lazy private var nicknameLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nicknameTitleLabel)
        view.addSubview(nicknameValueLabel)
        return view
    }()

    lazy private var nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var nicknameValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var sexLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sexTitleLabel)
        view.addSubview(sexValueLabel)
        return view
    }()

    lazy private var sexTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var sexValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var birthdayLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popBirthday))
        view.addSubview(birthdayTitleLabel)
        view.addSubview(birthdayValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var birthdayTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var birthdayValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var guideLine1: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    lazy private var heightLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popHeight))
        view.addSubview(heightTitleLabel)
        view.addSubview(heightValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var heightTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "키"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var heightValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bodyTypeLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popBodyType))
        view.addSubview(bodyTitleTypeLabel)
        view.addSubview(bodyTypeValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var bodyTitleTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "체형"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bodyTypeValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var guideLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    lazy private var occupationLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popOccupation))
        view.addSubview(occupationTitleLabel)
        view.addSubview(occupationValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var occupationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "직업"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var occupationValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var educationLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popEducation))
        view.addSubview(educationTitleLabel)
        view.addSubview(educationValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var educationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "학력"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var educationValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var guideLine3: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    lazy private var religionLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popReligion))
        view.addSubview(religionTitleLabel)
        view.addSubview(religionValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var religionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "종교"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var religionValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var drinkLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popDrink))
        view.addSubview(drinkTitleLabel)
        view.addSubview(drinkValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var drinkTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "주량"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var drinkValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var smokingLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popSmoking))
        view.addSubview(smokingTitleLabel)
        view.addSubview(smokingValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var smokingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "흡연"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var smokingValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bloodTypeLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popBloodType))
        view.addSubview(bloodTypeTitleLabel)
        view.addSubview(bloodTypeValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var bloodTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "혈액형"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var bloodTypeValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var guideLine4: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    lazy private var introductionLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popIntroduction))
        view.addSubview(introductionTitleLabel)
        view.addSubview(introductionValueLabel)
        ripple.activate(to: view)
        return view
    }()

    lazy private var introductionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "자기소개"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var introductionValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var guideLine5: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    lazy private var charmLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popCharm))
        view.addSubview(charmTitleLabel)
        view.addSubview(charmCollectionView)
        ripple.activate(to: view)
        return view
    }()

    lazy private var charmTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "매력 어필"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var charmCollectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        collectionView.delegate = charmDelegate
        return collectionView
    }()

    lazy private var guideLine6: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    lazy private var idealTypeLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popIdealType))
        view.addSubview(idealTypeTitleLabel)
        view.addSubview(idealTypeCollectionView)
        ripple.activate(to: view)
        return view
    }()

    lazy private var idealTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이상형"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var idealTypeCollectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        collectionView.delegate = idealTypeDelegate
        return collectionView
    }()

    lazy private var guideLine7: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    lazy private var interestsLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(popInterests))
        view.addSubview(interestsTitleLabel)
        view.addSubview(interestsCollectionView)
        ripple.activate(to: view)
        return view
    }()

    lazy private var interestsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심사"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .deepGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var interestsCollectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.delegate = interestsDelegate
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        return collectionView
    }()

    lazy private var bottomGuideLine: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()

    lazy private var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    lazy private var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bumble3
        button.setTitle("저장", for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return button
    }()

    lazy private var transparentView: UIView = {
        let view = UIView()
        view.alpha = 0.4
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.visible(false)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTransparent))
        return view
    }()

    lazy private var charmDelegate: CharmDelegate = {
        CharmDelegate(parent: self)
    }()

    lazy private var idealTypeDelegate: IdealTypeDelegate = {
        IdealTypeDelegate(parent: self)
    }()

    lazy private var interestsDelegate: InterestsDelegate = {
        InterestsDelegate(parent: self)
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.barTintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configConstraints()
        subscribeViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwinjectStoryboard.defaultContainer.resetObjectScope(.profileScope)
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        view.addSubview(bottomView)
        view.addSubview(transparentView)

        scrollView.addSubview(nicknameLine)
        scrollView.addSubview(sexLine)
        scrollView.addSubview(birthdayLine)
        scrollView.addSubview(guideLine1)
        scrollView.addSubview(heightLine)
        scrollView.addSubview(bodyTypeLine)
        scrollView.addSubview(guideLine2)
        scrollView.addSubview(occupationLine)
        scrollView.addSubview(educationLine)
        scrollView.addSubview(guideLine3)
        scrollView.addSubview(religionLine)
        scrollView.addSubview(drinkLine)
        scrollView.addSubview(smokingLine)
        scrollView.addSubview(bloodTypeLine)
        scrollView.addSubview(guideLine4)
        scrollView.addSubview(introductionLine)
        scrollView.addSubview(guideLine5)
        scrollView.addSubview(charmLine)
        scrollView.addSubview(guideLine6)
        scrollView.addSubview(idealTypeLine)
        scrollView.addSubview(guideLine7)
        scrollView.addSubview(interestsLine)

        bottomView.addSubview(saveButton)
    }

    private func configConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(interestsLine.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        configLineConstraints(
                line: nicknameLine,
                titleLabel: nicknameTitleLabel,
                valueLabel: nicknameValueLabel,
                top: scrollView.snp.top)

        configLineConstraints(
                line: sexLine,
                titleLabel: sexTitleLabel,
                valueLabel: sexValueLabel,
                top: nicknameLine.snp.bottom)

        configLineConstraints(
                line: birthdayLine,
                titleLabel: birthdayTitleLabel,
                valueLabel: birthdayValueLabel,
                top: sexLine.snp.bottom)

        guideLine1.snp.makeConstraints { make in
            make.top.equalTo(birthdayLine.snp.bottom)
            make.width.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        configLineConstraints(
                line: heightLine,
                titleLabel: heightTitleLabel,
                valueLabel: heightValueLabel,
                top: birthdayLine.snp.bottom)

        configLineConstraints(
                line: bodyTypeLine,
                titleLabel: bodyTitleTypeLabel,
                valueLabel: bodyTypeValueLabel,
                top: heightLine.snp.bottom)

        guideLine2.snp.makeConstraints { make in
            make.top.equalTo(bodyTypeLine.snp.bottom)
            make.width.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        configLineConstraints(
                line: occupationLine,
                titleLabel: occupationTitleLabel,
                valueLabel: occupationValueLabel,
                top: bodyTypeLine.snp.bottom)

        configLineConstraints(
                line: educationLine,
                titleLabel: educationTitleLabel,
                valueLabel: educationValueLabel,
                top: occupationLine.snp.bottom)

        guideLine3.snp.makeConstraints { make in
            make.top.equalTo(educationLine.snp.bottom)
            make.width.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        configLineConstraints(
                line: religionLine,
                titleLabel: religionTitleLabel,
                valueLabel: religionValueLabel,
                top: educationLine.snp.bottom)

        configLineConstraints(
                line: drinkLine,
                titleLabel: drinkTitleLabel,
                valueLabel: drinkValueLabel,
                top: religionLine.snp.bottom)

        configLineConstraints(
                line: smokingLine,
                titleLabel: smokingTitleLabel,
                valueLabel: smokingValueLabel,
                top: drinkLine.snp.bottom)

        configLineConstraints(
                line: bloodTypeLine,
                titleLabel: bloodTypeTitleLabel,
                valueLabel: bloodTypeValueLabel,
                top: smokingLine.snp.bottom)

        guideLine4.snp.makeConstraints { make in
            make.top.equalTo(bloodTypeLine.snp.bottom)
            make.width.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        introductionLine.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(bloodTypeLine.snp.bottom)
            make.height.equalTo(100)
            make.bottom.equalTo(introductionValueLabel.snp.bottom)
        }

        introductionTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        introductionValueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(120)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        guideLine5.snp.makeConstraints { make in
            make.top.equalTo(introductionLine.snp.bottom)
            make.width.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        configLineConstraints(
                line: charmLine,
                titleLabel: charmTitleLabel,
                collectionView: charmCollectionView,
                top: introductionLine.snp.bottom
        )

        guideLine6.snp.makeConstraints { make in
            make.top.equalTo(charmLine.snp.bottom)
            make.width.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        configLineConstraints(
                line: idealTypeLine,
                titleLabel: idealTypeTitleLabel,
                collectionView: idealTypeCollectionView,
                top: charmLine.snp.bottom
        )

        guideLine7.snp.makeConstraints { make in
            make.top.equalTo(idealTypeLine.snp.bottom)
            make.width.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        configLineConstraints(
                line: interestsLine,
                titleLabel: interestsTitleLabel,
                collectionView: interestsCollectionView,
                top: idealTypeLine.snp.bottom
        )

        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view.snp.centerX)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(55)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        transparentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(bottomView.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    @objc private func popBirthday() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let birthdayViewController = (storyboard.instantiateViewController(
                withIdentifier: "BirthdayViewController") as! BirthdayViewController)
        addChild(birthdayViewController)
        showFragment(subView: birthdayViewController.view)
    }

    @objc private func popHeight() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let heightViewController = (storyboard.instantiateViewController(
                withIdentifier: "HeightViewController") as! HeightViewController)
        addChild(heightViewController)
        showFragment(subView: heightViewController.view)
    }

    @objc private func popBodyType() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let bodyTypeViewController = (storyboard.instantiateViewController(
                withIdentifier: "BodyTypeViewController") as! BodyTypeViewController)
        addChild(bodyTypeViewController)
        showFragment(subView: bodyTypeViewController.view)
    }

    @objc private func popOccupation() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let occupationViewController = (storyboard.instantiateViewController(
                withIdentifier: "OccupationViewController") as! OccupationViewController)
        addChild(occupationViewController)
        showFragment(subView: occupationViewController.view)
    }

    @objc private func popEducation() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let educationViewController = (storyboard.instantiateViewController(
                withIdentifier: "EducationViewController") as! EducationViewController)
        addChild(educationViewController)
        showFragment(subView: educationViewController.view)
    }

    @objc private func popReligion() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let religionViewController = (storyboard.instantiateViewController(
                withIdentifier: "ReligionViewController") as! ReligionViewController)
        addChild(religionViewController)
        showFragment(subView: religionViewController.view)
    }

    @objc private func popDrink() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let drinkViewController = (storyboard.instantiateViewController(
                withIdentifier: "DrinkViewController") as! DrinkViewController)
        addChild(drinkViewController)
        showFragment(subView: drinkViewController.view)
    }

    @objc private func popSmoking() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let smokingViewController = (storyboard.instantiateViewController(
                withIdentifier: "SmokingViewController") as! SmokingViewController)
        addChild(smokingViewController)
        showFragment(subView: smokingViewController.view)
    }

    @objc private func popBloodType() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let bloodTypeViewController = (storyboard.instantiateViewController(
                withIdentifier: "BloodTypeViewController") as! BloodTypeViewController)
        addChild(bloodTypeViewController)
        showFragment(subView: bloodTypeViewController.view)
    }

    @objc private func popIntroduction() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let introductionViewController = (storyboard.instantiateViewController(
                withIdentifier: "IntroductionViewController") as! IntroductionViewController)
        addChild(introductionViewController)
        showFragment(subView: introductionViewController.view)
    }

    @objc fileprivate func popCharm() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let charmViewController = (storyboard.instantiateViewController(
                withIdentifier: "CharmViewController") as! CharmViewController)
        addChild(charmViewController)
        showFragment(subView: charmViewController.view)
    }

    @objc fileprivate func popIdealType() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let idealTypeViewController = (storyboard.instantiateViewController(
                withIdentifier: "IdealTypeViewController") as! IdealTypeViewController)
        addChild(idealTypeViewController)
        showFragment(subView: idealTypeViewController.view)
    }

    @objc fileprivate func popInterests() {
        let storyboard = UIStoryboard(name: "ProfileFragments", bundle: nil)
        let interestsViewController = (storyboard.instantiateViewController(
                withIdentifier: "InterestsViewController") as! InterestsViewController)
        addChild(interestsViewController)
        showFragment(subView: interestsViewController.view)
    }

    @objc func didTapTransparent(_ sender: UITapGestureRecognizer) {
        clearFragments()
    }

    @objc func didTapSaveButton(_ sender: UITapGestureRecognizer) {
        profileViewModel?.updateUserProfile()
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [self] in
                    navigationController?.popToRootViewController(animated: true)
                }, onError: { [self] err in
                    toast(message: "프로필 저장 중 에러가 발생 하였습니다.")
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func subscribeViewModel() {
        profileViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [self] userDTO in
                    setValue(userDTO: userDTO)
                    clearFragments()
                }, onError: { err in
                    log.error(err)
                }).disposed(by: disposeBag)
    }

    private func clearFragments() {
        if children.count > 0 {
            let viewControllers: [UIViewController] = children
            for viewController in viewControllers {
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
        }
        transparentView.visible(false)
    }

    private func showFragment(subView: UIView?) {
        guard subView != nil else {
            return
        }
        transparentView.visible(true)
        view?.addSubview(subView!)
    }

    private func setValue(userDTO: UserDTO) {
        nicknameValueLabel.text = userDTO.nickName ?? "닉네임을 입력 하세요."

        if (userDTO.sex == Sex.MALE) {
            sexValueLabel.text = "남자"
        } else if (userDTO.sex == Sex.FEMALE) {
            sexValueLabel.text = "여자"
        } else {
            sexValueLabel.text = "성별을 입력 하세요."
        }

        if (userDTO.birthedAt != nil) {
            let age = userDTO.birthedAt!.asAge()
            birthdayValueLabel.text = String(age) + " 세"
        } else {
            birthdayValueLabel.text = "생일을 입력 하세요."
        }

        if (userDTO.height != nil) {
            heightValueLabel.text = "\(userDTO.height ?? 0) cm"
        } else {
            heightValueLabel.text = "키를 입력 하세요."
        }

        if (userDTO.bodyId != nil) {
            bodyTypeValueLabel.text = userDTO.bodyType
        } else {
            bodyTypeValueLabel.text = "체형을 입력 하세요."
        }

        if (userDTO.introduction != nil) {
            introductionValueLabel.text = userDTO.introduction
        } else {
            introductionValueLabel.text = "자기소개를 입력 하세요."
        }

        if (userDTO.occupation != nil) {
            occupationValueLabel.text = userDTO.occupation
        } else {
            occupationValueLabel.text = "직업을 입력 하세요."
        }

        if (userDTO.education != nil) {
            educationValueLabel.text = userDTO.education
        } else {
            educationValueLabel.text = "교육을 입력 하세요."
        }

        if (userDTO.religionId != nil) {
            religionValueLabel.text = userDTO.religion
        } else {
            religionValueLabel.text = "종교를 입력 하세요."
        }

        if (userDTO.drinkId != nil) {
            drinkValueLabel.text = userDTO.drink
        } else {
            drinkValueLabel.text = "주량을 입력 하세요."
        }

        if (userDTO.smokingId != nil) {
            smokingValueLabel.text = userDTO.smoking
        } else {
            smokingValueLabel.text = "흡연을 입력 하세요."
        }

        if (userDTO.bloodId != nil) {
            bloodTypeValueLabel.text = userDTO.blood
        } else {
            bloodTypeValueLabel.text = "혈액형을 입력 하세요."
        }

        charmCollectionView.removeAllTags()
        if (userDTO.charmIds != nil && (userDTO.charmIds?.count ?? 0) > 0) {
            charmCollectionView.addTags(userDTO.charmIds?.map({ (index: Int) -> String in
                UserGlobal.charms[index]
            }), with: config)
        } else {
            charmCollectionView.addTags(["매력 어필을 입력 하세요."], with: config)
        }

        idealTypeCollectionView.removeAllTags()
        if (userDTO.idealTypeIds != nil && (userDTO.idealTypeIds?.count ?? 0) > 0) {
            idealTypeCollectionView.addTags(userDTO.idealTypeIds?.map({ (index: Int) -> String in
                UserGlobal.idealTypes[index]
            }), with: config)
        } else {
            idealTypeCollectionView.addTags(["이상형을 입력 하세요."], with: config)
        }

        interestsCollectionView.removeAllTags()
        if (userDTO.interestIds != nil && (userDTO.interestIds?.count ?? 0) > 0) {
            interestsCollectionView.addTags(userDTO.interestIds?.map({ (index: Int) -> String in
                UserGlobal.interests[index]
            }), with: config)
        } else {
            interestsCollectionView.addTags(["관심사를 입력 하세요."], with: config)
        }
    }

    private func configLineConstraints(line: UIView,
                                       titleLabel: UILabel,
                                       valueLabel: UILabel,
                                       top: ConstraintItem) {

        line.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(top)
            make.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(120)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    private func configLineConstraints(line: UIView,
                                       titleLabel: UILabel,
                                       collectionView: TTGTextTagCollectionView,
                                       top: ConstraintItem) {
        line.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(top)
            make.bottom.equalTo(collectionView.snp.bottom).inset(-8)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(120)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(8)
        }
    }
}

class CharmDelegate: NSObject, TTGTextTagCollectionViewDelegate {
    let parent: ProfileViewController

    init(parent: ProfileViewController) {
        self.parent = parent
    }

    public func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!,
                                      didTapTag tagText: String!,
                                      at index: UInt,
                                      selected: Bool,
                                      tagConfig config: TTGTextTagConfig!) {
        parent.popCharm()
    }
}

class IdealTypeDelegate: NSObject, TTGTextTagCollectionViewDelegate {
    let parent: ProfileViewController

    init(parent: ProfileViewController) {
        self.parent = parent
    }

    public func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!,
                                      didTapTag tagText: String!,
                                      at index: UInt,
                                      selected: Bool,
                                      tagConfig config: TTGTextTagConfig!) {
        parent.popIdealType()
    }
}

class InterestsDelegate: NSObject, TTGTextTagCollectionViewDelegate {
    let parent: ProfileViewController

    init(parent: ProfileViewController) {
        self.parent = parent
    }

    public func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!,
                                      didTapTag tagText: String!,
                                      at index: UInt,
                                      selected: Bool,
                                      tagConfig config: TTGTextTagConfig!) {
        parent.popInterests()
    }
}