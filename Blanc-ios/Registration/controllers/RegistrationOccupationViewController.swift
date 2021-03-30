import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationOccupationViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal var registrationViewModel: RegistrationViewModel?

    private weak var user: UserDTO?

    private var dataSource = UserGlobal.occupations

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .secondarySystemBackground
        progress.progressTintColor = .black
        progress.progress = 6 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "직업/직장"
        label.font = .boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var textFieldSubjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.text = "당신의 직업(or 직장)을 알려주세요."
        return label
    }()

    lazy private var textField: UITextField = {
        let textField = UITextField()
        textField.addPadding(direction: .left, width: 15)
        textField.attributedPlaceholder = NSAttributedString(
            string: "직업을 입력 하세요.",
            attributes: [.foregroundColor: UIColor.deepGray]
        )
        textField.font = .systemFont(ofSize: 18)
        textField.keyboardType = .default
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = RConfig.cornerRadius
        textField.tintColor = .systemBlue
        textField.rx
            .controlEvent([.editingChanged])
            .asObservable()
            .subscribe({ _ in
                let lastIndex = self.dataSource.count - 1
                self.selectPickerView(lastIndex)
                self.user?.occupation = self.textField.text
            }).disposed(by: disposeBag)

        return textField
    }()

    lazy private var clearButton: UIImageView = {
        let imageView = UIImageView()
        let systemName = "xmark.circle.fill"
        let image = UIImage(systemName: systemName)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        imageView.image = image
        imageView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [unowned self]_ in
                let lastIndex = self.dataSource.count - 1
                self.selectPickerView(lastIndex)
                self.textField.text = ""
                self.textField.resignFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.textField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)

        return imageView
    }()

    lazy private var keyboardClearView: UIView = {
        let view = UIView()
        view.visible(false)
        view.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                self.closeKeyboard()
            })
            .disposed(by: disposeBag)
        return view
    }()

    lazy private var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.layer.cornerRadius = 15
        pickerView.layer.masksToBounds = true
        pickerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.rx
            .itemSelected
            .subscribe { (row, component) in
                if (row == self.dataSource.count - 1) {
                    let currentText = self.textField.text ?? ""
                    if (self.dataSource.contains(currentText)) {
                        self.textField.text = ""
                    }
                } else {
                    self.textField.text = self.dataSource[row]
                }
            }
            .disposed(by: disposeBag)
        return pickerView
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "목록에 해당 직업이 없다면\n상단의 입력창에 직접 입력 할 수 있습니다."
        label.font = .systemFont(ofSize: RConfig.noticeSize)
        label.numberOfLines = 2;
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
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )

        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }

    deinit {
        log.info("deinit registration occupation view controller..")
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(textFieldSubjectLabel)
        view.addSubview(pickerView)
        view.addSubview(noticeLabel)

        view.addSubview(keyboardClearView)
        view.addSubview(textField)
        view.addSubview(clearButton)
        view.addSubview(backButton)
        view.addSubview(nextButton)
    }

    private func configureConstraints() {

        starFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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

        textFieldSubjectLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(textFieldSubjectLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo((view.width - RConfig.horizontalMargin * 2))
            make.height.equalTo(50)
        }

        clearButton.snp.makeConstraints { make in
            make.trailing.equalTo(textField.snp.trailing).inset(15)
            make.centerY.equalTo(textField.snp.centerY)
        }

        pickerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.height.equalTo(44 * 7)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(pickerView.snp.bottom).offset(RConfig.noticeTopMargin)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.nextBottomMargin)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.backBottomMargin)
        }

        keyboardClearView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?
            .user
            .take(1)
            .subscribe(onNext: { [unowned self] user in
                self.user = user
                update()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func update() {
        if user?.occupation == nil {
            user?.occupation = dataSource.first
        }

        if let index = dataSource.firstIndex(where: { $0 == user?.occupation }) {
            selectPickerView(index)
        } else {
            let lastIndex = dataSource.count - 1
            selectPickerView(lastIndex)
        }
        textField.text = user?.occupation
    }

    private func selectPickerView(_ index: Int) {
        pickerView.selectRow(index, inComponent: 0, animated: true)
        pickerView.delegate?.pickerView?(pickerView, didSelectRow: index, inComponent: 0)
    }

    @objc private func didTapNextButton() {
        let occupation = textField.text ?? ""
        if (occupation.isEmpty) {
            toast(message: "직업이 입력 되지 않았습니다.")
            return
        }
        user?.occupation = occupation
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegistrationEducationViewController")
        navigationController?.pushViewController(vc, animated: true)
        if let index = navigationController?.viewControllers.firstIndex(of: self) {
            navigationController?.viewControllers.remove(at: index)
        }
    }

    private func back() {
        user?.occupation = textField.text
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationBodyTypeViewController", animated: false)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            nextButton.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(keyboardHeight + 20)
            }
            backButton.snp.remakeConstraints { make in
                make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(keyboardHeight + 20)
            }
        }
        keyboardClearView.visible(true)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        nextButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.nextBottomMargin)
        }
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.backBottomMargin)
        }
        keyboardClearView.visible(false)
    }

    @objc private func closeKeyboard() {
        textField.endEditing(true)
    }
}

extension RegistrationOccupationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataSource.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        dataSource[row]
    }
}