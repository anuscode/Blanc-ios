import UIKit
import FirebaseAuth
import SwinjectStoryboard
import RxSwift
import RxDataSources


class AccountData {
    var icon: String
    var title: String

    init(icon: String, title: String) {
        self.icon = icon
        self.title = title
    }
}

typealias SectionedDataSource = TableViewSectionedDataSource
typealias ReloadDataSource = RxTableViewSectionedReloadDataSource

class AccountViewController: UIViewController {

    private let auth: Auth = Auth.auth()

    private var disposeBag: DisposeBag = DisposeBag()

    private let fireworkController = ClassicFireworkController()

    private let sections = [
        SectionModel<String, AccountData>(model: "결제", items: [
            AccountData(icon: "dollarsign.circle", title: "결제 하기")
        ]),
        SectionModel<String, AccountData>(model: "설정", items: [
            AccountData(icon: "bell", title: "푸시 설정"),
            AccountData(icon: "power", title: "로그 아웃")
        ]),
        SectionModel<String, AccountData>(model: "히스토리", items: [
            AccountData(icon: "clock.arrow.circlepath", title: "내 게시물 관리"),
        ]),
        SectionModel<String, AccountData>(model: "고객 센터", items: [
            AccountData(icon: "atom", title: "고객 센터"),
            AccountData(icon: "lightbulb", title: "블랑를 개선 시킬 의견을 주세요!")
        ])
    ]

    internal weak var accountViewModel: AccountViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "계정"))
    }()

    lazy private var semiProfileView: UIView = {
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

    lazy private var currentUserImage: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let imageView = UIImageView()
        imageView.layer.cornerRadius = screenWidth / 10
        imageView.layer.masksToBounds = true
        imageView.width(screenWidth / 5)
        imageView.height(screenWidth / 5)
        return imageView
    }()

    lazy private var line1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    lazy private var line2: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    lazy private var line3: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemBlue
        return label
    }()

    lazy private var tap1: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_wallpaper_black")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "이미지 변경"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black3
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

    lazy private var tap2: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_feed_black")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "프로필 변경"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black3
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

    lazy private var tap3: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_star")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "내 별점"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black3
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

    lazy private var tap4: UIView = {
        let view = UIView()

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_guard")
        view.addSubview(imageView)

        let label = UILabel()
        label.text = "지인 차단"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black3
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

    lazy private var tableViewContainer: UIView = {
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

    private let configureCell: (SectionedDataSource<SectionModel<String, AccountData>>, UITableView, IndexPath, AccountData) ->
    UITableViewCell = { (datasource, tableView, indexPath, element) in
        let identifier = AccountTableViewCell.identifier
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier, for: indexPath) as? AccountTableViewCell else {
            return UITableViewCell()
        }
        cell.bind(element)
        return cell
    }

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
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
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeAccountViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
        log.info("deinit account view controller..")
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

        let datasource = ReloadDataSource<SectionModel<String, AccountData>>.init(configureCell: configureCell)
        accountViewModel?
            .sections
            .bind(to: tableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)

        accountViewModel?
            .currentUser
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] user in
                let url = user.avatar ?? ""
                currentUserImage.url(url)
            })
            .disposed(by: disposeBag)

        accountViewModel?
            .currentUser
            .map({ user in user.nickname ?? "알 수 없음" })
            .bind(to: line1.rx.text)
            .disposed(by: disposeBag)

        accountViewModel?
            .currentUser
            .map({ user in
                let area = user.area ?? "알 수 없음"
                let age = user.age ?? 0
                return "\(area) · \(age)세"
            })
            .bind(to: line2.rx.text)
            .disposed(by: disposeBag)

        accountViewModel?
            .currentUser
            .map({ user in "내 잔여 포인트: \(user.point ?? 0)" })
            .bind(to: line3.rx.text)
            .disposed(by: disposeBag)
    }
}

extension AccountViewController {

    @objc private func didTapImageButton() {
        fireworkController.addFireworks(count: 1, around: tap1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            navigationController?.pushViewController(.imageView, current: self)
        }
    }

    @objc private func didTapProfileButton() {
        fireworkController.addFireworks(count: 1, around: tap2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            navigationController?.pushViewController(.profileView, current: self)
        }
    }

    @objc private func didTapStarRatingButton() {
        fireworkController.addFireworks(count: 1, around: tap3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            navigationController?.pushViewController(.myRatedScore, current: self)
        }
    }

    @objc private func didTapAvoidButton() {
        fireworkController.addFireworks(count: 1, around: tap4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AvoidViewController")
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}

extension AccountViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = sections[section].model
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

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0:
            navigationController?.pushViewController(.inAppPurchase, current: self)
        case 1:
            if (indexPath.row == 0) {
                navigationController?.pushViewController(.pushSetting, current: self)
            } else {
                navigationController?.pushViewController(.accountManagement, current: self)
            }
        case 2:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let identifier = "PostManagementViewController"
            let vc = storyboard.instantiateViewController(
                withIdentifier: identifier) as! PostManagementViewController
            vc.prepare()
            navigationController?.pushViewController(vc, current: self)
        case 3:
            if (indexPath.row == 0) {
                toast(message: "곧 구현 하겠습니다.")
            } else {
                toast(message: "곧 구현 하겠습니다.")
            }
        default:
            fatalError("Something wrong with menu clicks..")
        }
    }
}