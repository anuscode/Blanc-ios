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


class HeightViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var profileViewModel: ProfileViewModel?

    var userDTO: UserDTO?

    var selectedValue: Int?

    var labelSource = ["150 cm", "151 cm", "152 cm", "153 cm", "154 cm", "155 cm", "156 cm", "157 cm", "158 cm", "159 cm",
                       "160 cm", "161 cm", "162 cm", "163 cm", "164 cm", "165 cm", "166 cm", "167 cm", "168 cm", "169 cm",
                       "170 cm", "171 cm", "172 cm", "173 cm", "174 cm", "175 cm", "176 cm", "177 cm", "178 cm", "179 cm",
                       "180 cm", "181 cm", "182 cm", "183 cm", "184 cm", "185 cm", "186 cm", "187 cm", "188 cm", "189 cm",
                       "190 cm", "191 cm", "192 cm", "193 cm", "194 cm", "195 cm", "196 cm", "197 cm", "198 cm", "199 cm",
                       "200 cm"]
    var dataSource = [150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
                      160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
                      170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
                      180, 181, 182, 183, 184, 185, 186, 187, 188, 189,
                      190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
                      200]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "키를 입력하세요"
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
                    setInitialValue(userDTO.height)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(confirmButton)
        view.addSubview(loadingView)
        view.addSubview(tableView)
    }

    @objc private func didTapConfirmButton() {
        userDTO?.height = selectedValue
        profileViewModel?.update()
    }

    private func setInitialValue(_ height: Int?) {
        guard height != nil else {
            return
        }
        let index = dataSource.firstIndex(of: height!)
        let indexPath = IndexPath(row: index!, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    private func selectValue(_ height: Int?) {
        selectedValue = height
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

extension HeightViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataSource.count != labelSource.count) {
            fatalError("Please check the dataSource and labelSource..")
        }
        return dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectFieldCell.identifier, for: indexPath) as! SelectFieldCell
        let data = dataSource[indexPath.row]
        cell.textLabel?.text = labelSource[indexPath.row]
        if data == selectedValue {
            cell.select()
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.select()
        let value = dataSource[indexPath.row]
        selectValue(value)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SelectFieldCell
        cell?.deselect()
    }
}
