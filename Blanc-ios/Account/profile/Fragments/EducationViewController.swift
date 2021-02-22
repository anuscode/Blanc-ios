import FirebaseAuth
import Foundation
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import UIKit
import RxSwift
import SwinjectStoryboard


class EducationViewController: UIViewController {


    struct Data {
        var value: String
        var index: Int
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var user: UserDTO?

    var selected: Data?

    var profileViewModel: ProfileViewModel?

    var dataSource = ["고등학교", "전문대", "대학교", "석사", "박사", "기타", "직접입력"]

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최종 학력을 입력하세요"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SelectFieldCell.self, forCellReuseIdentifier: SelectFieldCell.identifier)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.add(FragmentConfig.transition, forKey: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
            make.height.equalTo(44 * 7)
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
        guard selected?.value != nil && !(selected?.value.isEmpty ?? true) else {
            toast(message: "선택 된 값이 존재하지 않습니다.")
            return
        }
        user?.education = selected?.value
        profileViewModel?.update()
    }

    private func update() {
        let value = user?.education
        guard value != nil else {
            return
        }
        let index = dataSource.firstIndex(of: value!)

        // 직접입력..
        if index == nil {
            selectValue(value!, dataSource.count - 1)
            let indexPath = IndexPath(row: dataSource.count - 1, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as? RegistrationTextFieldCell
            cell?.textField.text = user?.education
        } else {
            selected?.value = value!
            selectValue(value!, index!)
            let indexPath = IndexPath(row: selected!.index, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        log.info("initial value: \(selected?.value), index: \(selected?.index)")
    }

    private func selectValue(_ value: String, _ index: Int) {
        selectValue(Data(value: value, index: index))
    }

    private func selectValue(_ value: Data) {
        selected = value
        activateConfirmButton()
        log.info("selected value: \(selected?.value), index: \(selected?.index)")
    }

    private func activateConfirmButton() {
        if selected?.value != nil && !(selected?.value.isEmpty ?? true) {
            confirmButton.backgroundColor = .bumble3
        } else {
            confirmButton.backgroundColor = .lightGray
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension EducationViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == dataSource.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
            if selected?.index == dataSource.count - 1 {
                cell.textField.text = selected?.value
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectFieldCell.identifier, for: indexPath) as! SelectFieldCell
            let value = dataSource[indexPath.row]
            cell.textLabel?.text = value
            if selected?.index == indexPath.row {
                cell.select()
            }
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.select()
        let value = dataSource[indexPath.row]
        let index = indexPath.row
        selectValue(Data(value: value, index: index))
        resetTextField()
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.deselect()
    }

    @objc private func didChangeTextField(_ textField: MDCOutlinedTextField) {
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath?.row != nil && indexPath?.row == selected?.index {
            let cell = tableView.cellForRow(at: indexPath!) as? SelectFieldCell
            cell?.deselect()
        }
        let value = textField.text ?? ""
        selectValue(Data(value: value, index: dataSource.count - 1))
    }

    private func resetTextField() {
        let indexPath = IndexPath(row: dataSource.count - 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell
        cell?.textField.text = ""
    }
}
