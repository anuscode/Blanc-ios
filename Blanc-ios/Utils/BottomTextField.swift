import Foundation
import UIKit


protocol BottomTextFieldDelegate: class {
    func trigger(message: String)
    func dismiss()
}

class BottomTextField: UIView {

    var placeHolder: String = "댓글을 입력 하세요." {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                textField.placeholder = placeHolder
            }
        }
    }

    var isEnabled: Bool = true {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                textField.isEnabled = isEnabled
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private let ripple: Ripple = Ripple()

    private weak var delegate: BottomTextFieldDelegate?

    private lazy var border: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(border)
        view.addSubview(currentUserImage)
        view.addSubview(textField)
        view.addSubview(replyToTextsStackView)
        view.addSubview(closeImageStackView)

        border.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }

        replyToTextsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalTo(closeImageStackView.snp.leading)
            make.bottom.equalTo(textField.snp.top).offset(7).priority(.medium)
        }

        closeImageStackView.snp.makeConstraints { make in
            make.centerY.equalTo(replyToTextsStackView.snp.centerY)
            make.trailing.equalToSuperview().inset(15)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }

        currentUserImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.centerY.equalTo(textField.snp.centerY)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(replyToTextsStackView.snp.bottom).offset(5)
            make.leading.equalTo(currentUserImage.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(5)
            make.height.equalTo(45)
        }
        return view
    }()

    private lazy var replyToTextsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nicknameToReply, commentToReply
        ])
        stackView.setCustomSpacing(4, after: nicknameToReply)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        // stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return stackView
    }()

    private lazy var nicknameToReply: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.visible(false)
        return label
    }()

    private lazy var commentToReply: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .deepGray
        label.visible(false)
        return label
    }()

    private lazy var closeImageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            closeImage
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var closeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_close_black")
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCloseImage))
        imageView.visible(false)
        ripple.activate(to: imageView)
        return imageView
    }()

    private lazy var currentUserImage: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.layer.cornerRadius = 40 / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.addPadding(direction: .left, width: 15)
        textField.rightView = sendView
        textField.rightViewMode = .always
        textField.placeholder = placeHolder
        textField.keyboardType = .default
        textField.backgroundColor = .secondarySystemBackground
        textField.sizeToFit()
        textField.layer.cornerRadius = 10
        textField.isEnabled = isEnabled
        textField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        return textField
    }()

    private lazy var sendView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.addSubview(sendLabel)
        sendLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(5)
        }
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(send))
        view.width(55)
        view.height(45)
        ripple.activate(to: view)
        return view
    }()

    private lazy var sendLabel: UILabel = {
        let label = UILabel()
        label.text = "전송"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .placeholderText
        return label
    }()

    private func controlReplyToVisibility(_ flag: Bool) {
        replyToTextsStackView.subviews.forEach { view in
            view.visible(flag)
        }
        closeImageStackView.subviews.forEach { view in
            view.visible(flag)
        }
        replyToTextsStackView.layoutMargins = UIEdgeInsets(top: (flag ? 7 : 0), left: 0, bottom: 0, right: 0)
    }

    @objc private func send() {
        let comment = textField.text ?? ""
        delegate?.trigger(message: comment)
    }

    @objc private func didChangeTextField() {
        let value = textField.text
        if (value == "" || value == nil) {
            sendLabel.textColor = .placeholderText
            sendView.isUserInteractionEnabled = false
        } else {
            sendLabel.textColor = .systemBlue
            sendView.isUserInteractionEnabled = true
        }
    }

    @objc private func didTapCloseImage() {
        delegate?.dismiss()
    }

    func configure(avatar: String?) {
        currentUserImage.url(avatar, size: CGSize(width: 40, height: 40))
    }

    func configure(replyTo: CommentDTO?) {
        nicknameToReply.text = "\(replyTo?.commenter?.nickname ?? "[ERROR]") 님에게 답글.."
        commentToReply.text = replyTo?.comment ?? "..."
        controlReplyToVisibility(true)
        textField.becomeFirstResponder()
    }

    func configure(delegate: BottomTextFieldDelegate) {
        self.delegate = delegate
    }

    func dismiss() {
        nicknameToReply.text = ""
        commentToReply.text = ""
        textField.text = ""
        didChangeTextField()
        controlReplyToVisibility(false)
    }
}
