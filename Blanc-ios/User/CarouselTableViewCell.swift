import Foundation
import UIKit
import RxSwift
import FSPagerView

class CarouselTableViewCell: UITableViewCell {

    static let identifier: String = "CarouselTableViewCell"

    private weak var user: UserDTO?

    private let carouselCellIdentifier = "CarouselCell"

    lazy private var carousel: FSPagerView = {
        let carousel = FSPagerView(frame: frame)
        carousel.register(FSPagerViewCell.self, forCellWithReuseIdentifier: carouselCellIdentifier)
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.delegate = self
        carousel.dataSource = self
        return carousel
    }()

    private let label1: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()

    private let label2: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()

    private let gradientView: GradientView = {
        let alpha0 = UIColor.userCardGradientBlack.withAlphaComponent(0)
        let alpha1 = UIColor.userCardGradientBlack.withAlphaComponent(0.8)
        let gradient = GradientView(colors: [alpha0, alpha1], locations: [0.0, 1.0])
        return gradient
    }()

    private var pageControl: FSPageControl = {
        let pageControl = FSPageControl()
        pageControl.contentHorizontalAlignment = .right
        return pageControl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureSubviews() {
        contentView.addSubview(carousel)
        contentView.addSubview(pageControl)
        contentView.addSubview(gradientView)
        contentView.addSubview(label1)
        contentView.addSubview(label2)
    }

    private func configureConstraints() {

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

        let line1 = "\(self.user?.nickname ?? "알 수 없음"), \(user?.age ?? -1)"
        let line2 = "\(self.user?.area ?? "알 수 없음") · \(user?.relationship?.distance ?? "알 수 없음")"
        let numberOfPages = user?.userImages?.count ?? 0

        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        label1.text = line1
        label2.text = line2
        carousel.reloadData()
    }
}

extension CarouselTableViewCell: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        user?.userImages?.count ?? 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: carouselCellIdentifier, at: index)
        guard (user?.userImages != nil || user?.userImages?.count ?? 0 > 0) else {
            return cell
        }
        cell.imageView?.url(user?.userImages?[index].url)
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }

    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        false
    }
}
