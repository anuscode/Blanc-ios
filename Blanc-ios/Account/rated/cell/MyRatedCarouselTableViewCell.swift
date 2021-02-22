import Foundation
import UIKit
import RxSwift
import FSPagerView

class MyRatedCarouselTableViewCell: UITableViewCell {

    static let identifier: String = "MyRatedCarouselTableViewCell"

    lazy private var carousel: FSPagerView = {
        let carousel = FSPagerView(frame: frame)
        carousel.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.delegate = self
        carousel.dataSource = self
        return carousel
    }()

    private var user: UserDTO?

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
    }

    private func configConstraints() {
        carousel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(carousel.snp.width)
        }
    }

    func bind(user: UserDTO?) {
        self.user = user
        DispatchQueue.main.async { [self] in
            carousel.reloadData()
        }
    }
}

extension MyRatedCarouselTableViewCell: FSPagerViewDataSource, FSPagerViewDelegate {
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
