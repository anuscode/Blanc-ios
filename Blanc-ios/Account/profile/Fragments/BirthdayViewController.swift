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


class BirthdayViewController: UIViewController {

    private struct BirthDay {
        var year = 1985
        var month = 6
        var day = 24
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var profileViewModel: ProfileViewModel?

    private var userDTO: UserDTO?

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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "생일을 입력하세요"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    private let yearTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .darkGray
        tableView.register(SelectFieldCell.self, forCellReuseIdentifier: SelectFieldCell.identifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let monthTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .darkGray
        tableView.register(SelectFieldCell.self, forCellReuseIdentifier: SelectFieldCell.identifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let dayTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .darkGray
        tableView.register(SelectFieldCell.self, forCellReuseIdentifier: SelectFieldCell.identifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 정확하게 입력 하세요.."
        label.font = UIFont.systemFont(ofSize: 12)
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

        yearTableView.separatorColor = .clear
        yearTableView.delegate = self
        yearTableView.dataSource = self

        monthTableView.separatorColor = .clear
        monthTableView.delegate = self
        monthTableView.dataSource = self

        dayTableView.separatorColor = .clear
        dayTableView.delegate = self
        dayTableView.dataSource = self

        addSubviews()
        configConstraints()
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

    func configConstraints() {

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(FragmentConfig.verticalMargin)
        }

        yearTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.width.equalTo((view.width - 50) / 4)
            make.height.equalTo(44 * 6)
            make.top.equalTo(titleLabel.snp.bottom).inset(-FragmentConfig.contentMarginTop)
        }

        monthTableView.snp.makeConstraints { make in
            make.leading.equalTo(yearTableView.snp.trailing)
            make.width.equalTo((view.width - 50) / 4)
            make.height.equalTo(44 * 6)
            make.top.equalTo(titleLabel.snp.bottom).inset(-FragmentConfig.contentMarginTop)
        }

        dayTableView.snp.makeConstraints { make in
            make.leading.equalTo(monthTableView.snp.trailing)
            make.width.equalTo((view.width - 50) / 4)
            make.height.equalTo(44 * 6)
            make.top.equalTo(titleLabel.snp.bottom).inset(-FragmentConfig.contentMarginTop)
        }

        warningLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
            make.top.equalTo(yearTableView.snp.bottom).inset(-FragmentConfig.warningTextMarginTop)
        }

        confirmButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(25)
            make.top.equalTo(warningLabel.snp.bottom).inset(-FragmentConfig.confirmButtonMarginTop)
            make.height.equalTo(FragmentConfig.confirmButtonHeight)
        }

        ripple.activate(to: confirmButton)

        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    }

    private func subscribeViewModel() {
        profileViewModel?.observe()
                .subscribe(onNext: { [self] userDTO in
                    self.userDTO = userDTO
                    initTables(userDTO.birthedAt)
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
        view.addSubview(yearTableView)
        view.addSubview(monthTableView)
        view.addSubview(dayTableView)
    }

    @objc private func didTapConfirmButton() {
        let age = Time.calculateAge(
                year: birthDay.year, month: birthDay.month, day: birthDay.day)
        if age < 18 {
            toast(message: "이용 불가능 한 나이 입니다.")
            return
        }
        let timestamp = Time.convertCalendarToTimestamp(
                year: birthDay.year, month: birthDay.month, day: birthDay.day)
        userDTO?.birthedAt = timestamp
        profileViewModel?.update()
    }

    private func initTables(_ birthedAt: Int?) {

        // 946731661 is timestamp for 2000/01/01
        let timestamp: Int = birthedAt ?? 946731661
        let cal = timestamp.asCalendar()

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

    private func activateConfirmButton() {
        // TODO: didTapConfirmButton
        let age = Time.calculateAge(year: birthDay.year, month: birthDay.month, day: birthDay.day)
        if age >= 18 {
            confirmButton.backgroundColor = .bumble3
        } else {
            confirmButton.backgroundColor = .lightGray
        }
    }
}

extension BirthdayViewController: UITableViewDelegate, UITableViewDataSource {

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
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectFieldCell.identifier, for: indexPath) as! SelectFieldCell
            cell.textLabel?.text = String(years[indexPath.row])
            if birthDay.year == years[indexPath.row] {
                cell.select()
            }
            return cell
        } else if tableView == monthTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectFieldCell.identifier, for: indexPath) as! SelectFieldCell
            cell.textLabel?.text = String(months[indexPath.row])
            if birthDay.month == months[indexPath.row] {
                cell.select()
            }
            return cell
        } else if tableView == dayTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectFieldCell.identifier, for: indexPath) as! SelectFieldCell
            cell.textLabel?.text = String(days[indexPath.row])
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

        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.select()
        activateConfirmButton()
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.deselect()
    }
}
