import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationHeightViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal weak var registrationViewModel: RegistrationViewModel?

    private weak var user: UserDTO?

    private var labelSource = Array(stride(from: 100, to: 220, by: 1)).map({ "\($0) cm" })

    private var dataSource = Array(stride(from: 100, to: 220, by: 1))

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .secondarySystemBackground
        progress.progressTintColor = .black
        progress.progress = 4 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "키"
        label.font = UIFont.boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var resultSubjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.text = "당신의 키를 알려주세요."
        return label
    }()

    lazy private var resultView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "입력 된 값이 없습니다."
        return label
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
            .subscribe(onNext: { (row, component) in
                self.user?.height = self.dataSource[row]
                self.resultLabel.text = self.labelSource[row]
            })
            .disposed(by: disposeBag)
        return pickerView
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: RConfig.noticeSize)
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }

    deinit {
        log.info("deinit registration height view controller..")
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

        resultSubjectLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
        }

        resultView.snp.makeConstraints { make in
            make.top.equalTo(resultSubjectLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo((view.width - RConfig.horizontalMargin * 2))
            make.height.equalTo(50)
        }

        pickerView.snp.makeConstraints { make in
            make.top.equalTo(resultView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo((view.width - RConfig.horizontalMargin))
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
    }

    private func subscribeViewModel() {
        registrationViewModel?
            .user
            .take(1)
            .subscribe(onNext: { [unowned self] user in
                self.user = user
                update()
            })
            .disposed(by: disposeBag)
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(resultSubjectLabel)
        view.addSubview(resultView)
        view.addSubview(pickerView)
        view.addSubview(noticeLabel)
        view.addSubview(nextButton)
        view.addSubview(backButton)
    }

    private func update() {
        if user?.height == nil {
            user?.height = 160
        }
        let height = user?.height
        if let index = dataSource.firstIndex(where: { $0 == height }) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
            pickerView.delegate?.pickerView?(pickerView, didSelectRow: index, inComponent: 0)
        }
    }

    @objc private func didTapNextButton() {
        if user?.height == nil {
            toast(message: "키가 입력 되지 않았습니다.")
            return
        }
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegistrationBodyTypeViewController")
        navigationController?.pushViewController(vc, animated: true)
        if let index = navigationController?.viewControllers.firstIndex(of: self) {
            navigationController?.viewControllers.remove(at: index)
        }
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationBirthdayViewController", animated: false)
    }
}


extension RegistrationHeightViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataSource.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        labelSource[row]
    }
}
