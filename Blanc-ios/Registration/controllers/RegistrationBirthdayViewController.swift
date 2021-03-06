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

private typealias RSelectFieldCell = RegistrationSelectFieldCell

class RegistrationBirthdayViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    private var years = Array(stride(from: 1971, to: 2021 + 1, by: 1))

    private var months = Array(stride(from: 1, to: 12 + 1, by: 1))

    private var days = Array(stride(from: 1, to: 31 + 1, by: 1))

    private var birthDay = Cal(year: 1985, month: 6, day: 24)

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .secondarySystemBackground
        progress.progressTintColor = .black
        progress.progress = 3 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.font = UIFont.boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var resultSubjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.text = "생년월일을 알려주세요."
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
            .subscribe { (row, component) in
                switch component {
                case 0:
                    self.birthDay.year = self.years[row]
                case 1:
                    self.birthDay.month = self.months[row]
                case 2:
                    self.birthDay.day = self.days[row]
                default:
                    break
                }
                self.resultLabel.text =
                    "\(self.birthDay.year)년 \(self.birthDay.month)월 \(self.birthDay.day)일"
            }
            .disposed(by: disposeBag)
        return pickerView
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 만 18세 미만은 이용 할 수 없습니다."
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
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
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
            // make.top.equalTo(pickerView.snp.bottom).offset(RConfig.noticeTopMargin)
            make.top.equalTo(pickerView.snp.bottom)
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
            .observe()
            .take(1)
            .subscribe(onNext: { user in
                self.user = user
                self.update()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func update() {

        if user?.birthedAt == nil {
            user?.birthedAt = Cal(year: 2000, month: 06, day: 15).asTimestamp()
        }

        let timestamp = user?.birthedAt ?? Cal(year: 2000, month: 06, day: 15).asTimestamp()
        let cal = timestamp.asCalendar()

        if let yearIndex = years.firstIndex(where: { $0 == cal.year }) {
            pickerView.selectRow(yearIndex, inComponent: 0, animated: true)
            pickerView.delegate?.pickerView?(pickerView, didSelectRow: yearIndex, inComponent: 0)
        }

        if let monthIndex = months.firstIndex(where: { $0 == cal.month }) {
            pickerView.selectRow(monthIndex, inComponent: 1, animated: true)
            pickerView.delegate?.pickerView?(pickerView, didSelectRow: monthIndex, inComponent: 1)
        }

        if let dayIndex = days.firstIndex(where: { $0 == cal.day }) {
            pickerView.selectRow(dayIndex, inComponent: 2, animated: true)
            pickerView.delegate?.pickerView?(pickerView, didSelectRow: dayIndex, inComponent: 2)
        }
    }

    @objc private func didTapNextButton() {
        let age = birthDay.asAge()
        if age < 18 {
            toast(message: "이용 불가능 한 나이 입니다.")
            return
        }
        user?.birthedAt = birthDay.asTimestamp()
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationHeightViewController")
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationSexViewController", animated: false)
    }
}


extension RegistrationBirthdayViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (component) {
        case 0:
            return years.count
        case 1:
            return months.count
        case 2:
            return days.count
        default:
            fatalError("Invalid component found.")
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch (component) {
        case 0:
            return "\(years[row])"
        case 1:
            return "\(months[row])"
        case 2:
            return "\(days[row])"
        default:
            fatalError("Invalid component found.")
        }
    }
}
