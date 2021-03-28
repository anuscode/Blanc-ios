import Foundation
import UIKit
import RxSwift


protocol BottomTextFieldDelegate: class {
    func trigger(message: String)
    func dismiss()
}

class BottomTextView: UIView {

    private let disposeBag: DisposeBag = DisposeBag()

    var placeHolder: String = "댓글을 입력 하세요." {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                placeholder.text = placeHolder
            }
        }
    }

    var isEditable: Bool = true {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                textView.isEditable = isEditable
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
        view.addSubview(textView)
        view.addSubview(replyToTextsStackView)
        view.addSubview(closeImageStackView)
        view.addSubview(sendView)

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
            make.bottom.equalTo(textView.snp.top).offset(7).priority(.medium)
        }
        closeImageStackView.snp.makeConstraints { make in
            make.centerY.equalTo(replyToTextsStackView.snp.centerY)
            make.trailing.equalToSuperview().inset(15)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        currentUserImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.centerY.equalTo(textView.snp.centerY)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(replyToTextsStackView.snp.bottom).offset(5)
            make.leading.equalTo(currentUserImage.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(5)
            make.height.equalTo(40)
        }
        sendView.snp.makeConstraints { make in
            make.centerY.equalTo(textView.snp.centerY)
            make.trailing.equalTo(textView.snp.trailing)
            make.width.equalTo(55)
            make.height.equalTo(40)
        }
        return view
    }()

    private lazy var replyToTextsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nicknameToReply,
            commentToReply
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

    private lazy var placeholder: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
        textView.keyboardType = .default
        textView.sizeToFit()
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 50)
        textView.addSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        textView.rx
            .text
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [unowned self] _ in
                let height = self.textView.contentSize.height
                textView.snp.remakeConstraints { make in
                    make.top.equalTo(self.replyToTextsStackView.snp.bottom).offset(5)
                    make.leading.equalTo(self.currentUserImage.snp.trailing).offset(10)
                    make.trailing.equalToSuperview().inset(15)
                    make.bottom.equalToSuperview().inset(5)
                    make.height.equalTo(height)
                }
            })
            .do(onNext: { [unowned self] text in
                self.placeholder.visible(text.isEmpty())
            })
            .subscribe({ [unowned self] _ in
                self.didChangeTextField()
            })
            .disposed(by: disposeBag)
        return textView
    }()

    private lazy var sendView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.addSubview(sendLabel)
        sendLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(5)
            make.width.equalTo(55)
            make.height.equalTo(45)
        }
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapSendButton))
        ripple.activate(to: view)
        return view
    }()

    private lazy var sendLabel: UILabel = {
        let label = UILabel()
        label.text = "전송"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray3
        return label
    }()

    private func controlReplyToVisibility(_ isVisible: Bool) {
        replyToTextsStackView.subviews.forEach { view in
            view.visible(isVisible)
        }
        closeImageStackView.subviews.forEach { view in
            view.visible(isVisible)
        }
        replyToTextsStackView.layoutMargins = UIEdgeInsets(top: (isVisible ? 7 : 0), left: 0, bottom: 0, right: 0)
    }

    @objc private func didTapSendButton() {
        let message = textView.text ?? ""
        delegate?.trigger(message: message)
    }

    @objc private func didChangeTextField() {
        let isTextEmpty = textView.text.isEmpty()
        sendLabel.textColor = isTextEmpty ? .systemGray3 : .systemBlue
        sendView.isUserInteractionEnabled = !isTextEmpty
    }

    @objc private func didTapCloseImage() {
        delegate?.dismiss()
    }

    func configure(avatar: String?) {
        let size = CGSize(width: 40, height: 40)
        currentUserImage.url(avatar, size: size)
    }

    func configure(replyTo: CommentDTO?) {
        nicknameToReply.text = "\(replyTo?.commenter?.nickname ?? "[ERROR]") 님에게 답글.."
        commentToReply.text = replyTo?.comment ?? "..."
        controlReplyToVisibility(true)
        textView.becomeFirstResponder()
    }

    func configure(delegate: BottomTextFieldDelegate) {
        self.delegate = delegate
    }

    func dismiss() {
        nicknameToReply.text = ""
        commentToReply.text = ""
        textView.text = ""
        didChangeTextField()
        controlReplyToVisibility(false)
    }
}