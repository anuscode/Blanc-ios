import Foundation
import UIKit
import StoreKit


struct Product {
    let title: String
    let discount: String
    let price: String
    let tag: String?

    init(title: String, discount: String, price: String, tag: String? = nil) {
        self.title = title
        self.discount = discount
        self.price = price
        self.tag = tag
    }
}

class InAppPurchaseViewController: UIViewController {

    private var products: [Product] = [
        Product(title: "포인트 5", discount: "약 0% 할인 😔", price: "₩1,500"),
        Product(title: "포인트 15", discount: "약 2% 할인", price: "₩4,400"),
        Product(title: "포인트 50", discount: "약 10% 할인", price: "₩13,500", tag: "할인율 대비 가격이 문안 합니다. 👍"),
        Product(title: "포인트 100", discount: "약 15% 할인", price: "₩25,500", tag: "보통 이 상품이 가장 적절 합니다. 😃"),
        Product(title: "포인트 200", discount: "약 25% 할인", price: "₩44,900"),
        Product(title: "포인트 500", discount: "약 34% 할인", price: "₩99,900")
    ]

    var rightSideBarView: RightSideBarView?

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
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
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
            make.trailing.equalToSuperview()
        }
    }

    @objc private func didTapButton() {
        navigationController?.startProgress()
        IAPManager.shared.purchase(productId: "com.ground.blanc.point.1200.won",
                onPurchased: { transaction in
                    guard let receiptURL = Bundle.main.appStoreReceiptURL,
                          let receiptString = try? Data(contentsOf: receiptURL).base64EncodedString() else {
                        return
                    }

                    let requestData: [String: Any] = [
                        "receipt-data": receiptString,
                        "password": "0062c0812a164740bed2e43f606cf80c",
                        "exclude-old-transactions": false
                    ]
                    print(receiptString)
                    self.navigationController?.stopProgress()
                },
                onFailed: {
                    self.navigationController?.stopProgress()
                }
        )
    }
}

extension InAppPurchaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
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
        IAPManager.shared.purchase(productId: "com.ground.blanc.point.1200.won",
                onPurchased: { transaction in
                    IAPManager.shared.finishTransaction(transaction: transaction)
                    self.navigationController?.stopProgress()
                },
                onFailed: {
                    self.navigationController?.stopProgress()
                }
        )
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
