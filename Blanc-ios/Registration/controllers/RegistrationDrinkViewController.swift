import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationDrinkViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    var dataSource: [String] = {
        UserGlobal.drinks
    }()

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 9 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "주량"
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
                let isSelectedRow = (row == self.user?.drinkId)
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
                self.user?.drinkId = nil
                self.collectionView.reloadItems(at: [indexPath])
            }
            .disposed(by: disposeBag)

        // selected will be triggered after deselect callback done.
        Observable
            .zip(collectionView.rx.itemSelected,
                collectionView.rx.modelSelected(String.self))
            .bind { (indexPath, model) in
                self.user?.drinkId = indexPath.row
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
        view.backgroundColor = .white
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
        registrationViewModel?.observe()
            .take(1)
            .subscribe(onNext: { user in
                self.user = user
                self.collectionView.reloadData()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapNextButton() {
        if (user?.drinkId == nil) {
            toast(message: "주량이 입력 되지 않았습니다.")
            return
        }
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationSmokingViewController")
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationReligionViewController", animated: false)
    }
}