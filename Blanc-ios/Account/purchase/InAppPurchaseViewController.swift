import Foundation
import UIKit
import StoreKit

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

    private var products: [Product] = [
        Product(productId: "ios.com.ground.blanc.point.2500.won", title: "포인트 10", discount: "할인 없음 😔", price: "₩2,500"),
        Product(productId: "ios.com.ground.blanc.point.4900.won", title: "포인트 20", discount: "약 2% 할인", price: "₩4,900"),
        Product(productId: "ios.com.ground.blanc.point.11000.won", title: "포인트 50", discount: "약 8.3% 할인", price: "₩11,000", tag: "할인율 대비 가격이 문안 합니다. 👍"),
        Product(productId: "ios.com.ground.blanc.point.20000.won", title: "포인트 100", discount: "약 16.6% 할인", price: "₩20,000", tag: "보통 이 상품이 가장 적절 합니다. 😃"),
        Product(productId: "ios.com.ground.blanc.point.36000.won", title: "포인트 200", discount: "약 25% 할인", price: "₩36,000"),
        Product(productId: "ios.com.ground.blanc.point.79000.won", title: "포인트 500", discount: "약 37% 할인", price: "₩79,000")
    ]

    var rightSideBarView: RightSideBarView?

    var inAppPurchaseViewModel: InAppPurchaseViewModel?

    lazy private var rightBarButtonItem: UIBarButtonItem = {
        guard (rightSideBarView != nil) else {
            return UIBarButtonItem()
        }
        rightSideBarView!.delegate {
            self.navigationController?.pushAlarmViewController(current: self)
        }
        return UIBarButtonItem(customView: rightSideBarView!)
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
        tableView.dataSource = self
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
}

extension InAppPurchaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: InAppPurchaseTableViewCell.identifier, for: indexPath) as! InAppPurchaseTableViewCell
        let product = products[indexPath.row]
        cell.bind(product)
        return cell
    }
}

extension InAppPurchaseViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.startProgress()
        let productId = products[indexPath.row].productId
        inAppPurchaseViewModel?.purchase(
                productId: productId,
                onSuccess: {
                    self.navigationController?.stopProgress()
                },
                onError: {
                    self.toast(message: "결제 프로세스가 중단 되었습니다.")
                    self.navigationController?.stopProgress()
                })
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
