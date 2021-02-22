import FirebaseAuth
import Foundation
import RxSwift
import SwinjectStoryboard
import TTGTagCollectionView
import UIKit

class IdealTypeViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var profileViewModel: ProfileViewModel?

    var userDTO: UserDTO?

    var selectedValues: [Int] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이상형을 입력하세요"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    private let collectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        return collectionView
    }()

    private let config: TTGTextTagConfig = {
        let config = TTGTextTagConfig()
        config.backgroundColor = .secondarySystemBackground
        config.cornerRadius = 5
        config.textColor = .black
        config.textFont = UIFont.systemFont(ofSize: 14)
        config.borderColor = .secondarySystemBackground
        config.shadowOpacity = 0
        config.selectedBackgroundColor = .bumble3
        config.selectedCornerRadius = 5
        config.selectedTextColor = .white
        config.exactHeight = 36
        config.extraSpace = CGSize(width: 20, height: 0)
        return config
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

        collectionView.delegate = self
        collectionView.addTags(UserGlobal.idealTypes, with: config)

        addSubviews()
        subscribeViewModel()
    }

    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        CGSize(width: 1, height: 1)
    }

    override func viewDidLayoutSubviews() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(FragmentConfig.verticalMargin)
        }

        collectionView.snp.makeConstraints { make in
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
            make.top.equalTo(collectionView.snp.bottom).inset(-FragmentConfig.confirmButtonMarginTop)
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
                .subscribe(onNext: { [self] userDTO in
                    self.userDTO = userDTO
                    initSelectedValues(userDTO.idealTypeIds)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(confirmButton)
        view.addSubview(loadingView)
        view.addSubview(collectionView)
    }

    @objc private func didTapConfirmButton() {
        userDTO?.idealTypeIds = selectedValues
        profileViewModel?.update()
    }

    private func initSelectedValues(_ indexes: [Int]?) {
        guard indexes != nil else {
            return
        }
        for index in indexes! {
            collectionView.setTagAt(UInt(index), selected: true)
        }
        selectedValues = indexes!
        activateConfirmButton()
    }

    private func addSelectedValue(_ index: Int) {
        selectedValues.append(index)
        activateConfirmButton()
    }

    private func addSelectedValue(_ index: UInt) {
        addSelectedValue(Int(index))
    }

    private func removeSelectedValue(_ index: Int) {
        selectedValues = selectedValues.filter({ $0 != index })
        activateConfirmButton()
    }

    private func removeSelectedValue(_ index: UInt) {
        removeSelectedValue(Int(index))
    }

    private func activateConfirmButton() {
        if selectedValues.count >= 3 {
            confirmButton.backgroundColor = .bumble3
        } else {
            confirmButton.backgroundColor = .lightGray
        }
    }
}

extension IdealTypeViewController: TTGTextTagCollectionViewDelegate {
    public func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!,
                                      didTapTag tagText: String!,
                                      at index: UInt,
                                      selected: Bool,
                                      tagConfig config: TTGTextTagConfig!) {
        if selected {
            addSelectedValue(index)
        } else {
            removeSelectedValue(index)
        }
    }
}