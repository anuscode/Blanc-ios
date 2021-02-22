import FirebaseAuth
import Foundation
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import UIKit
import RxSwift
import SwinjectStoryboard


class SmokingViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var profileViewModel: ProfileViewModel?

    private var user: UserDTO?

    private var selectedValue: Int?

    private var dataSource: [String] = {
        UserGlobal.smokings
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "흡연을 입력하세요"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SelectFieldCell.self, forCellReuseIdentifier: SelectFieldCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    lazy private var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        ripple.activate(to: button)
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        return button
    }()

    lazy private var loadingView: LoadingView = {
        let view = LoadingView()
        view.visible(false)
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.add(FragmentConfig.transition, forKey: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    override func viewDidLayoutSubviews() {

        view.snp.makeConstraints { make in
            make.top.equalTo(self.parent!.view.safeAreaLayoutGuide)
            make.bottom.equalTo(confirmButton.snp.bottom).inset(-FragmentConfig.verticalMargin)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalTo(self.parent!.view.snp.centerX)
        }
    }

    private func configureConstraints() {

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(FragmentConfig.verticalMargin)
        }

        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
            make.height.equalTo(44 * 4)
            make.top.equalTo(titleLabel.snp.bottom).inset(-FragmentConfig.contentMarginTop)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
            make.top.equalTo(tableView.snp.bottom).inset(-FragmentConfig.confirmButtonMarginTop)
            make.height.equalTo(FragmentConfig.confirmButtonHeight)
        }
    }

    private func subscribeViewModel() {
        profileViewModel?.observe()
                .subscribe(onNext: { user in
                    self.user = user
                    self.update()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func configureSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(confirmButton)
        view.addSubview(loadingView)
        view.addSubview(tableView)
    }

    @objc private func didTapConfirmButton() {
        user?.smokingId = selectedValue
        profileViewModel?.update()
    }

    private func update() {
        let index = user?.smokingId
        guard index != nil else {
            return
        }
        let indexPath = IndexPath(row: index!, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    private func selectValue(_ index: Int?) {
        selectedValue = index
        activateConfirmButton()
    }

    private func activateConfirmButton() {
        if selectedValue != nil {
            confirmButton.backgroundColor = .bumble3
        } else {
            confirmButton.backgroundColor = .lightGray
        }
    }
}

extension SmokingViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectFieldCell.identifier, for: indexPath) as! SelectFieldCell
        let data = indexPath.row
        cell.textLabel?.text = dataSource[indexPath.row]
        if data == selectedValue {
            cell.select()
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.select()
        selectValue(indexPath.row)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.deselect()
    }
}
