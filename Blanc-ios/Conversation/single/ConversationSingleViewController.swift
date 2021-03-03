import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard

class ConversationSingleViewController: UIViewController {

    private class Const {
        static let navigationUserImageSize: Int = 28
        static let navigationUserLabelFont: UIFont = .systemFont(ofSize: 15)
        static let bottomViewHeight: Int = 55
        static let navigationUserImageCornerRadius: Int = {
            Const.navigationUserImageSize / 2
        }()
    }

    private let ripple: Ripple = Ripple()

    private let disposeBag: DisposeBag = DisposeBag()

    private weak var conversation: ConversationDTO?

    private var dataSource: UITableViewDiffableDataSource<Section, MessageDTO>?

    var conversationSingleViewModel: ConversationSingleViewModel?

    lazy private var navigationBarContent: UIView = {
        let view = UIView()
        view.addSubview(navigationUserImage)
        view.addSubview(navigationUserLabel)
        navigationUserImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(Const.navigationUserImageSize)
            make.height.equalTo(Const.navigationUserImageSize)
        }
        navigationUserLabel.snp.makeConstraints { make in
            make.leading.equalTo(navigationUserImage.snp.trailing).inset(-10)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        return view
    }()

    lazy private var navigationUserImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy private var navigationUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.font = Const.navigationUserLabelFont
        return label
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SystemMessageTableViewCell.self, forCellReuseIdentifier: SystemMessageTableViewCell.identifier)
        tableView.register(RightMessageTableViewCell.self, forCellReuseIdentifier: RightMessageTableViewCell.identifier)
        tableView.register(LeftMessageTableViewCell.self, forCellReuseIdentifier: LeftMessageTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.backgroundColor = .white
        return tableView
    }()

    lazy var bottomTextField: BottomTextField = {
        let view = BottomTextField()
        view.placeHolder = "대화를 입력 하세요."
        view.configure(avatarUrl: conversationSingleViewModel?.getSession().user?.avatar)
        view.configure(delegate: self)
        return view
    }()

    lazy var closeTapBackground: UIView = {
        let view = UIView()
        view.visible(false)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(dismissTextField))
        return view
    }()

    lazy var inactiveConversationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.visible(false)

        view.addSubview(inactiveUserImage)
        view.addSubview(inactiveLabel1)
        view.addSubview(inactiveLabel2)
        view.addSubview(activeButton)

        inactiveUserImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.9)
        }

        inactiveLabel1.snp.makeConstraints { make in
            make.top.equalTo(inactiveUserImage.snp.bottom).inset(-50)
            make.centerX.equalToSuperview()
        }

        inactiveLabel2.snp.makeConstraints { make in
            make.top.equalTo(inactiveLabel1.snp.bottom).inset(-10)
            make.centerX.equalToSuperview()
        }

        activeButton.snp.makeConstraints { make in
            make.top.equalTo(inactiveLabel2.snp.bottom).inset(-50)
            make.centerX.equalToSuperview()
        }

        return view
    }()

    lazy var inactiveUserImage: UIImageView = {
        let screenWidth = UIScreen.main.bounds.width
        let imageView = UIImageView()
        imageView.layer.cornerRadius = screenWidth / 8
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ic_google")
        imageView.width(screenWidth / 4)
        imageView.height(screenWidth / 4)
        return imageView
    }()

    lazy var inactiveLabel1: UILabel = {
        let label = UILabel()
        label.text = "소소한 님과 연결 되었습니다."
        label.font = .systemFont(ofSize: 22)
        return label
    }()

    lazy var inactiveLabel2: UILabel = {
        let label = UILabel()
        label.text = "지금 대화를 나누어 보세요."
        label.textColor = .lightBlack
        return label
    }()

    lazy var activeButton: UIButton = {
        let button = UIButton()
        button.setTitle("대화방 오픈", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.backgroundColor = .bumble3
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.width(250)
        button.height(45)
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapActivateButton))
        ripple.activate(to: button)
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        navigationItem.titleView = navigationBarContent
        navigationController?.navigationBar.barTintColor = .secondarySystemBackground
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification, object: nil)
        configureSubviews()
        configureConstraints()
        configureTableViewDataSource()
        subscribeConversationSingleViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        conversationSingleViewModel?.sync()
        SwinjectStoryboard.defaultContainer.resetObjectScope(.conversationSingleScope)
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        log.info("deinit ConversationSingleViewController..")
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(closeTapBackground)
        view.addSubview(bottomTextField)
        view.addSubview(inactiveConversationView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomTextField.snp.top)
        }

        bottomTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        closeTapBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        inactiveConversationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribeConversationSingleViewModel() {
        conversationSingleViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] conversation in
                    self.conversation = conversation
                    DispatchQueue.main.async { [unowned self] in
                        update()
                        updateNavigation()
                        showInactiveViewIfRequired()
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func updateNavigation() {
        navigationUserImage.url(conversation?.partner?.avatar)
        navigationUserLabel.text = "\(conversation?.partner?.nickname ?? "알 수 없음"), \(conversation?.partner?.age ?? -1)"
    }

    private func showInactiveViewIfRequired() {
        inactiveConversationView.visible(conversation?.available != true)
        inactiveUserImage.url(conversation?.partner?.avatar)
        if (conversation?.references?.count ?? 0 > 1) {
            inactiveLabel1.text = "\(conversation?.partner?.nickname ?? "알 수 없음") 님과 연결 되었습니다."
        } else {
            inactiveLabel1.text = "해당 사용자가 대화방을 나갔습니다."
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let window = UIApplication.shared.keyWindow
            bottomTextField.frame.origin.y -= (keyboardSize.height - (window?.safeAreaInsets.bottom ?? 0))
            closeTapBackground.visible(true)
        }
    }

    @objc private func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomTextField.snp.removeConstraints()
            bottomTextField.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(keyboardSize.height)
            }
            bottomTextField.layoutIfNeeded()

            tableView.snp.removeConstraints()
            tableView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalTo(bottomTextField.snp.top)
            }
            tableView.layoutIfNeeded()
            if (conversation?.messages?.count ?? 0 > 0) {
                print(conversation?.messages?.count ?? 0)
                tableView.scrollToRow(
                        at: IndexPath(row: conversation!.messages!.count - 1, section: 0),
                        at: .bottom,
                        animated: true)
            }
        }
    }

    @objc private func keyboardWillHide() {
        tableView.snp.removeConstraints()
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomTextField.snp.top)
        }

        bottomTextField.snp.removeConstraints()
        bottomTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func dismissTextField() {
        closeTapBackground.visible(false)
        bottomTextField.dismiss()
        view.endEditing(true)
    }

    @objc private func didTapActivateButton() {
        guard let partner = conversation?.partner else {
            toast(message: "해당 유저를 찾을 수 없습니다...")
            return
        }
        OpenConversationConfirmViewController
                .present(target: self, user: partner)
                .subscribe(onNext: { [unowned self] result in
                    if (result == .accept) {
                        updateConversationAvailable()
                        return
                    }

                    if (result == .purchase) {

                    }

                    if (result == .decline) {
                        log.info("declined open conversation confirm.")
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func updateConversationAvailable() {
        conversationSingleViewModel?.updateConversationAvailable(conversation: conversation, onCompleted: { [unowned self] in
            toast(message: "대화방이 정상적으로 열렸습니다.")
        }, onError: { [unowned self] in
            toast(message: "대화방을 여는 도중 에러가 발생 하였습니다.")
        })
    }
}

extension ConversationSingleViewController {

    fileprivate enum Section {
        case Main
    }

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, MessageDTO>(tableView: tableView) { [unowned self] (tableView, indexPath, message) -> UITableViewCell? in
            if (message.category == Category.system) {
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: SystemMessageTableViewCell.identifier,
                        for: indexPath) as? SystemMessageTableViewCell else {
                    return UITableViewCell()
                }
                cell.bind(message: message)
                return cell
            }
            if (message.isCurrentUserMessage == true) {
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: RightMessageTableViewCell.identifier,
                        for: indexPath) as? RightMessageTableViewCell else {
                    return UITableViewCell()
                }
                cell.bind(message: message)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: LeftMessageTableViewCell.identifier,
                        for: indexPath) as? LeftMessageTableViewCell else {
                    return UITableViewCell()
                }
                let partner = conversation?.partner
                cell.bind(user: partner, message: message)
                return cell
            }
        }
        tableView.dataSource = dataSource
    }

    private func update(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MessageDTO>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(conversation?.messages ?? [])
        dataSource?.apply(snapshot, animatingDifferences: animatingDifferences) { [unowned self] in
            if (conversation?.messages?.count ?? 0 > 0) {
                tableView.scrollToRow(at: IndexPath(row: ((conversation?.messages?.count ?? 1) - 1), section: 0),
                        at: .bottom, animated: true)
            }
        }
    }
}

extension ConversationSingleViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        75.3
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
    }
}

extension ConversationSingleViewController: BottomTextFieldDelegate {
    func trigger(message: String) {
        conversationSingleViewModel?.sendMessage(message: message) { [unowned self] in
            toast(message: "메시지 전송에 실패 하였습니다.")
        }
        dismissTextField()
    }

    func dismiss() {
        fatalError("Not required here.")
    }
}