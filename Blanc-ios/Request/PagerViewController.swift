import UIKit
import Parchment
import FSPagerView

extension UIView {
    func constrainToEdges(_ subview: UIView) {

        subview.translatesAutoresizingMaskIntoConstraints = false

        let topContraint = NSLayoutConstraint(
                item: subview,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: 0)

        let bottomConstraint = NSLayoutConstraint(
                item: subview,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0)

        let leadingContraint = NSLayoutConstraint(
                item: subview,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1.0,
                constant: 0)

        let trailingContraint = NSLayoutConstraint(
                item: subview,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1.0,
                constant: 0)

        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
}

class PagerViewController: UIViewController {

    private let fireworkController = ClassicFireworkController()

    private var titles: [String] = ["받은 요청", "받은 관심", "보낸 관심"]

    var rightSideBarView: RightSideBarView?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "요청"))
    }()

    lazy private var rightBarButtonItem: UIBarButtonItem = {
        guard (rightSideBarView != nil) else {
            return UIBarButtonItem()
        }
        rightSideBarView!.delegate {
            self.navigationController?.pushAlarmViewController(current: self)
        }
        return UIBarButtonItem(customView: rightSideBarView!)
    }()

    lazy private var viewControllers: [UIViewController] = {
        [receivedViewController, sendingViewController]
    }()

    lazy private var labels: [UILabel] = {
        let labels = [titleLabel1, titleLabel2]
        return labels
    }()

    lazy private var titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "받음"
        label.font = .boldSystemFont(ofSize: 25)
        label.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTitleLabel1))
        label.isUserInteractionEnabled = false
        return label
    }()

    lazy private var underLine1: UIView = {
        let view = UIView()
        view.backgroundColor = .bumble1
        return view
    }()

    lazy private var titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "보냄"
        label.textColor = .systemGray3
        label.font = .systemFont(ofSize: 25)
        label.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTitleLabel2))
        return label
    }()

    lazy private var underLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    lazy private var guideLine: UIView = {
        let view = UIView()
        return view
    }()

    lazy private var pageViewController: PageViewController = {
        let pageViewController = PageViewController()
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.selectViewController(viewControllers[0], direction: .none)
        pageViewController.didMove(toParent: self)
        pageViewController.scrollView.isScrollEnabled = false
        return pageViewController
    }()

    lazy private var receivedViewController: ReceivedViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
                withIdentifier: "ReceivedViewController") as! ReceivedViewController
        vc.pushUserSingleViewController = {
            self.navigationController?.pushUserSingleViewController(current: self)
        }
        return vc
    }()

    lazy private var sendingViewController: SendingViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
                withIdentifier: "SendingViewController") as! SendingViewController
        vc.pushUserSingleViewController = {
            self.navigationController?.pushUserSingleViewController(current: self)
        }
        return vc
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    override func viewDidLoad() {
        configureChildren()
        configureSubviews()
        configureConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureChildren() {
        addChild(pageViewController)
    }

    private func configureSubviews() {
        view.addSubview(guideLine)
        view.addSubview(titleLabel1)
        view.addSubview(underLine1)
        view.addSubview(titleLabel2)
        view.addSubview(underLine2)
        view.addSubview(pageViewController.view)
    }

    private func configureConstraints() {

        guideLine.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
        }

        titleLabel1.snp.makeConstraints { make in
            make.bottom.equalTo(guideLine.snp.top)
            make.leading.equalToSuperview().inset(15)
        }

        underLine1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel1.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel1.snp.leading)
            make.trailing.equalTo(titleLabel1.snp.trailing)
            make.height.equalTo(3)
        }

        titleLabel2.snp.makeConstraints { make in
            make.bottom.equalTo(guideLine.snp.top)
            make.leading.equalTo(titleLabel1.snp.trailing).offset(10)
        }

        underLine2.snp.makeConstraints { make in
            make.top.equalTo(titleLabel2.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel2.snp.leading)
            make.trailing.equalTo(titleLabel2.snp.trailing)
            make.height.equalTo(3)
        }

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(titleLabel1.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func didTapTitleLabel1() {
        titleLabel1.textColor = .black
        titleLabel1.font = .boldSystemFont(ofSize: 25)
        titleLabel1.isUserInteractionEnabled = false
        underLine1.backgroundColor = .bumble2

        titleLabel2.textColor = .systemGray3
        titleLabel2.font = .systemFont(ofSize: 25)
        titleLabel2.isUserInteractionEnabled = true
        underLine2.backgroundColor = .clear
        pageViewController.selectViewController(receivedViewController, direction: .reverse)

        fireworkController.addFireworks(count: 2, around: titleLabel1)
    }

    @objc private func didTapTitleLabel2() {
        titleLabel2.textColor = .black
        titleLabel2.font = .boldSystemFont(ofSize: 25)
        titleLabel2.isUserInteractionEnabled = false
        underLine2.backgroundColor = .bumble2

        titleLabel1.textColor = .systemGray3
        titleLabel1.font = .systemFont(ofSize: 25)
        titleLabel1.isUserInteractionEnabled = true
        underLine1.backgroundColor = .clear
        pageViewController.selectViewController(sendingViewController, direction: .forward)

        fireworkController.addFireworks(count: 2, around: titleLabel2)
    }
}

extension PagerViewController: PageViewControllerDataSource {
    func pageViewController(_ pageViewController: PageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        if index > 0 {
            return viewControllers[index - 1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: PageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        if index < viewControllers.count - 1 {
            return viewControllers[index + 1]
        }
        return nil
    }
}

extension PagerViewController: PageViewControllerDelegate {
    func pageViewController(_ pageViewController: PageViewController,
                            willStartScrollingFrom startingViewController: UIViewController,
                            destinationViewController: UIViewController) {
    }

    func pageViewController(_ pageViewController: PageViewController,
                            isScrollingFrom startingViewController: UIViewController,
                            destinationViewController: UIViewController?,
                            progress: CGFloat) {
    }

    func pageViewController(_ pageViewController: PageViewController,
                            didFinishScrollingFrom startingViewController: UIViewController,
                            destinationViewController: UIViewController,
                            transitionSuccessful: Bool) {
    }
}
