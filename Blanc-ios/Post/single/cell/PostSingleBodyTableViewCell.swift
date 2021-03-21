import Foundation
import UIKit
import FSPagerView

protocol PostSingleTableViewCellDelegate: class {
    func favorite()
    func isFavoritePost() -> Bool
}

class PostSingleBodyTableViewCell: UITableViewCell {

    static let identifier: String = "PostSingleBodyTableViewCell"

    private weak var delegate: PostSingleTableViewCellDelegate?

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
        addSubviews()
        configConstraints()
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

    private func addSubviews() {
        contentView.addSubview(header)
        contentView.addSubview(body)
    }

    private func configConstraints() {
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

    func bind(post: PostDTO?, delegate: PostSingleTableViewCellDelegate) {
        header.bind(user: post?.author)
        body.bind(post: post, delegate: delegate)
    }
}
