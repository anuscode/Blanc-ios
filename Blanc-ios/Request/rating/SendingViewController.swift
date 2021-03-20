import UIKit
import Moya
import RxSwift
import Foundation
import SwinjectStoryboard

class SendingViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var dataSource: UITableViewDiffableDataSource<Section, UserDTO>!

    internal weak var sendingViewModel: SendingViewModel?

    var pushUserSingleViewController: (() -> Void)?

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SmallUserProfileTableViewCell.self,
            forCellReuseIdentifier: SmallUserProfileTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.delegate = self
        return tableView
    }()

    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView(animationName: "girl_with_phone", animationSpeed: 1)
        emptyView.primaryText = "아직 관심을 준 상대가 없습니다."
        emptyView.secondaryText = "내가 4점 이상 점수를 준 사람들이\n이곳에 표시 됩니다."
        emptyView.buttonText = "메인 화면으로.."
        emptyView.didTapButtonDelegate = { [unowned self] in
            self.tabBarController?.selectedIndex = 0
        }
        emptyView.visible(false)
        return emptyView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (!emptyView.isHidden) {
            emptyView.play()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewDataSource()
        configureSubviews()
        configureConstraints()
        subscribeRatingViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    private func subscribeRatingViewModel() {
        sendingViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] users in
                update(users)
            })
            .disposed(by: disposeBag)

        sendingViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ users in users.count == 0 })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] boolean in
                emptyView.visible(boolean)
            })
            .disposed(by: disposeBag)
    }
}

extension SendingViewController {

    fileprivate enum Section {
        case Main
    }

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, UserDTO>(tableView: tableView) { (tableView, indexPath, user) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SmallUserProfileTableViewCell.identifier, for: indexPath) as? SmallUserProfileTableViewCell else {
                return UITableViewCell()
            }
            cell.bind(user: user, delegate: self)
            return cell
        }
        tableView.dataSource = dataSource
    }

    private func update(_ users: [UserDTO], animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserDTO>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
    }
}


extension SendingViewController: UITableViewDelegate {

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

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = generateHeaderView(text: "내가 관심을 보냄")
        return header
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

extension SendingViewController: SmallUserProfileTableViewCellDelegate {
    func presentUserSingleView(user: UserDTO?) {
        guard let user = user else {
            return
        }
        Channel.next(user: user)
        pushUserSingleViewController?()
    }
}
