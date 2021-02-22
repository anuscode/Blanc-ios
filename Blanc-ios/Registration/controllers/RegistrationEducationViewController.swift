import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationEducationViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    var dataSource = ["고등학교", "전문대", "대학교", "석사", "박사", "기타", "직접입력"]

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 7 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "학력"
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
        tableView.register(RegistrationTextFieldCell.self, forCellReuseIdentifier: RegistrationTextFieldCell.identifier)
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification, object: nil
        )
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
            make.height.equalTo(48 * 6 + 60 + 20)
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
                .subscribe(onNext: { [self] user in
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
        guard user?.education != nil else {
            return
        }

        let index = dataSource.firstIndex(of: user!.education!)

        // 직접입력..
        if index == nil {
            let indexPath = IndexPath(row: dataSource.count - 1, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as? RegistrationTextFieldCell
            cell?.textField.text = user?.education
        } else {
            let indexPath = IndexPath(row: index!, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    @objc private func didTapNextButton() {
        if (user?.education == nil) {
            toast(message: "학력이 입력 되지 않았습니다.")
            return
        }
        presentNextView()
    }

    @objc private func didTapBackButton() {
        presentBackView()
    }

    private func presentNextView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationReligionViewController")
    }

    private func presentBackView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationOccupationViewController", animated: false)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                let window = UIApplication.shared.keyWindow
                view.frame.origin.y -= (keyboardSize.height - (window?.safeAreaInsets.bottom ?? 0))
                view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(closeKeyboard))
            }
        }
    }

    @objc private func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
            view.gestureRecognizers?.forEach { recognizer in
                view.removeGestureRecognizer(recognizer)
            }
        }
    }

    @objc private func closeKeyboard() {
        let indexPath = IndexPath(row: dataSource.count - 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationTextFieldCell
        cell?.textField.endEditing(true)
    }
}

extension RegistrationEducationViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 직접입력
        if indexPath.row == dataSource.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationTextFieldCell.identifier, for: indexPath) as! RegistrationTextFieldCell
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
            if (user?.education != nil && dataSource.firstIndex(of: user?.education ?? "") == nil) {
                cell.textField.text = user?.education
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationSelectFieldCell.identifier, for: indexPath) as! RegistrationSelectFieldCell
            cell.textLabel?.text = dataSource[indexPath.row]
            cell.textLabel?.textAlignment = .center
            guard user?.education != nil else {
                return cell
            }
            let index = dataSource.firstIndex(of: user!.education!)
            if index == indexPath.row {
                cell.select()
            }
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationSelectFieldCell
        cell?.select()
        user?.education = dataSource[indexPath.row]
        resetTextField()
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationSelectFieldCell
        cell?.deselect()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row != dataSource.count - 1 ? 48 : UITableView.automaticDimension
    }

    @objc private func didChangeTextField(_ textField: UITextField) {
        let indexPath = tableView.indexPathForSelectedRow
        let index = dataSource.firstIndex(of: user?.education ?? "")
        if indexPath?.row != nil && indexPath?.row == index {
            let cell = tableView.cellForRow(at: indexPath!) as? RegistrationSelectFieldCell
            cell?.deselect()
        }
        user?.education = textField.text ?? ""
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }

    private func resetTextField() {
        let indexPath = IndexPath(row: dataSource.count - 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationTextFieldCell
        cell?.textField.text = ""
        cell?.textField.resignFirstResponder()
        cell?.textField.layer.borderColor = UIColor.secondarySystemBackground.cgColor
    }
}