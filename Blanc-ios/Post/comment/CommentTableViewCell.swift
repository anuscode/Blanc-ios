import Foundation
import UIKit


protocol CommentTableViewCellDelegate: class {
    func thumbUp(comment: CommentDTO?) -> Void
    func thumbDown(comment: CommentDTO?) -> Void

    func isThumbedUp(comment: CommentDTO?) -> Bool
    func isThumbedDown(comment: CommentDTO?) -> Bool

    func isAuthorFavoriteComment(comment: CommentDTO?) -> Bool

    func reply(comment: CommentDTO?) -> Void
}

class CommentTableViewCell: UITableViewCell {

    static let identifier: String = "CommentTableViewCell"

    private let ripple: Ripple = Ripple()

    private class Const {
        static let imageDiameter: CGFloat = CGFloat(35)
    }

    private weak var comment: CommentDTO?

    private weak var delegate: CommentTableViewCellDelegate?

    lazy private var thumbUpEmpty: UIImage? = {
        UIImage(named: "ic_thumb_up_empty")
    }()

    lazy private var thumbUpFilled: UIImage? = {
        UIImage(named: "ic_thumb_up_filled")
    }()

    lazy private var thumbDownEmpty: UIImage? = {
        UIImage(named: "ic_thumb_down_empty")
    }()

    lazy private var thumbDownFilled: UIImage? = {
        UIImage(named: "ic_thumb_down_filled")
    }()

    lazy private var content: UIView = {
        let view = UIView()
        return view
    }()

    lazy private var frontMargin: UIView = {
        let view = UIView()
        return view
    }()

    lazy private var userImage: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.layer.cornerRadius = Const.imageDiameter / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy private var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    lazy private var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            thumbUpImageContainer, thumbUpCount, thumbDownImageContainer, thumbDownCount, replyView
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        return stackView
    }()

    lazy private var thumbUpImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        view.isUserInteractionEnabled = true
        view.width(25, priority: 800)
        view.height(25, priority: 800)

        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapThumbUpImageView))

        view.addSubview(thumbUpImageView)
        thumbUpImageView.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var thumbDownImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        view.isUserInteractionEnabled = true
        view.width(25, priority: 800)
        view.height(25, priority: 800)

        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapThumbDownImageView))

        view.addSubview(thumbDownImageView)
        thumbDownImageView.snp.makeConstraints { make in
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var thumbUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy private var thumbDownImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy private var thumbUpCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.width(15, priority: 800)
        label.height(25, priority: 800)
        return label
    }()

    lazy private var thumbDownCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.width(15, priority: 800)
        label.height(25, priority: 800)
        return label
    }()

    lazy private var authorFavoriteCommentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            authorFavoriteCommentLabel, heartImageView
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.setCustomSpacing(8, after: authorFavoriteCommentLabel)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: CGFloat(3), left: 0, bottom: 0, right: 0)
        return stackView
    }()

    lazy private var authorFavoriteCommentLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "작성자가 이 댓글을 좋아합니다!"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.visible(false)
        return label
    }()

    lazy private var heartImageView: UIImageView = {
        var imageView = UIImageView(image: UIImage(named: "ic_heart_red"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.width(10, priority: 800)
        imageView.height(10, priority: 800)
        imageView.visible(false)
        return imageView
    }()

    lazy private var replyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5

        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapReplyView))

        let label = UILabel()
        label.text = "답글 달기"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(50)
        }
        return view
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
        contentView.addSubview(content)
        content.addSubview(frontMargin)
        content.addSubview(userImage)
        content.addSubview(nicknameLabel)
        content.addSubview(dateLabel)
        content.addSubview(commentLabel)
        content.addSubview(authorFavoriteCommentStackView)
        content.addSubview(buttonsStackView)
    }

    private func configureConstraints() {

        content.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(15)
        }

        userImage.snp.makeConstraints { make in
            make.leading.equalTo(frontMargin.snp.trailing)
            make.top.equalToSuperview()
            make.width.equalTo(Const.imageDiameter)
            make.height.equalTo(Const.imageDiameter)
        }

        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-11)
            make.top.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(nicknameLabel.snp.trailing).inset(-8)
            make.top.equalTo(nicknameLabel.snp.top)
            make.bottom.equalTo(nicknameLabel.snp.bottom)
        }

        commentLabel.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-11)
            make.top.equalTo(nicknameLabel.snp.bottom).inset(-1)
            make.trailing.equalToSuperview().inset(10)
        }

        authorFavoriteCommentStackView.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-11)
            make.top.equalTo(commentLabel.snp.bottom)
            make.bottom.equalTo(buttonsStackView.snp.top)
        }

        buttonsStackView.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-8)
            make.top.equalTo(authorFavoriteCommentLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    func bind(comment: CommentDTO?, delegate: CommentTableViewCellDelegate) {
        self.comment = comment
        self.delegate = delegate

        userImage.url(comment?.commenter?.avatar, size: CGSize(width: Const.imageDiameter, height: Const.imageDiameter))
        nicknameLabel.text = comment?.commenter?.nickname ?? ""
        dateLabel.text = comment?.createdAt.asStaledTime()
        commentLabel.text = comment?.comment ?? "[ERROR]"
        frontMargin.frame = CGRect(x: 0, y: 0, width: 35 * ((comment?.lv ?? 1) - 1), height: 0)
        showButtonStackView(comment?.lv ?? 1 == 1)
        showFavoriteCommentMessageStackView(delegate.isAuthorFavoriteComment(comment: comment))

        thumbUpImageView.image = delegate.isThumbedUp(comment: comment) == true ? thumbUpFilled : thumbUpEmpty
        thumbUpCount.text = "\(comment?.thumbUpUserIds?.count ?? 0)"
        thumbDownImageView.image = delegate.isThumbedDown(comment: comment) == true ? thumbDownFilled : thumbDownEmpty
        thumbDownCount.text = "\(comment?.thumbDownUserIds?.count ?? 0)"
    }

    @objc private func didTapThumbUpImageView() {
        delegate?.thumbUp(comment: comment)
    }

    @objc private func didTapThumbDownImageView() {
        delegate?.thumbDown(comment: comment)
    }

    @objc private func didTapReplyView() {
        delegate?.reply(comment: comment)
    }

    private func showButtonStackView(_ flag: Bool) {
        buttonsStackView.subviews.forEach { view in
            view.visible(flag)
        }
    }

    private func showFavoriteCommentMessageStackView(_ flag: Bool) {
        authorFavoriteCommentStackView.layoutMargins = UIEdgeInsets(
            top: CGFloat(flag ? 3 : 0), left: 0, bottom: 0, right: 0)
        authorFavoriteCommentStackView.subviews.forEach { view in
            view.visible(flag)
        }
    }
}
