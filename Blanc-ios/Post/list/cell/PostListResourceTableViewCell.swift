import Foundation
import UIKit


class PostListResourceTableViewCell: UITableViewCell {

    static let identifier: String = "PostListResourceTableViewCell"

    private weak var delegate: PostBodyDelegate?

    lazy private var header: PostListHeader = {
        let header = PostListHeader()
        return header
    }()

    lazy private var body: PostListBody = {
        let body = PostListBody()
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
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(body.snp.top)
            make.height.equalTo(PostListHeader.Constant.headerHeight)
        }
        body.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func bind(post: PostDTO?,
              headerDelegate: PostListHeaderDelegate? = nil,
              bodyDelegate: PostBodyDelegate? = nil) {
        header.bind(post: post, delegate: headerDelegate)
        body.bind(post: post, delegate: bodyDelegate)
    }
}