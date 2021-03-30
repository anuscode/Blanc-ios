import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationSmokingViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal weak var registrationViewModel: RegistrationViewModel?

    private weak var user: UserDTO?

    private var dataSource: [String] = {
        UserGlobal.smokings
    }()

    lazy private var starFallView: StarFallView = {
        let view = StarFallView(layerTransparency: 0.5)
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .secondarySystemBackground
        progress.progressTintColor = .black
        progress.progress = 10 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "흡연"
        label.font = .boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - RConfig.horizontalMargin * 2)
        layout.itemSize = CGSize(width: cellWidth, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }()

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.register(
            SelectionCollectionViewCell.self,
            forCellWithReuseIdentifier: SelectionCollectionViewCell.identifier
        )

        let cellIdentifier = SelectionCollectionViewCell.identifier
        let cellType = SelectionCollectionViewCell.self

        Observable
            .just(dataSource)
            .bind(to: collectionView.rx.items(
                cellIdentifier: cellIdentifier,
                cellType: cellType
            )) { (row, item, cell) in
                let isSelectedRow = (row == self.user?.smokingId)
                let text = item

                cell.subject.text = text
                if (isSelectedRow) {
                    self.collectionView.selectItem(
                        at: IndexPath(row: row, section: 0),
                        animated: false,
                        scrollPosition: .init(rawValue: 0)
                    )
                }
                cell.select(isSelectedRow)
            }
            .disposed(by: disposeBag)

        // deselect is triggered before triggering selected event.
        Observable
            .zip(collectionView.rx.itemDeselected,
                collectionView.rx.modelDeselected(String.self))
            .bind { (indexPath, model) in
                self.user?.smokingId = nil
                self.collectionView.reloadItems(at: [indexPath])
            }
            .disposed(by: disposeBag)

        // selected will be triggered after deselect callback done.
        Observable
            .zip(collectionView.rx.itemSelected,
                collectionView.rx.modelSelected(String.self))
            .bind { (indexPath, model) in
                self.user?.smokingId = indexPath.row
                self.collectionView.reloadItems(at: [indexPath])
            }
            .disposed(by: disposeBag)

        return collectionView
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let top = titleLabel.frame.origin.y + titleLabel.height
        let bottom = nextButton.frame.origin.y
        let allowedHeight = CGFloat(bottom - top) - 40
        let idealHeight = CGFloat(60 * dataSource.count + 40)
        let height = allowedHeight > idealHeight ? idealHeight : allowedHeight
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(height)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }

    deinit {
        log.info("deinit registration smoking view controller..")
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
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

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(collectionView.snp.bottom).offset(RConfig.noticeTopMargin)
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
                collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapNextButton() {
        if (user?.smokingId == nil) {
            toast(message: "흡연이 입력 되지 않았습니다.")
            return
        }
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegistrationBloodTypeViewController")
        navigationController?.pushViewController(vc, animated: true)
        if let index = navigationController?.viewControllers.firstIndex(of: self) {
            navigationController?.viewControllers.remove(at: index)
        }
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationDrinkViewController", animated: false)
    }
}