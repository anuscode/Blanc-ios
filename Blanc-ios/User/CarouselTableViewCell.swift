import Foundation
import UIKit
import RxSwift
import FSPagerView

class CarouselTableViewCell: UITableViewCell {

    static let identifier: String = "CarouselCell"

    lazy private var carousel: FSPagerView = {
        let carousel = FSPagerView(frame: frame)
        carousel.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.delegate = self
        carousel.dataSource = self
        return carousel
    }()

    private let label1: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.text = "용구쇼핑, 35"
        return label
    }()

    private let label2: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.text = "서울특별시 · 1km"
        return label
    }()

    let gradientView: GradientView = {
        let alpha0 = UIColor.userCardGradientBlack.withAlphaComponent(0)
        let alpha1 = UIColor.userCardGradientBlack.withAlphaComponent(0.8)
        let gradient = GradientView(colors: [alpha0, alpha1], locations: [0.0, 1.0])
        return gradient
    }()

    private weak var user: UserDTO?

    private var homeViewModel: HomeViewModel?

    private var pageControl: FSPageControl = {
        let pageControl = FSPageControl()
        pageControl.contentHorizontalAlignment = .right
        return pageControl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        configConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func addSubviews() {
        contentView.addSubview(carousel)
        contentView.addSubview(pageControl)
        contentView.addSubview(gradientView)
        contentView.addSubview(label1)
        contentView.addSubview(label2)
    }

    private func configConstraints() {

        let window = UIApplication.shared.keyWindow
        var topPadding = window?.safeAreaInsets.top ?? 0
        topPadding = topPadding + (topPadding == 0 ? 20 : 5)

        carousel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(carousel.snp.width)
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(topPadding)
            make.trailing.equalToSuperview().inset(20)
        }

        label1.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(label2.snp.top).inset(-5)
        }

        label2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(carousel.snp.bottom).inset(10)
        }

        gradientView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(carousel.snp.bottom)
            make.height.equalTo(100)
        }
    }

    func bind(user: UserDTO?) {
        self.user = user
        pageControl.numberOfPages = user?.userImages?.count ?? 0
        carousel.reloadData()
        label1.text = "\(self.user?.nickName ?? "알 수 없음"), \(user?.age ?? -1)"
        label2.text = "\(self.user?.area ?? "알 수 없음") · \(user?.distance ?? "알 수 없음")"
    }
}

extension CarouselTableViewCell: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        user?.userImages?.count ?? 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        guard (user?.userImages != nil || user?.userImages?.count ?? 0 > 0) else {
            return cell
        }
        cell.imageView?.url(user?.userImages![index].url)
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
}
