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

    var postViewModel: PostViewModel?

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
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
        view.width(40)
        view.height(40)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFloatingActionButton))
        ripple.activate(to: view)

        let imageView = UIImageView(image: UIImage(named: "ic_menu"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalTo(25)
        }
        return view
    }()

    lazy private var fab1: UIView = {

        let view = UIView()
        view.visible(false)

        let circleView = UIView()
        circleView.backgroundColor = .white
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = 20
        circleView.width(40)
        circleView.height(40)
        circleView.isUserInteractionEnabled = true
        circleView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFloatingActionButton1))
        ripple.activate(to: circleView)

        let imageView = UIImageView(image: UIImage(named: "ic_history_navy"))
        imageView.rotate(withDuration: 2, infinite: true)
        circleView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalTo(25)
        }

        let textView = UIView()
        textView.layer.cornerRadius = 4
        textView.layer.masksToBounds = true
        textView.backgroundColor = .white

        let label = UILabel()
        label.text = "지난 게시물 관리"
        label.font = .systemFont(ofSize: 11)

        textView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(7)
            make.trailing.equalToSuperview().inset(7)
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
        }

        view.addSubview(circleView)
        view.addSubview(textView)

        circleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(circleView.snp.leading).inset(-10)
            make.centerY.equalToSuperview()
        }

        return view
    }()

    lazy private var fab2: UIView = {

        let view = UIView()
        view.visible(false)

        let circleView = UIView()
        circleView.backgroundColor = .white
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = 20
        circleView.width(40)
        circleView.height(40)
        circleView.isUserInteractionEnabled = true
        circleView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFloatingActionButton2))
        ripple.activate(to: circleView)

        circleView.addSubview(fab2LottieView)
        fab2LottieView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalTo(25)
        }

        let textView = UIView()
        textView.layer.cornerRadius = 4
        textView.layer.masksToBounds = true
        textView.backgroundColor = .white

        let label = UILabel()
        label.text = "게시물 작성"
        label.font = .systemFont(ofSize: 11)

        textView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(7)
            make.trailing.equalToSuperview().inset(7)
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
        }

        view.addSubview(circleView)
        view.addSubview(textView)

        circleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(circleView.snp.leading).inset(-10)
            make.centerY.equalToSuperview()
        }

        return view
    }()

    lazy private var fab2LottieView: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("cloud_upload_black")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        return animationView
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

    private func configureSubviews() {
        view.addSubview(collectionView)
        view.addSubview(fab2)
        view.addSubview(fab1)
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

        fab1.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        fab2.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func subscribePostViewModel() {
        postViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { posts in
                    self.posts = posts
                    self.update()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    @objc func didTapFloatingActionButton() {
        if (isOpened) {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: { [self] in
                fab1.transform = CGAffineTransform(translationX: 0, y: 0)
                fab2.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { [unowned self] _ in
                fab1.visible(false)
                fab2.visible(false)
                fab2LottieView.stop()
            })
        } else {
            fab1.visible(true)
            fab2.visible(true)
            fab2LottieView.play()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: { [self] in
                fab1.transform = CGAffineTransform(translationX: 0, y: -100)
                fab2.transform = CGAffineTransform(translationX: 0, y: -50)
            })
        }
        isOpened = !isOpened
    }

    @objc func didTapFloatingActionButton1() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
                withIdentifier: "PostManagementViewController") as! PostManagementViewController
        vc.prepare()
        navigationController?.pushViewController(vc, current: self)
    }

    @objc func didTapFloatingActionButton2() {
        navigationController?.pushViewController(.postCreate, current: self)
    }
}

extension PostViewController {

    fileprivate enum Section {
        case main
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Section, PostDTO>(collectionView: collectionView) { [self] (collectionView, indexPath, post) -> UICollectionViewCell? in
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
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
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
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == posts.count - 10) {
            log.info("loading more posts..")
            postViewModel?.populate()
        }
    }
}

extension PostViewController: GridLayoutDelegate {
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        let index = indexPath.row
        let post = posts[index]
        return (index % division == reminder && !post.isTextOnly()) ? 2 : 1
    }

    func itemFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        fixedDimension
    }
}