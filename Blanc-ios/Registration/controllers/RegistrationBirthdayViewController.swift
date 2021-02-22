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

    private struct BirthDay {
        var year = 1985
        var month = 6
        var day = 24
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    private var years = [1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 1980,
                         1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990,
                         1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000,
                         2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
                         2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020]

    private var months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

    private var days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                        21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
                        31]

    private var birthDay = BirthDay()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 3 / RConfig.progressCount
        return progress
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.font = UIFont.boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var yearTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RSelectFieldCell.self, forCellReuseIdentifier: RSelectFieldCell.identifier)
        tableView.layer.cornerRadius = RConfig.cornerRadius
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    lazy private var monthTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RSelectFieldCell.self, forCellReuseIdentifier: RSelectFieldCell.identifier)
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    lazy private var dayTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RSelectFieldCell.self, forCellReuseIdentifier: RSelectFieldCell.identifier)
        tableView.layer.cornerRadius = RConfig.cornerRadius
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 만 18세 미만은 이용 할 수 없습니다."
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

        yearTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.width.equalTo((view.width - RConfig.horizontalMargin * 2) / 3)
            make.height.equalTo(44 * 9)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }

        monthTableView.snp.makeConstraints { make in
            make.leading.equalTo(yearTableView.snp.trailing)
            make.width.equalTo((view.width - RConfig.horizontalMargin * 2) / 3)
            make.height.equalTo(44 * 9)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }

        dayTableView.snp.makeConstraints { make in
            make.leading.equalTo(monthTableView.snp.trailing)
            make.width.equalTo((view.width - RConfig.horizontalMargin * 2) / 3)
            make.height.equalTo(44 * 9)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(yearTableView.snp.bottom).offset(RConfig.noticeTopMargin)
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
                .subscribe(onNext: { [self] userDTO in
                    user = userDTO
                    update(userDTO.birthedAt)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func configureSubviews() {
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(yearTableView)
        view.addSubview(monthTableView)
        view.addSubview(dayTableView)
        view.addSubview(noticeLabel)
        view.addSubview(nextButton)
        view.addSubview(backButton)
    }

    private func update(_ birthedAt: Int?) {

        // 946731661 is timestamp for 2000/01/01
        let timestamp = birthedAt ?? 946731661
        let cal = Time.convertTimestampToCalendar(timestamp: timestamp)

        let yearIndex = years.firstIndex(of: cal.year)
        let yearIndexPath = IndexPath(row: yearIndex!, section: 0)
        yearTableView.selectRow(at: yearIndexPath, animated: true, scrollPosition: .top)
        yearTableView.delegate?.tableView!(yearTableView, didSelectRowAt: yearIndexPath)
        yearTableView.scrollToRow(at: yearIndexPath, at: .top, animated: true)

        let monthIndex = months.firstIndex(of: cal.month)
        let monthIndexPath = IndexPath(row: monthIndex!, section: 0)
        monthTableView.selectRow(at: monthIndexPath, animated: true, scrollPosition: .top)
        monthTableView.delegate?.tableView!(monthTableView, didSelectRowAt: monthIndexPath)
        monthTableView.scrollToRow(at: monthIndexPath, at: .top, animated: true)

        let dayIndex = days.firstIndex(of: cal.day)
        let dayIndexPath = IndexPath(row: dayIndex!, section: 0)
        dayTableView.selectRow(at: dayIndexPath, animated: true, scrollPosition: .top)
        dayTableView.delegate?.tableView!(dayTableView, didSelectRowAt: dayIndexPath)
        dayTableView.scrollToRow(at: dayIndexPath, at: .top, animated: true)
    }

    @objc private func didTapNextButton() {
        let age = Time.calculateAge(
                year: birthDay.year, month: birthDay.month, day: birthDay.day)
        if age < 18 {
            toast(message: "이용 불가능 한 나이 입니다.")
            return
        }
        let timestamp = Time.convertCalendarToTimestamp(
                year: birthDay.year, month: birthDay.month, day: birthDay.day)
        user?.birthedAt = timestamp
        presentNextView()
    }

    @objc private func didTapBackButton() {
        presentBackView()
    }

    private func presentNextView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationHeightViewController")
    }

    private func presentBackView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationSexViewController", animated: false)
    }
}


extension RegistrationBirthdayViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == yearTableView) {
            return years.count
        } else if tableView == monthTableView {
            return months.count
        } else if tableView == dayTableView {
            return days.count
        } else {
            fatalError("Invalid Table found.")
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == yearTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: RSelectFieldCell.identifier, for: indexPath) as! RSelectFieldCell
            cell.textLabel?.text = String(years[indexPath.row])
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textAlignment = .center
            if birthDay.year == years[indexPath.row] {
                cell.select()
            }
            return cell
        } else if tableView == monthTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: RSelectFieldCell.identifier, for: indexPath) as! RSelectFieldCell
            cell.textLabel?.text = String(months[indexPath.row])
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textAlignment = .center
            if birthDay.month == months[indexPath.row] {
                cell.select()
            }
            return cell
        } else if tableView == dayTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: RSelectFieldCell.identifier, for: indexPath) as! RSelectFieldCell
            cell.textLabel?.text = String(days[indexPath.row])
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textAlignment = .center
            if birthDay.day == days[indexPath.row] {
                cell.select()
            }
            return cell
        } else {
            fatalError("Invalid Table found.")
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == yearTableView) {
            let year = years[indexPath.row]
            birthDay.year = year
        } else if tableView == monthTableView {
            let month = months[indexPath.row]
            birthDay.month = month
        } else if tableView == dayTableView {
            let day = days[indexPath.row]
            birthDay.day = day
        } else {
            fatalError("Invalid Table found.")
        }

        let cell = tableView.cellForRow(at: indexPath) as? RSelectFieldCell
        cell?.select()
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? RSelectFieldCell
        cell?.deselect()
    }
}
