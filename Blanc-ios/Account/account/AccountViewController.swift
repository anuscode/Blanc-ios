import UIKit
import FirebaseAuth
import SwinjectStoryboard
import RxSwift

class AccountData {
    var icon: String
    var title: String

    init(icon: String, title: String) {
        self.icon = icon
        self.title = title
    }
}

class AccountViewController: UIViewController {

    private let auth: Auth = Auth.auth()

    private let disposeBag: DisposeBag = DisposeBag()

    var accountViewModel: AccountViewModel?

    private let fireworkController = ClassicFireworkController()

    private var sections = ["결제", "설정", "고객센터"]

    private var dataSource = [
        [
            AccountData(icon: "dollarsign.circle", title: "결제 하기")
        ],
        [
            AccountData(icon: "bell", title: "푸시 설정"),
            AccountData(icon: "power", title: "로그 아웃")
        ],
        [
            AccountData(icon: "atom", title: "고객 센터"),
            AccountData(icon: "lightbulb", title: "블랑를 개선 시킬 의견을 주세요!")
        ]
    ]

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "계정"))
    }()

    lazy var semiProfileView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white

        view.addSubview(currentUserImage)
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(line3)
        view.addSubview(tap1)
        view.addSubview(tap2)
        view.addSubview(tap3)
        view.addSubview(tap4)

        currentUserImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
        }

        line1.snp.makeConstraints { make in
            make.leading.equalTo(currentUserImage.snp.trailing).inset(-15)
            make.bottom.equalTo(line2.snp.top).inset(-1)
        }

        line2.snp.makeConstraints { make in
            make.leading.equalTo(currentUserImage.snp.trailing).inset(-15)
            make.centerY.equalTo(currentUserImage.snp.centerY).multipliedBy(1.05)
        }

        line3.snp.makeConstraints { make in
            make.leading.equalTo(currentUserImage.snp.trailing).inset(-15)
            make.top.equalTo(line2.snp.bottom).inset(-1)
        }

        let viewWidth = UIScreen.main.bounds.width - 20
        let cellWidth = viewWidth / 4

        tap1.snp.makeConstraints { make in
            make.top.equalTo(currentUserImage.snp.bottom).offset(5)
            make.centerX.equalTo(cellWidth / 2)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }

        tap2.snp.makeConstraints { make in
            make.top.equalTo(currentUserImage.snp.bottom).offset(5)
            make.centerX.equalTo((3 * cellWidth) / 2)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }

        tap3.snp.makeConstraints { make in
            make.top.equalTo(currentUserImage.snp.bottom).offset(5)
            make.centerX.equalTo((5 * cellWidth) / 2)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }

        tap4.snp.makeConstraints { make in
            make.top.equalTo(currentUserImage.snp.bottom).offset(5)
            make.centerX.equalTo((7 * cellWidth) / 2)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(60)
            make.height.equalTo(60)
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
        return imageView
    }()

    lazy var line1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    lazy var line2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    lazy var line3: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemBlue
        return label
    }()

    lazy var tap1: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_wallpaper_black")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "이미지 변경"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .lightBlack
        view.addSubview(label)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapImageButton))
        return view
    }()

    lazy var tap2: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_feed_black")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "프로필 변경"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .lightBlack
        view.addSubview(label)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapProfileButton))
        return view
    }()

    lazy var tap3: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_star")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "내 별점"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .lightBlack
        view.addSubview(label)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapStarRatingButton))
        return view
    }()

    lazy var tap4: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_guard")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "지인 차단"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .lightBlack
        view.addSubview(label)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapAvoidButton))
        return view
    }()

    lazy var tableViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        return view
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: AccountTableViewCell.identifier)
        tableView.isScrollEnabled = false
        return tableView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .secondarySystemBackground
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeAccountViewModel()
    }

    private func configureSubviews() {
        view.addSubview(semiProfileView)
        view.addSubview(tableViewContainer)
    }

    private func configureConstraints() {
        semiProfileView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        tableViewContainer.snp.makeConstraints { make in
            make.top.equalTo(semiProfileView.snp.bottom).inset(-10)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }

    private func subscribeAccountViewModel() {
        accountViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { user in
                    self.update(user)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func update(_ user: UserDTO) {
        let nickname = user.nickname ?? "알 수 없음"
        let area = user.area ?? "알 수 없음"
        let age = user.age ?? 0
        let point = user.point ?? 0
        currentUserImage.url(user.avatar)
        line1.text = nickname
        line2.text = "\(area) · \(age)세"
        line3.text = "내 잔여 포인트: \(point)"
    }
}

extension AccountViewController {

    @objc private func didTapImageButton() {
        fireworkController.addFireworks(count: 1, around: tap1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pushViewController(identifier: "ImageViewController")
        }
    }

    @objc private func didTapProfileButton() {
        fireworkController.addFireworks(count: 1, around: tap2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pushViewController(identifier: "ProfileViewController")
        }
    }

    @objc private func didTapStarRatingButton() {
        fireworkController.addFireworks(count: 1, around: tap3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pushViewController(identifier: "MyRatedScoreViewController")
        }
    }

    @objc private func didTapAvoidButton() {
        fireworkController.addFireworks(count: 1, around: tap4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pushViewController(identifier: "AvoidViewController")
        }
    }

    private func logout() {
        do {
            try auth.signOut()
            let navigation = parent
            let tapBar = navigation?.parent
            tapBar?.replace(withIdentifier: "InitPagerViewController") {
                SwinjectStoryboard.defaultContainer.resetObjectScope(.mainScope)
            }
        } catch {
            toast(message: "로그아웃에 실패 하였습니다. 다시 시도해 주세요.")
        }
    }

    private func pushViewController(storyboard: String = "Main", identifier: String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = sections[section]
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12, weight: .light)

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }

        if (section != 0) {
            let border = UIView()
            border.backgroundColor = .systemGray4
            view.addSubview(border)
            border.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(20)
                make.trailing.equalToSuperview().inset(5)
                make.top.equalToSuperview()
                make.height.equalTo(0.25)
            }
        }

        return view
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: AccountTableViewCell.identifier, for: indexPath) as! AccountTableViewCell
        let data = dataSource[indexPath.section][indexPath.row]
        cell.bind(data)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath.section == 0) {
            pushViewController(identifier: "InAppPurchaseViewController")
        }

        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                pushViewController(identifier: "PushSettingViewController")
            } else {
                logout()
            }
        }

        if (indexPath.section == 2) {

        }
    }
}