import Foundation
import UIKit
import StoreKit
import RxSwift
import RxDataSources

struct Product {
    let title: String
    let discount: String
    let price: String
    let tag: String?
    let productId: String

    init(productId: String, title: String, discount: String, price: String, tag: String? = nil) {
        self.productId = productId
        self.title = title
        self.discount = discount
        self.price = price
        self.tag = tag
    }
}

class InAppPurchaseViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private var dataSource: ReloadDataSource<SectionModel<String, Product>>!

    internal var rightSideBarView: RightSideBarView?

    internal weak var inAppPurchaseViewModel: InAppPurchaseViewModel?

    lazy private var rightBarButtonItem: UIBarButtonItem = {
        guard let rightSideBarView = rightSideBarView else {
            return UIBarButtonItem()
        }
        rightSideBarView.delegate {
            self.navigationController?.pushViewController(.alarms, current: self)
        }
        return UIBarButtonItem(customView: rightSideBarView)
    }()

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "스토어"))
    }()

    lazy private var guideLine: UIView = {
        let view = UIView()
        return view
    }()

    lazy private var titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "충전"
        label.font = .boldSystemFont(ofSize: 25)
        label.isUserInteractionEnabled = false
        return label
    }()

    lazy private var underLine1: UIView = {
        let view = UIView()
        view.backgroundColor = .bumble1
        return view
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(InAppPurchaseTableViewCell.self, forCellReuseIdentifier: InAppPurchaseTableViewCell.identifier)
        tableView.delegate = self
        tableView.separatorColor = .systemGray5
        return tableView
    }()

    lazy private var policyLabel: UILabel = {
        let label = UILabel()
        label.text = "환불은 앱스토어 규정을 따릅니다."
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeInAppPurchaseViewModel()
    }

    private func configureSubviews() {
        view.addSubview(guideLine)
        view.addSubview(titleLabel1)
        view.addSubview(underLine1)
        view.addSubview(tableView)
        view.addSubview(policyLabel)
    }

    private func configureConstraints() {

        guideLine.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
        }

        titleLabel1.snp.makeConstraints { make in
            make.bottom.equalTo(guideLine.snp.top)
            make.leading.equalToSuperview().inset(15)
        }

        underLine1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel1.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel1.snp.leading)
            make.trailing.equalTo(titleLabel1.snp.trailing)
            make.height.equalTo(3)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel1.snp.bottom).offset(20)
            make.height.equalTo(69.5 * 4 + 110 * 2)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        policyLabel.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).inset(-20)
            make.leading.equalToSuperview()
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }

    private func subscribeInAppPurchaseViewModel() {

        inAppPurchaseViewModel?
            .products
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .bind(to: tableView.rx.items(cellIdentifier: InAppPurchaseTableViewCell.identifier)) { index, product, cell in
                let cell = cell as? InAppPurchaseTableViewCell
                cell?.bind(product)
            }
            .disposed(by: disposeBag)

        inAppPurchaseViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        inAppPurchaseViewModel?
            .loading
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] boolean in
                navigationController?.progress(boolean)
            })
            .disposed(by: disposeBag)
    }
}

extension InAppPurchaseViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inAppPurchaseViewModel?.purchase(indexPath: indexPath)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
