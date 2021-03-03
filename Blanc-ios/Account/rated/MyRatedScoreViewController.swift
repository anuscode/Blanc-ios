import Foundation
import UIKit
import RxSwift
import FSPagerView
import TTGTagCollectionView
import SwinjectStoryboard

class MyRatedScoreViewController: UIViewController {

    private class Const {
        static let navigationUserImageSize: Int = 28
        static let navigationUserLabelFont: UIFont = .systemFont(ofSize: 15)
        static let navigationUserImageCornerRadius: Int = {
            Const.navigationUserImageSize / 2
        }()
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    private let sections: [String] = ["CAROUSEL", "PROFILE", "RATERS"]

    private var data: MyRatedData?

    var myRatedScoreViewModel: MyRatedScoreViewModel?

    lazy private var navigationBarContent: UIView = {
        let view = UIView()
        view.addSubview(navigationUserImage)
        view.addSubview(navigationUserLabel)
        navigationUserImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(Const.navigationUserImageSize)
            make.height.equalTo(Const.navigationUserImageSize)
        }
        navigationUserLabel.snp.makeConstraints { make in
            make.leading.equalTo(navigationUserImage.snp.trailing).inset(-10)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        return view
    }()

    lazy private var navigationUserImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy private var navigationUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.font = Const.navigationUserLabelFont
        return label
    }()

    lazy private var tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyRatedCarouselTableViewCell.self, forCellReuseIdentifier: MyRatedCarouselTableViewCell.identifier)
        tableView.register(MyRatedProfileTableViewCell.self, forCellReuseIdentifier: MyRatedProfileTableViewCell.identifier)
        tableView.register(MyRatedSmallUserProfileTableViewCell.self, forCellReuseIdentifier: MyRatedSmallUserProfileTableViewCell.identifier)
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        return tableView
    }()

    override var prefersStatusBarHidden: Bool {
        navigationController?.isNavigationBarHidden == true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        UIStatusBarAnimation.slide
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.titleView = navigationBarContent
//        // navigationBarContent.alpha = 0
        navigationUserLabel.visible(false)
        navigationUserImage.visible(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeMyRatedScoreViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwinjectStoryboard.defaultContainer.resetObjectScope(.myRatedScoreScope)
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        navigationController?.navigationBar.addSubview(navigationBarContent)
    }

    private func configureConstraints() {
        let window = UIApplication.shared.windows[0]
        tableView.frame = CGRect(x: 0, y: 0, width: view.width,
                height: view.height - CGFloat(0) - window.safeAreaInsets.bottom)
    }

    private func subscribeMyRatedScoreViewModel() {
        myRatedScoreViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] data in
                    self.data = data
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}

extension MyRatedScoreViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return data?.raters?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if (section != 2) {
            return UIView()
        }

        let view = UIView()
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "평가자들"
        label.font = .boldSystemFont(ofSize: 22)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section != 2) {
            return CGFloat.leastNormalMagnitude
        } else {
            return UITableView.automaticDimension
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return view.width
        } else if indexPath.section == 1 {
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {  /** Carousel **/
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyRatedCarouselTableViewCell.identifier,
                    for: indexPath) as! MyRatedCarouselTableViewCell
            cell.bind(user: data?.currentUser)
            return cell
        } else if indexPath.section == 1 {  /** Score **/
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyRatedProfileTableViewCell.identifier,
                    for: indexPath) as! MyRatedProfileTableViewCell
            cell.bind(data?.currentUser)
            return cell
        } else {  /** Raters **/
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: MyRatedSmallUserProfileTableViewCell.identifier,
                    for: indexPath) as! MyRatedSmallUserProfileTableViewCell
            cell.bind(rater: data?.raters?[indexPath.row])
            return cell
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximum = view.width - 80
        let y: CGFloat = min(scrollView.contentOffset.y, maximum)
        let percent = y / maximum
        navigationController?.navigationBar.isTranslucent = percent < 0.05 ? true : false
        navigationController?.navigationBar.alpha = percent < 0.05 ? 100 : percent
        navigationBarContent.alpha = percent < 0.05 ? 0 : percent
        if (navigationUserImage.isHidden || navigationUserLabel.isHidden) {
            navigationUserLabel.visible(true)
            navigationUserImage.visible(true)
        }
    }
}


