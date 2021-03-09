import UIKit
import Moya
import RxSwift
import Foundation
import SwinjectStoryboard
import Lottie

private typealias UserProfileCellDelegate = SmallUserProfileWithButtonTableViewCellDelegate

class ReceivedViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var dataSource: UITableViewDiffableDataSource<Section, AnyHashable>!

    private var data: ReceivedViewData = ReceivedViewData()

    private var animations: [AnimationView] = []

    internal weak var receivedViewModel: ReceivedViewModel?

    var pushUserSingleViewController: (() -> Void)?

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SmallUserProfileWithButtonTableViewCell.self,
            forCellReuseIdentifier: "SmallUserProfileWithButtonTableViewCell")
        tableView.register(SmallUserProfileTableViewCell.self,
            forCellReuseIdentifier: "SmallUserProfileTableViewCell")
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.delegate = self
        return tableView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animations.forEach({ view in view.play() })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewDataSource()
        configureSubviews()
        configureConstraints()
        subscribeRequestsViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func configureSubviews() {
        view.addSubview(tableView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func subscribeRequestsViewModel() {
        receivedViewModel?
            .observe()
            .skip(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ data in
                // no initial animation but yes afterward.
                let isRequestsEmpty = self.data.requests.isEmpty
                let isUsersEmpty = self.data.users.isEmpty
                let animatingDifferences: Bool = !(isRequestsEmpty && isUsersEmpty)
                self.data.requests = data.requests
                self.data.users = data.users
                return animatingDifferences
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: update(animatingDifferences:))
            .disposed(by: disposeBag)
    }
}

extension ReceivedViewController {

    fileprivate enum Section {
        case Request, HighRating
    }

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { (tableView, indexPath, data) -> UITableViewCell? in
            if let request = data as? RequestDTO {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "SmallUserProfileWithButtonTableViewCell",
                    for: indexPath) as? SmallUserProfileWithButtonTableViewCell else {
                    return UITableViewCell()
                }
                cell.bind(request: request, delegate: self)
                return cell
            }
            if let user = data as? UserDTO {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "SmallUserProfileTableViewCell",
                    for: indexPath) as? SmallUserProfileTableViewCell else {
                    return UITableViewCell()
                }
                cell.bind(user: user, delegate: self)
                return cell
            }
            return nil
        }
        tableView.dataSource = dataSource
    }

    private func update(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.Request, .HighRating])
        snapshot.appendItems(data.requests, toSection: .Request)
        snapshot.appendItems(data.users, toSection: .HighRating)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) {
            self.reloadIfRequired()
        }
    }

    private func reloadIfRequired() {
        if data.requests.isEmpty {
            tableView.reloadData()
            return
        }
        if data.users.isEmpty {
            tableView.reloadData()
            return
        }
    }
}


extension ReceivedViewController: UITableViewDelegate {

    private func generateHeaderView(text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hexCode: "0C090A")

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        return view
    }

    private func generateFooterView(mainText: String, secondaryText: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white

        let animationView = AnimationView()
        animations.append(animationView)
        animationView.animation = Animation.named("bad_emoji")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(100).priority(800)
        }

        let mainLabel = UILabel()
        mainLabel.text = mainText
        mainLabel.textColor = .darkText
        mainLabel.textAlignment = .center
        mainLabel.font = .systemFont(ofSize: 20)

        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let secondaryLabel = UILabel()
        secondaryLabel.text = secondaryText
        secondaryLabel.textColor = .systemGray
        secondaryLabel.textAlignment = .center
        secondaryLabel.font = .systemFont(ofSize: 15)
        secondaryLabel.numberOfLines = 3

        view.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
        }

        return view
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = generateHeaderView(text: section == 0 ? "내게 친구 요청을 보냄" : "내게 관심을 보냄")
        return header
    }

    /** Footer is used for a empty message view. **/
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (section == 0) {
            return data.requests.count == 0 ? generateFooterView(
                mainText: "아직 받은 친구신청이 없습니다.",
                secondaryText: "먼저 친구신청을 걸어 보세요.") : UIView()
        }
        if (section == 1) {
            return data.users.count == 0 ? generateFooterView(
                mainText: "아직 관심을 받지 못했습니다.",
                secondaryText: "상대방이 내게 4점이상 평가를 하면\n이곳에 표시 됩니다..") : UIView()
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
    }
}

extension ReceivedViewController: UserProfileCellDelegate {
    func presentUserSingleView(user: UserDTO?) {
        receivedViewModel?.channel(user: user)
        pushUserSingleViewController?()
    }

    func accept(request: RequestDTO?) {
        guard let request = request else {
            toast(message: "요청 수락에 실패 하였습니다.")
            return
        }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([request])
        dataSource.apply(snapshot, animatingDifferences: true) {
            self.reloadIfRequired()
        }
        receivedViewModel?.accept(request: request, onError: { [unowned self] in
            toast(message: "요청 수락에 실패 하였습니다.")
        })
    }

    func decline(request: RequestDTO?) {
        receivedViewModel?.decline(request: request, onError: { [unowned self] in
            toast(message: "요청 거절에 실패 하였습니다.")
        })
    }
}
