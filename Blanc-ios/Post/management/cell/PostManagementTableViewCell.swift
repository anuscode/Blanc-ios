import Foundation
import UIKit

protocol PostManagementTableViewCellDelegate {
    func favorite(_ post: PostDTO?)
    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool
    func presentFavoriteUserListView(_ post: PostDTO?)
}

class PostManagementTableViewCell: UITableViewCell {

    static let identifier: String = "PostManagementTableViewCell"

    var delegate: PostManagementTableViewCellDelegate?

    let header: PostManagementHeader = {
        let header = PostManagementHeader()
        return header
    }()

    let body: PostManagementBody = {
        let body = PostManagementBody()
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
            make.height.equalTo(PostManagementHeader.Constant.headerHeight)
        }
        body.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func bind(post: PostDTO?, delegate: PostManagementTableViewCellDelegate? = nil) {
        header.bind(post: post)
        body.bind(post: post, delegate: delegate)
    }
}
