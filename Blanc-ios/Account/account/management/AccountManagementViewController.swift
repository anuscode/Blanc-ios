import Foundation
import UIKit
import RxSwift
import RxDataSources
import FirebaseAuth
import SwinjectStoryboard

class AccountManagementViewController: UIViewController {

    private let auth: Auth = Auth.auth()

    private var disposeBag: DisposeBag = DisposeBag()

    internal var accountManagementViewModel: AccountManagementViewModel?

    private let ripple: Ripple = Ripple()

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "계정 관리"))
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.isScrollEnabled = false
        tableView.delegate = self
        return tableView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeAccountManagementViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func configureSubviews() {
        view.addSubview(tableView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func subscribeAccountManagementViewModel() {
        let configureCell: (SectionedDataSource<SectionModel<String, String>>, UITableView, IndexPath, String) -> UITableViewCell = { [unowned self] (datasource, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.text = element
            cell.selectionStyle = .none
            ripple.activate(to: cell.contentView)
            return cell
        }

        let dataSource = ReloadDataSource<SectionModel<String, String>>.init(configureCell: configureCell)
        dataSource.titleForHeaderInSection = { ds, index in
            return " "
        }
        accountManagementViewModel?
            .sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        accountManagementViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        accountManagementViewModel?
            .replaceViewController
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] in
                replaceViewController()
            })
            .disposed(by: disposeBag)
    }

    deinit {
        log.info("deinit account management view controller..")
    }

    private func replaceViewController() {
        replace(withIdentifier: "InitPagerViewController") {
            SwinjectStoryboard.defaultContainer.resetObjectScope(.accountManagement)
            SwinjectStoryboard.defaultContainer.resetObjectScope(.mainScope)
        }
    }
}

extension AccountManagementViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0:
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let logoutAction = UIAlertAction(title: "로그 아웃", style: .default) { [unowned self] (action) in
                accountManagementViewModel?.logout()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            alertController.addAction(cancelAction)
            alertController.addAction(logoutAction)
            alertController.modalPresentationStyle = .popover

            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = view
                    popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    present(alertController, animated: true, completion: nil)
                }
            } else {
                present(alertController, animated: true, completion: nil)
            }
        case 1:
            let alertController = UIAlertController(
                title: "주의 바랍니다.",
                message: "회원 탈퇴 직후 모든 데이터는 삭제 되며\n절대로 되돌릴 수 없습니다.",
                preferredStyle: .actionSheet
            )
            let unregisterAction = UIAlertAction(title: "회원 탈퇴", style: .default) { [unowned self] (action) in
                accountManagementViewModel?.withdraw()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            alertController.addAction(cancelAction)
            alertController.addAction(unregisterAction)
            alertController.modalPresentationStyle = .popover

            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = view
                    popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                    present(alertController, animated: true, completion: nil)
                }
            } else {
                present(alertController, animated: true, completion: nil)
            }
        default:
            fatalError("Something wrong with menu clicks..")
        }
    }
}
