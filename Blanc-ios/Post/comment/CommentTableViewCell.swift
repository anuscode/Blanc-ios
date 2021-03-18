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

    private class Config {
        static let userImageDiameter: CGFloat = 35
        static let favoriteDiameter: CGFloat = 20
        static let nicknameFontSize: CGFloat = 12
        static let dateFontSize: CGFloat = 10
        static let commentFontSize: CGFloat = 14
        static let authorFavoriteFontSize: CGFloat = 10
        static let replyFontSize: CGFloat = 12
        static let containerDiameter: CGFloat = 25
        static let imageDiameter: CGFloat = 13
        static let countLabelWidth: CGFloat = 10
        static let countLabelHeight: CGFloat = 25
    }

    static let identifier: String = "CommentTableViewCell"

    private let ripple: Ripple = Ripple()

    private weak var comment: CommentDTO?

    private weak var post: PostDTO?

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
        imageView.layer.cornerRadius = Config.userImageDiameter / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy private var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Config.nicknameFontSize)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Config.dateFontSize)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Config.commentFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    lazy private var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            thumbUpImageContainer,
            thumbUpCount,
            thumbDownImageContainer,
            thumbDownCount,
            replyView
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(5, after: thumbDownCount)
        stackView.axis = .horizontal
        return stackView
    }()

    lazy private var thumbUpImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Config.containerDiameter / 2
        view.isUserInteractionEnabled = true
        view.width(Config.containerDiameter, priority: 800)
        view.height(Config.containerDiameter, priority: 800)

        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapThumbUpImageView))

        view.addSubview(thumbUpImageView)
        thumbUpImageView.snp.makeConstraints { make in
            make.width.equalTo(Config.imageDiameter)
            make.height.equalTo(Config.imageDiameter)
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var thumbDownImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Config.containerDiameter / 2
        view.isUserInteractionEnabled = true
        view.width(Config.containerDiameter, priority: 800)
        view.height(Config.containerDiameter, priority: 800)

        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapThumbDownImageView))

        view.addSubview(thumbDownImageView)
        thumbDownImageView.snp.makeConstraints { make in
            make.width.equalTo(Config.imageDiameter)
            make.height.equalTo(Config.imageDiameter)
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
        label.font = .systemFont(ofSize: 13)
        label.width(Config.countLabelWidth, priority: 800)
        label.height(Config.countLabelHeight, priority: 800)
        return label
    }()

    lazy private var thumbDownCount: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 13)
        label.width(Config.countLabelWidth, priority: 800)
        label.height(Config.countLabelHeight, priority: 800)
        return label
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
        label.font = .systemFont(ofSize: Config.replyFontSize)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(50)
        }
        return view
    }()

    lazy private var favoriteView: UIView = {
        let view = UIView()
        view.visible(false)
        view.addSubview(favoriteUserImage)
        favoriteUserImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let heartImageView = UIImageView(image: UIImage(named: "ic_heart_red"))
        view.addSubview(heartImageView)
        heartImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(-3)
            make.bottom.equalToSuperview().inset(-3)
            make.width.equalTo(10)
            make.height.equalTo(10)
        }
        return view
    }()

    lazy private var favoriteUserImage: UIImageView = {
        let userImageView = UIImageView()
        userImageView.layer.cornerRadius = Config.favoriteDiameter / 2
        userImageView.clipsToBounds = true
        return userImageView
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
        content.addSubview(favoriteView)
        content.addSubview(commentLabel)
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
            make.width.equalTo(Config.userImageDiameter)
            make.height.equalTo(Config.userImageDiameter)
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
            make.top.equalTo(nicknameLabel.snp.bottom).inset(-3)
            make.trailing.equalToSuperview().inset(10)
        }

        buttonsStackView.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-8)
            make.top.equalTo(commentLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }

        favoriteView.snp.makeConstraints { make in
            make.leading.equalTo(buttonsStackView.snp.trailing).inset(-8)
            make.centerY.equalTo(buttonsStackView.snp.centerY)
        }
    }

    func bind(comment: CommentDTO?, delegate: CommentTableViewCellDelegate) {
        self.comment = comment
        self.delegate = delegate

        let userImageDiameter = Config.userImageDiameter
        let userImageSize = CGSize(width: userImageDiameter, height: userImageDiameter)
        let userImageUrl = comment?.commenter?.avatar
        let nickname = comment?.commenter?.nickname ?? ""
        let staledTime = comment?.createdAt.asStaledTime()
        let commentText = comment?.isDeleted != true ? (comment?.comment ?? "...") : "관리자가 삭제 한 댓글 입니다."
        let frontMarginFrame = CGRect(x: 0, y: 0, width: 35 * ((comment?.lv ?? 1) - 1), height: 0)
        let isButtonShown = comment?.lv ?? 1 == 1
        userImage.url(userImageUrl, size: userImageSize)
        nicknameLabel.text = nickname
        dateLabel.text = staledTime
        commentLabel.text = commentText
        frontMargin.frame = frontMarginFrame
        showButtonStackView(isButtonShown)

        let isAuthorFavoriteComment = delegate.isAuthorFavoriteComment(comment: comment)
        let favoriteDiameter = Config.favoriteDiameter
        let size = CGSize(width: favoriteDiameter, height: favoriteDiameter)
        let authorUserImageUrl = comment?.post?.author?.avatar
        favoriteUserImage.url(authorUserImageUrl, size: size)
        favoriteView.visible(isAuthorFavoriteComment)

        let isThumbedUp = delegate.isThumbedUp(comment: comment) == true
        let thumbUpCountText = "\(comment?.thumbUpUserIds?.count ?? 0)"
        let isThumbedDown = delegate.isThumbedDown(comment: comment) == true
        let thumbDownCountText = "\(comment?.thumbDownUserIds?.count ?? 0)"
        thumbUpImageView.image = isThumbedUp ? thumbUpFilled : thumbUpEmpty
        thumbUpCount.text = thumbUpCountText
        thumbDownImageView.image = isThumbedDown ? thumbDownFilled : thumbDownEmpty
        thumbDownCount.text = thumbDownCountText
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
}
