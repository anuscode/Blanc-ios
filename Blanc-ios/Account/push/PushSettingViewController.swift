import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard

class PushSettingViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    internal weak var pushSettingViewModel: PushSettingViewModel?

    internal weak var pushSetting: PushSetting?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "푸시 설정"))
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PushSettingTableViewCell.self, forCellReuseIdentifier: PushSettingTableViewCell.identifier)
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return tableView
    }()

    lazy private var alarmGuide: UILabel = {
        let label = UILabel()
        label.text = "• 푸시 설정은 앱 외부의 알림에만 해당 됩니다.\n• 앱 사용 중 표시되는 알람에는 해당 되지 않습니다."
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 13, weight: .light)
        return label
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = true
        view.backgroundColor = .secondarySystemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribePushSettingViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwinjectStoryboard.defaultContainer.resetObjectScope(.pushSettingScope)
    }

    deinit {
        log.info("deinit push setting view controller..")
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(alarmGuide)
    }

    private func configureConstraints() {
        let height = 46.5 + (44.5 * 8)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(height + 20)
        }

        alarmGuide.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func subscribePushSettingViewModel() {
        pushSettingViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] pushSetting in
                self.pushSetting = pushSetting
                tableView.reloadData()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}

extension PushSettingViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        9
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? 46.5 : 44.5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PushSettingTableViewCell.identifier, for: indexPath) as! PushSettingTableViewCell
        if (indexPath.row == 0) {
            cell.bind(attribute: .all, isEnable: pushSetting?.all == true, isBoldTitle: true, delegate: self)
        } else if (indexPath.row == 1) {
            cell.bind(attribute: .poke, isEnable: pushSetting?.poke == true, isBoldTitle: false, delegate: self)
        } else if (indexPath.row == 2) {
            cell.bind(attribute: .request, isEnable: pushSetting?.request == true, isBoldTitle: false, delegate: self)
        } else if (indexPath.row == 3) {
            cell.bind(attribute: .comment, isEnable: pushSetting?.comment == true, isBoldTitle: false, delegate: self)
        } else if (indexPath.row == 4) {
            cell.bind(attribute: .highRate, isEnable: pushSetting?.highRate == true, isBoldTitle: false, delegate: self)
        } else if (indexPath.row == 5) {
            cell.bind(attribute: .match, isEnable: pushSetting?.match == true, isBoldTitle: false, delegate: self)
        } else if (indexPath.row == 6) {
            cell.bind(attribute: .favoriteComment, isEnable: pushSetting?.commentThumbUp == true, isBoldTitle: false, delegate: self)
        } else if (indexPath.row == 7) {
            cell.bind(attribute: .conversation, isEnable: pushSetting?.conversation == true, isBoldTitle: false, delegate: self)
        } else if (indexPath.row == 8) {
            cell.bind(attribute: .lookup, isEnable: pushSetting?.lookup == true, isBoldTitle: false, delegate: self)
        } else {
            fatalError("WATCH OUT YOUR ASS HOLE..")
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension PushSettingViewController: PushSettingTableViewCellDelegate {
    func update(attribute: PushSettingAttribute) {
        pushSettingViewModel?.update(attribute) { [unowned self] in
            toast(message: "설정 저장에 실패 하였습니다.")
        }
    }
}
