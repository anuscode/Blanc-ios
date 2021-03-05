import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationBloodTypeViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    var dataSource: [String] = {
        UserGlobal.bloodTypes
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 11 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "혈액형"
        label.font = .boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.layer.cornerRadius = RConfig.cornerRadius
        tableView.layer.masksToBounds = true
        tableView.separatorColor = .clear
        tableView.register(RegistrationSelectFieldCell.self, forCellReuseIdentifier: RegistrationSelectFieldCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return tableView
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: RConfig.noticeSize)
        label.numberOfLines = 4;
        label.textColor = .black
        return label
    }()

    lazy private var nextButton: NextButton = {
        let button = NextButton()
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapNextButton))
        return button
    }()

    lazy private var backButton: BackButton = {
        let button = BackButton()
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapBackButton))
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .bumble1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    private func configureConstraints() {

        progressView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(RConfig.progressTopMargin)
            make.height.equalTo(3)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(progressView.snp.bottom).offset(RConfig.titleTopMargin)
        }

        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(48 * dataSource.count + 20)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(tableView.snp.bottom).offset(RConfig.noticeTopMargin)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.nextBottomMargin)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.backBottomMargin)
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?.observe()
                .take(1)
                .subscribe(onNext: { [unowned self] user in
                    self.user = user
                    update()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func configureSubviews() {
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(noticeLabel)
        view.addSubview(nextButton)
        view.addSubview(backButton)
    }

    private func update() {
        if (user?.bloodId == nil) {
            return
        }

        let indexPath = IndexPath(row: user!.bloodId!, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    @objc private func didTapNextButton() {
        if (user?.bloodId == nil) {
            toast(message: "혈액형이 입력 되지 않았습니다.")
            return
        }
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationCharmViewController")
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationSmokingViewController", animated: false)
    }
}


extension RegistrationBloodTypeViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationSelectFieldCell.identifier, for: indexPath) as! RegistrationSelectFieldCell
        let data = dataSource[indexPath.row]
        cell.textLabel?.text = data
        cell.textLabel?.textAlignment = .center
        if indexPath.row == user?.bloodId {
            cell.select()
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationSelectFieldCell
        cell?.select()
        user?.bloodId = indexPath.row
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationSelectFieldCell
        cell?.deselect()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
}
