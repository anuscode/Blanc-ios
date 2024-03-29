import UIKit
import RxSwift
import SwinjectStoryboard


private enum Section {
    case Main
}

private protocol ConversationDataSourceDelegate: class {
    func deleteAction(conversation: ConversationDTO)
}

private class ConversationDataSource: UITableViewDiffableDataSource<Section, ConversationDTO> {

    internal weak var conversationViewModel: ConversationViewModel?

    internal weak var delegate: ConversationDataSourceDelegate?

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let conversation: ConversationDTO = itemIdentifier(for: indexPath) {
                delegate?.deleteAction(conversation: conversation)
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

    internal weak var conversationViewModel: ConversationViewModel?

    internal var rightSideBarView: RightSideBarView?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "채팅"))
    }()

    lazy private var rightBarButtonItem: UIBarButtonItem = {
        guard let rightSideBarView = rightSideBarView else {
            return UIBarButtonItem()
        }
        rightSideBarView.delegate {
            self.navigationController?.pushViewController(.alarms, current: self)
        }
        return UIBarButtonItem(customView: rightSideBarView)
    }()

    lazy private var starFallView: StarFallView = {
        let view = StarFallView(layerTransparency: 0.9)
        return view
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
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.delegate = self
        return tableView
    }()

    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView(animationName: "girl_with_phone", animationSpeed: 1)
        emptyView.primaryText = "생성 된 대화방이 없습니다."
        emptyView.secondaryText = "서로 요청을 수락하면\n이곳에 대화방이 생성 됩니다."
        emptyView.buttonText = "메인 화면으로"
        emptyView.didTapButtonDelegate = { [unowned self] in
            self.tabBarController?.selectedIndex = 0
        }
        emptyView.visible(false)
        return emptyView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = true
        !emptyView.isHidden ? emptyView.play() : ({ return })()
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

    deinit {
        log.info("deinit conversation view controller..")
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(titleLabel)
        view.addSubview(underLine)
        view.addSubview(tableView)
        view.addSubview(emptyView)
    }

    private func configureConstraints() {
        starFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        conversationViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] conversations in
                self.conversations = conversations
                update()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)

        conversationViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] conversations in
                emptyView.visible(conversations.isEmpty)
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
        // set view model to leave conversation
        dataSource.conversationViewModel = conversationViewModel
        dataSource.delegate = self
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
        guard let user = user else {
            return
        }
        Channel.next(user: user)
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
        guard let conversation = conversation else {
            return
        }
        Channel.next(conversation: conversation)
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

extension ConversationViewController: ConversationDataSourceDelegate {
    func deleteAction(conversation: ConversationDTO) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "나가기", style: .default) { [unowned self] (action) in
            conversationViewModel?.leaveConversation(conversationId: conversation.id)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.modalPresentationStyle = .popover

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                let sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.sourceView = view
                popoverController.sourceRect = sourceRect
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
}