import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationHeightViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    private var labelSource = [
        "150 cm", "151 cm", "152 cm", "153 cm", "154 cm", "155 cm", "156 cm", "157 cm", "158 cm", "159 cm",
        "160 cm", "161 cm", "162 cm", "163 cm", "164 cm", "165 cm", "166 cm", "167 cm", "168 cm", "169 cm",
        "170 cm", "171 cm", "172 cm", "173 cm", "174 cm", "175 cm", "176 cm", "177 cm", "178 cm", "179 cm",
        "180 cm", "181 cm", "182 cm", "183 cm", "184 cm", "185 cm", "186 cm", "187 cm", "188 cm", "189 cm",
        "190 cm", "191 cm", "192 cm", "193 cm", "194 cm", "195 cm", "196 cm", "197 cm", "198 cm", "199 cm",
        "200 cm"
    ]

    private var dataSource = [
        150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
        160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
        170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
        180, 181, 182, 183, 184, 185, 186, 187, 188, 189,
        190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
        200
    ]

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
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

    lazy private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.layer.cornerRadius = RConfig.cornerRadius
        tableView.layer.masksToBounds = true
        tableView.separatorColor = .clear
        tableView.register(RegistrationSelectFieldCell.self, forCellReuseIdentifier: RegistrationSelectFieldCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
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
            make.bottom.equalTo(nextButton.snp.top).inset(-50)
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
        if (user?.height == nil) {
            return
        }

        if let index = dataSource.firstIndex(of: user!.height!) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    @objc private func didTapNextButton() {
        if (user?.height == nil) {
            toast(message: "키가 입력 되지 않았습니다.")
            return
        }
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationBodyTypeViewController")
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationBirthdayViewController", animated: false)
    }
}


extension RegistrationHeightViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataSource.count != labelSource.count) {
            fatalError("Please check the dataSource and labelSource..")
        }
        return dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationSelectFieldCell.identifier, for: indexPath) as! RegistrationSelectFieldCell
        let data = dataSource[indexPath.row]
        cell.textLabel?.text = labelSource[indexPath.row]
        cell.textLabel?.textAlignment = .center
        if data == user?.height {
            cell.select()
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationSelectFieldCell
        cell?.select()
        let value = dataSource[indexPath.row]
        user?.height = value
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationSelectFieldCell
        cell?.deselect()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
}
