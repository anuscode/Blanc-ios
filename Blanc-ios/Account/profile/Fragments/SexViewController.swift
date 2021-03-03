import AMShimmer
import FirebaseAuth
import Foundation
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import UIKit
import RxSwift
import SwinjectStoryboard


class SexViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var profileViewModel: ProfileViewModel?

    var userDTO: UserDTO?

    var selectedValue: Sex?

    var dataSource = [Sex.MALE, Sex.FEMALE]

    var labelSource = ["남자", "여자"]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "성별을 입력하세요"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .darkGray
        tableView.register(SelectFieldCell.self, forCellReuseIdentifier: SelectFieldCell.identifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 성별은 어떠한 이유로도 추후 변경이 불가능 합니다. \n2.옳바르지 않은 성별 등록 후 적발 시 해당 전화번호는 영구 이용정지 됩니다."
        label.font = UIFont.systemFont(ofSize: 8)
        label.numberOfLines = 3;
        label.textColor = .secondaryLabel
        return label
    }()

    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.visible(false)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.add(FragmentConfig.transition, forKey: nil)

        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self

        addSubviews()
        subscribeViewModel()
    }

    override func viewDidLayoutSubviews() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(FragmentConfig.verticalMargin)
        }

        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
            make.height.equalTo(88)
            make.top.equalTo(titleLabel.snp.bottom).inset(-FragmentConfig.contentMarginTop)
        }

        warningLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
            make.top.equalTo(tableView.snp.bottom).inset(-FragmentConfig.warningTextMarginTop)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
            make.top.equalTo(warningLabel.snp.bottom).inset(-FragmentConfig.confirmButtonMarginTop)
            make.height.equalTo(FragmentConfig.confirmButtonHeight)
        }

        view.snp.makeConstraints { make in
            make.top.equalTo(self.parent!.view.safeAreaLayoutGuide)
            make.bottom.equalTo(confirmButton.snp.bottom).inset(-FragmentConfig.verticalMargin)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalTo(self.parent!.view.snp.centerX)
        }

        ripple.activate(to: confirmButton)

        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    }

    private func subscribeViewModel() {
        profileViewModel?.observe()
                .subscribe(onNext: { [unowned self] userDTO in
                    self.userDTO = userDTO
                    setInitialValue(userDTO.sex)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(warningLabel)
        view.addSubview(confirmButton)
        view.addSubview(loadingView)
        view.addSubview(tableView)
    }

    @objc private func didTapConfirmButton() {
        userDTO?.sex = selectedValue
        profileViewModel?.update()
    }

    private func setInitialValue(_ sex: Sex?) {
        guard sex != nil else {
            return
        }

        let index = dataSource.firstIndex(of: sex!)
        let indexPath = IndexPath(row: index!, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
    }

    private func selectValue(_ sex: Sex?) {
        selectedValue = sex
        activateConfirmButton()
    }

    private func activateConfirmButton() {
        if selectedValue != nil {
            confirmButton.backgroundColor = .systemBlue
        } else {
            confirmButton.backgroundColor = .lightGray
        }
    }
}

extension SexViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectFieldCell.identifier, for: indexPath)
        cell.textLabel?.text = labelSource[indexPath.row]
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        cell?.textLabel?.textColor = .systemPink
        let sex = dataSource[indexPath.row]
        selectValue(sex)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCell.AccessoryType.none
        cell?.textLabel?.textColor = .darkGray
    }
}
