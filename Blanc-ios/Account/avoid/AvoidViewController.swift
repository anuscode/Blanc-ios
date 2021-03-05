import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard

class AvoidViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple = Ripple()

    private var contacts: [Contact] = []

    private var dataSource: UITableViewDiffableDataSource<Section, Contact>?

    var avoidViewModel: AvoidViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "지인 차단"))
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.register(AvoidTableViewCell.self, forCellReuseIdentifier: AvoidTableViewCell.identifier)
        tableView.delegate = self
        return tableView
    }()

    lazy private var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(45)
        }
        return view
    }()

    lazy private var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bumble3
        button.setTitle("전체 차단", for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        configureTableViewDataSource()
        subscribeAvoidViewModel()
        populate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .secondarySystemBackground
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwinjectStoryboard.defaultContainer.resetObjectScope(.avoidScope)
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(bottomView.snp.top).inset(-10)
        }

        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(55 + bottomPadding)
        }
    }

    private func subscribeAvoidViewModel() {
        avoidViewModel?.observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] contacts in
                self.contacts = contacts
                DispatchQueue.main.async {
                    update()
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func populate() {
        avoidViewModel?.populate(onError: {
            self.toast(message: "연락처 정보를 가져오지 못했습니다.")
        })
    }

    @objc private func didTapButton() {
        avoidViewModel?.updateUserContacts(onSuccess: { [unowned self] in
            toast(message: "이제 연락처에 등록 된 사람은 서로 추천에서 제외 됩니다.") {
                navigationController?.popToRootViewController(animated: true)
            }
        }, onError: { [unowned self] in
            toast(message: "아는 사람 만나지 않기 등록 중 에러가 발생 하였습니다.")
        })
    }
}

extension AvoidViewController {

    fileprivate enum Section {
        case Main
    }

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Contact>(tableView: tableView) { (tableView, indexPath, contact) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AvoidTableViewCell.identifier,
                for: indexPath) as? AvoidTableViewCell else {
                return UITableViewCell()
            }
            cell.bind(contact: contact)
            return cell
        }
        tableView.dataSource = dataSource
    }

    private func update(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Contact>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(contacts)
        dataSource?.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
    }
}

extension AvoidViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = "\(contacts.count) 개의 연락처 발견"
        label.font = .boldSystemFont(ofSize: 20)

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }

        if (section != 0) {
            let border = UIView()
            border.backgroundColor = .systemGray5
            view.addSubview(border)
            border.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(20)
                make.trailing.equalToSuperview().inset(20)
                make.top.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }

        return view
    }
}