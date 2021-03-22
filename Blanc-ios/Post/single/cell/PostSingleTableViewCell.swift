import Foundation
import UIKit
import FSPagerView

class PostSingleTableViewCell: UITableViewCell {

    static let identifier: String = "PostSingleTableViewCell"

    private weak var delegate: PostSingleBodyDelegate?

    private let header: PostSingleHeader = {
        let header = PostSingleHeader()
        return header
    }()

    private let body: PostSingleBody = {
        let body = PostSingleBody()
        return body
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

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func configureSubviews() {
        contentView.addSubview(header)
        contentView.addSubview(body)
    }

    private func configureConstraints() {
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(body.snp.top)
            make.height.equalTo(PostListHeader.Constant.headerHeight)
        }
        body.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func bind(post: PostDTO?, headerDelegate: PostSingleHeaderDelegate? = nil, bodyDelegate: PostSingleBodyDelegate) {
        header.bind(post: post, delegate: headerDelegate)
        body.bind(post: post, delegate: bodyDelegate)
    }
}
