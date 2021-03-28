import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Kingfisher
import Lottie


class PostViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var dataSource: UICollectionViewDiffableDataSource<Section, PostDTO>!

    private var posts: [PostDTO] = []

    private var isOpened: Bool = false

    private var division: Int = 10

    private var reminder: Int = 0

    internal weak var postViewModel: PostViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "그램"))
    }()

    lazy private var collectionViewLayout: InstagramGridLayout = {
        let layout = InstagramGridLayout()
        layout.scrollDirection = .vertical
        layout.delegate = self
        layout.itemSpacing = 1
        layout.fixedDivisionCount = 3
        return layout
    }()

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .white
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.delegate = self
        return collectionView
    }()

    lazy private var fab: UIView = {

        let container = UIView()
        container.width(50)
        container.height(50)
        container.applyShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.black, radius: 2.0, opacity: 0.35)

        let view = UIView()
        view.backgroundColor = .tinderPink
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 25
        view.isUserInteractionEnabled = true
        view.width(50)
        view.height(50)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFloatingActionButton))
        ripple.activate(to: view)

        let pencil = UIImageView()
        pencil.clipsToBounds = true
        pencil.contentMode = .scaleAspectFill
        let image = UIImage(systemName: "pencil")
        pencil.image = image
        pencil.tintColor = .white

        let plus = UIImageView()
        plus.contentMode = .scaleAspectFill
        plus.image = UIImage(systemName: "plus")
        plus.tintColor = .white

        container.addSubview(view)
        view.addSubview(pencil)
        view.addSubview(plus)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pencil.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(35)
            make.width.equalTo(35)
        }
        plus.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(0.65)
            make.centerY.equalToSuperview().multipliedBy(0.65)
            make.height.equalTo(15)
            make.width.equalTo(15)
        }
        return container
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .secondarySystemBackground
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationController?.navigationBar.barTintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureSubviews()
        configureConstraints()
        subscribePostViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (isOpened) {
            didTapFloatingActionButton()
        }
    }

    deinit {
        log.info("deinit post view controller..")
    }

    private func configureSubviews() {
        view.addSubview(collectionView)
        view.addSubview(fab)
    }

    private func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fab.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func subscribePostViewModel() {
        postViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] posts in
                self.posts = posts
                update()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    @objc func didTapFloatingActionButton() {
        navigationController?.pushViewController(.postCreate, current: self)
    }
}

extension PostViewController {

    fileprivate enum Section {
        case main
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Section, PostDTO>(collectionView: collectionView) { [unowned self] (collectionView, indexPath, post) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as! PostCollectionViewCell
            let index = indexPath.row
            let isLargeScale: Bool = (index % division == reminder && !post.isTextOnly())
            cell.bind(post, isLargeScale: isLargeScale)
            return cell
        }
        collectionView.dataSource = dataSource
    }

    private func update() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostDTO>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension PostViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "PostListViewController") as! PostListViewController
        vc.scrollToRow = indexPath.row
        vc.prepare()
        navigationController?.pushViewController(vc, current: self)
    }
}

extension PostViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        if (indexPath.row == posts.count - 10) {
            postViewModel?.populate()
        }
    }
}

extension PostViewController: GridLayoutDelegate {
    func scaleForItem(inCollectionView collectionView: UICollectionView,
                      withLayout layout: UICollectionViewLayout,
                      atIndexPath indexPath: IndexPath) -> UInt {
        let index = indexPath.row
        let post = posts[index]
        return (index % division == reminder && !post.isTextOnly()) ? 2 : 1
    }

    func itemFlexibleDimension(inCollectionView collectionView: UICollectionView,
                               withLayout layout: UICollectionViewLayout,
                               fixedDimension: CGFloat) -> CGFloat {
        fixedDimension
    }
}