import UIKit
import Moya
import RxSwift
import Foundation
import SwinjectStoryboard

class SendingViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var dataSource: UICollectionViewDiffableDataSource<Section, UserDTO>!

    internal weak var sendingViewModel: SendingViewModel?

    internal var pushUserSingleViewController: (() -> Void)?

    private var users: [UserDTO] = []

    lazy private var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        return layout
    }()

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        collectionView.register(UserCollectionViewCell.self,
            forCellWithReuseIdentifier: UserCollectionViewCell.identifier
        )
        collectionView.register(SendingHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SendingHeaderReusableView.identifier
        )
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView(animationName: "girl_with_phone", animationSpeed: 1)
        emptyView.primaryText = "아직 관심을 준 상대가 없습니다."
        emptyView.secondaryText = "내가 4점 이상 점수를 준 사람들이\n이곳에 표시 됩니다."
        emptyView.buttonText = "메인 화면으로"
        emptyView.didTapButtonDelegate = { [unowned self] in
            self.tabBarController?.selectedIndex = 0
        }
        emptyView.visible(false)
        return emptyView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        if (!emptyView.isHidden) {
            emptyView.play()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureSubviews()
        configureConstraints()
        subscribeRatingViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func configureSubviews() {
        view.addSubview(collectionView)
        view.addSubview(emptyView)
    }

    private func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    private func subscribeRatingViewModel() {
        sendingViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] users in
                self.users = users
                update(users: users)
            })
            .disposed(by: disposeBag)

        sendingViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ users in users.count == 0 })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] boolean in
                emptyView.visible(boolean)
            })
            .disposed(by: disposeBag)
    }
}

extension SendingViewController {

    fileprivate enum Section {
        case main
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Section, UserDTO>(collectionView: collectionView) { [unowned self] (collectionView, indexPath, user) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.identifier, for: indexPath) as! UserCollectionViewCell
            cell.bind(user)
            return cell
        }
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: SendingHeaderReusableView.identifier, for: indexPath
            ) as? SendingHeaderReusableView {
                header.bind("내가 관심을 보냄")
                return header
            } else {
                fatalError("Cannot create new supplementary")
            }
        }
        collectionView.dataSource = dataSource
    }

    private func update(users: [UserDTO]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserDTO>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension SendingViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let user = users[index]
        Channel.next(user: user)
        pushUserSingleViewController?()
    }
}

extension SendingViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.size.width, height: 41.66666793823242)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = flowLayout.minimumInteritemSpacing
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: itemDimension + 43)
    }
}
