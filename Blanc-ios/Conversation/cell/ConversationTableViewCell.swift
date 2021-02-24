import Foundation
import UIKit

protocol ConversationTableViewCellDelegate: class {
    func presentUserSingleView(user: UserDTO?)
    func presentConversationSingleView(conversation: ConversationDTO?)
}

class ConversationTableViewCell: UITableViewCell {

    static var identifier: String = "ConversationTableViewCell"

    private var comment: CommentDTO?

    private let ripple: Ripple = Ripple()

    private var conversation: ConversationDTO?

    private class Const {
        static let imageDiameter: CGFloat = CGFloat(60)
    }

    private weak var delegate: ConversationTableViewCellDelegate?

    lazy private var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.width(Const.imageDiameter)
        imageView.height(Const.imageDiameter)
        // imageView.isUserInteractionEnabled = true
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapUserImageView))
        return imageView
    }()

    lazy private var lineContainer: UIView = {
        let view = UIView()
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(guideLine)

        guideLine.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }

        line1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(guideLine.snp.top).offset(-1)
        }

        line2.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().priority(800)
            make.top.equalTo(guideLine.snp.bottom).offset(1)
        }

        return view
    }()

    lazy private var guideLine: UIView = {
        let label = UIView()
        return label
    }()

    lazy private var line1: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    lazy private var line2: UILabel = {
        let label = UILabel()
        label.textColor = .deepGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    lazy private var lastMessageTime: UILabel = {
        let label = UILabel()
        label.text = "5분 전"
        label.textColor = .deepGray
        label.font = .systemFont(ofSize: 12, weight: .thin)
        return label
    }()

    lazy private var unreadMessageCountView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .systemPink
        view.addSubview(unreadMessageCountLabel)
        unreadMessageCountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var unreadMessageCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSelf()
        configureSubviews()
        configureConstraints()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.squircle(19.0)
    }

    private func configureSelf() {
        contentView.isUserInteractionEnabled = true
        ripple.activate(to: contentView)
        contentView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTableViewCell))
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(draw(_:)), userInfo: nil, repeats: true)
    }

    private func configureSubviews() {
        contentView.addSubview(userImage)
        contentView.addSubview(lineContainer)
        contentView.addSubview(lastMessageTime)
        contentView.addSubview(unreadMessageCountView)
    }

    private func configureConstraints() {
        userImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(Const.imageDiameter)
            make.height.equalTo(Const.imageDiameter)
            make.centerY.equalToSuperview()
        }

        let width = UIScreen.main.bounds.width - 2.5 * (Const.imageDiameter)
        lineContainer.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).offset(10)
            make.width.equalTo(width)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        lastMessageTime.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
        }

        unreadMessageCountView.snp.makeConstraints { make in
            make.bottom.equalTo(lastMessageTime.snp.top).inset(-3)
            make.trailing.equalToSuperview().inset(15)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }

    func bind(conversation: ConversationDTO?, delegate: ConversationTableViewCellDelegate?) {
        self.conversation = conversation
        self.delegate = delegate
        draw()
    }

    @objc private func draw() {
        let diameter = Const.imageDiameter
        let partner: UserDTO? = conversation?.partner
        let lastMessage = conversation?.messages?.last
        let nickName = partner?.nickName ?? "알 수 없음"
        let isMessageNotEmpty: Bool = lastMessage?.message.isNotEmpty() ?? false
        let message: String = isMessageNotEmpty ? lastMessage!.message! : "\(nickName) 님과 연결 되었습니다."
        let unreadMessageCount = conversation?.unreadMessageCount ?? 0
        let staledTime = conversation?.messages?.last?.createdAt.asStaledTime() ?? (conversation?.createdAt?.asStaledTime() ?? "알 수 없음")

        userImage.url(partner?.avatar, cornerRadius: 0, size: CGSize(width: diameter, height: diameter))
        line1.text = "\(nickName)"
        line2.text = "\(message)"
        unreadMessageCountLabel.text = "\(unreadMessageCount)"
        unreadMessageCountView.visible(unreadMessageCount > 0)
        lastMessageTime.text = staledTime
    }

    @objc func didTapTableViewCell() {
        delegate?.presentConversationSingleView(conversation: conversation)
    }

    @objc func didTapUserImageView() {
        let partner = conversation?.partner
        delegate?.presentUserSingleView(user: partner)
    }
}
