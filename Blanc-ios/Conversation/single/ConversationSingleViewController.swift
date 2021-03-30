import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard

private class Content: UIView {
    override var intrinsicContentSize: CGSize {
        UIView.layoutFittingExpandedSize
    }
}

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

    private var dataSource: UITableViewDiffableDataSource<Section, MessageDTO>?

    internal weak var conversationSingleViewModel: ConversationSingleViewModel!

    private weak var conversation: ConversationDTO?

    lazy private var navigationBarContent: Content = {
        let content = Content()
        let view = UIView()

        view.addSubview(navigationUserImageView)
        view.addSubview(navigationUserLabel)

        navigationUserImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(Const.navigationUserImageSize)
            make.height.equalTo(Const.navigationUserImageSize)
        }

        navigationUserLabel.snp.makeConstraints { make in
            make.leading.equalTo(navigationUserImageView.snp.trailing).inset(-10)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        content.addSubview(view)
        content.addSubview(optionImageView)
        view.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }

        optionImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(Const.navigationUserImageSize)
            make.height.equalTo(Const.navigationUserImageSize)
        }

        return content
    }()

    lazy private var navigationUserImageView: UIImageView = {
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

    lazy private var optionImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_more_vert")
        imageView.image = image
        imageView.layer.cornerRadius = CGFloat(Const.navigationUserImageSize / 2)
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapOptionImageView))
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SystemMessageTableViewCell.self, forCellReuseIdentifier: SystemMessageTableViewCell.identifier)
        tableView.register(RightMessageTableViewCell.self, forCellReuseIdentifier: RightMessageTableViewCell.identifier)
        tableView.register(LeftMessageTableViewCell.self, forCellReuseIdentifier: LeftMessageTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.delegate = self
        tableView.backgroundColor = .clear
        return tableView
    }()

    lazy private var bottomTextView: BottomTextView = {
        let view = BottomTextView()
        view.placeHolder = "대화를 입력 하세요."
        view.configure(avatar: conversationSingleViewModel.avatar)
        view.configure(delegate: self)
        return view
    }()

    lazy private var closeTapBackground: UIView = {
        let view = UIView()
        view.visible(false)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(dismissTextField))
        return view
    }()

    lazy private var inactiveConversationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.visible(false)

        view.addSubview(inactiveStarFallView)
        view.addSubview(inactiveUserImage)
        view.addSubview(inactiveLabel1)
        view.addSubview(inactiveLabel2)
        view.addSubview(activeButton)

        inactiveStarFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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

    lazy private var activeStarFallView: StarFallView = {
        let view = StarFallView(layerTransparency: 0.9)
        return view
    }()

    lazy private var inactiveStarFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var inactiveUserImage: GradientCircleImageView = {
        let width = UIScreen.main.bounds.width
        let imageView = GradientCircleImageView(diameter: width / 3.5)
        return imageView
    }()

    lazy private var inactiveLabel1: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .black4
        return label
    }()

    lazy private var inactiveLabel2: UILabel = {
        let label = UILabel()
        label.text = "지금 대화를 나누어 보세요."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .darkGray
        return label
    }()

    lazy private var activeButton: UIButton = {
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
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.titleView = navigationBarContent
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
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
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        conversationSingleViewModel?.sync()
        SwinjectStoryboard.defaultContainer.resetObjectScope(.conversationSingleScope)
        log.info("deinit ConversationSingleViewController..")
    }

    private func configureSubviews() {
        view.addSubview(activeStarFallView)
        view.addSubview(tableView)
        view.addSubview(closeTapBackground)
        view.addSubview(bottomTextView)
        view.addSubview(inactiveConversationView)
    }

    private func configureConstraints() {
        activeStarFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomTextView.snp.top)
        }
        bottomTextView.snp.makeConstraints { make in
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

        conversationSingleViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] conversation in
                self.conversation = conversation
                update()
            })
            .disposed(by: disposeBag)

        conversationSingleViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] conversation in
                navigation()
            })
            .disposed(by: disposeBag)

        conversationSingleViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] conversation in
                activate()
            })
            .disposed(by: disposeBag)

        conversationSingleViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        conversationSingleViewModel?
            .back
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func navigation() {
        let nickname = conversation?.partner?.nickname ?? "알 수 없음"
        let age = conversation?.partner?.age ?? 0
        let avatar = conversation?.partner?.avatar
        navigationUserImageView.url(avatar)
        navigationUserLabel.text = "\(nickname), \(age)"
    }

    private func activate() {
        let hasPartner = conversation?.participants?.count ?? 0 > 1
        let positive = "\(conversation?.partner?.nickname ?? "알 수 없음") 님과 연결 되었습니다."
        let negative = "해당 사용자가 대화방을 나갔습니다."
        inactiveLabel1.text = hasPartner ? positive : negative
        inactiveUserImage.url(conversation?.partner?.avatar)
        inactiveConversationView.visible(conversation?.available != true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           closeTapBackground.isHidden == true {
            let window = UIApplication.shared.keyWindow
            bottomTextView.frame.origin.y -= (keyboardSize.height - (window?.safeAreaInsets.bottom ?? 0))
            closeTapBackground.visible(true)
        }
    }

    @objc private func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomTextView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(keyboardSize.height)
            }
            bottomTextView.layoutIfNeeded()
            tableView.snp.remakeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalTo(bottomTextView.snp.top)
            }
            tableView.layoutIfNeeded()
            if let conversation = conversation,
               let messages = conversation.messages {
                let row = messages.count - 1
                let indexPath = IndexPath(row: row, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide() {
        tableView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomTextView.snp.top)
        }
        bottomTextView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func dismissTextField() {
        closeTapBackground.visible(false)
        bottomTextView.dismiss()
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
                }
                if (result == .purchase) {
                    navigationController?.pushViewController(.inAppPurchase, current: self)
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
        conversationSingleViewModel?.updateConversationAvailable(conversation: conversation)
    }

    @objc func didTapOptionImageView() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "신고", style: .default) { [unowned self] (action) in
            guard let user = conversation?.partner else {
                return
            }
            Channel.next(report: user)
            navigationController?.pushViewController(
                .reportUser,
                current: self,
                hideBottomWhenStart: true,
                hideBottomWhenEnd: true
            )
        }
        let leaveAction = UIAlertAction(title: "나가기", style: .default) { [unowned self] (action) in
            let alertController = UIAlertController(
                title: "삭제 된 대화방 데이터는 절대로 되돌릴 수 없습니다.",
                message: "정말로 나가시겠습니까?",
                preferredStyle: .actionSheet
            )
            let confirmAction = UIAlertAction(title: "네, 확실합니다.", style: .default) { [unowned self] (action) in
                conversationSingleViewModel.leaveConversation()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
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

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(leaveAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
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
                let indexPath = IndexPath(row: ((conversation?.messages?.count ?? 1) - 1), section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
    }
}

extension ConversationSingleViewController: BottomTextFieldDelegate {
    func trigger(message: String) {
        conversationSingleViewModel?.sendMessage(message: message)
        dismissTextField()
    }

    func dismiss() {
        fatalError("Not required here.")
    }
}