import UIKit
import RxSwift
import SwinjectStoryboard


fileprivate enum Section {
    case Main
}

fileprivate class ConversationDataSource: UITableViewDiffableDataSource<Section, ConversationDTO> {

    var conversationViewModel: ConversationViewModel?

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item: ConversationDTO = itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                snapshot.deleteItems([item])
                apply(snapshot)
                conversationViewModel?.leaveConversation(conversationId: item.id)
            }
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}


class ConversationViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var dataSource: ConversationDataSource!

    private var conversations: [ConversationDTO] = []

    var conversationViewModel: ConversationViewModel?

    var rightSideBarView: RightSideBarView?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "채팅"))
    }()

    lazy private var rightBarButtonItem: UIBarButtonItem = {
        guard (rightSideBarView != nil) else {
            return UIBarButtonItem()
        }
        rightSideBarView!.delegate {
            self.navigationController?.pushAlarmViewController(current: self)
        }
        return UIBarButtonItem(customView: rightSideBarView!)
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "연결"
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()

    lazy private var underLine: UIView = {
        let view = UIView()
        view.backgroundColor = .bumble1
        return view
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ConversationTableViewCell.self,
                forCellReuseIdentifier: ConversationTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.delegate = self
        return tableView
    }()

    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView(animationName: "girl_with_phone", animationSpeed: 1)
        emptyView.primaryText = "생성 된 대화방이 없습니다.."
        emptyView.secondaryText = "서로 요청을 수락하면\n이곳에 대화방이 생성 됩니다."
        emptyView.buttonText = "메인 화면으로.."
        emptyView.didTapButtonDelegate = { [self] in
            self.tabBarController?.selectedIndex = 0
        }
        emptyView.visible(false)
        return emptyView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
        if (!emptyView.isHidden) {
            emptyView.play()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewDataSource()
        configureSubviews()
        configureConstraints()
        subscribeConversationViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(underLine)
        view.addSubview(tableView)
        view.addSubview(emptyView)
    }

    private func configureConstraints() {

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalToSuperview().inset(15)
        }

        underLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.height.equalTo(3)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(tableView.snp.edges)
        }
    }

    private func subscribeConversationViewModel() {
        conversationViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { conversations in
                    self.conversations = conversations
                    DispatchQueue.main.async {
                        self.update()
                        self.emptyView.visible(conversations.count == 0)
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}

extension ConversationViewController {

    private func configureTableViewDataSource() {
        dataSource = ConversationDataSource(tableView: tableView) { (tableView, indexPath, conversation) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as? ConversationTableViewCell else {
                return UITableViewCell()
            }
            cell.bind(conversation: conversation, delegate: self)
            return cell
        }
        // set viewmodel to leave conversation
        dataSource.conversationViewModel = conversationViewModel
        tableView.dataSource = dataSource
    }

    private func update(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ConversationDTO>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(conversations)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
    }
}


extension ConversationViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
    }
}

extension ConversationViewController: ConversationTableViewCellDelegate {

    func presentUserSingleView(user: UserDTO?) {
        conversationViewModel?.channel(user: user)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
                withIdentifier: "UserSingleViewController") as! UserSingleViewController
        vc.modalPresentationStyle = .fullScreen
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }

    func presentConversationSingleView(conversation: ConversationDTO?) {
        conversationViewModel?.channel(conversation: conversation)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ConversationSingleViewController")
        vc.modalPresentationStyle = .fullScreen
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = false
    }
}
