import Foundation
import UIKit
import RxSwift


class OpenConversationConfirmViewController: BaseConfirmViewController {

    static func present(target: UIViewController, user: UserDTO?) -> Observable<ConfirmResult> {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(
            withIdentifier: "OpenConversationConfirmViewController") as! OpenConversationConfirmViewController
        controller.setUser(user)
        target.present(controller, animated: false, completion: nil)
        return controller.observe().take(1)
    }

    // user to request
    private var user: UserDTO? = nil

    // my session.
    internal weak var session: Session?

    private let ripple: Ripple = Ripple()

    lazy private var blancLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "blanc"
        label.textColor = .darkGray
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    lazy private var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_avatar")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35 / 2
        imageView.url(user?.avatar)
        view.addSubview(imageView)
        return imageView
    }()

    lazy private var subjectLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "여자_테스트계정_1\n님에게 친구 신청을 합니다."
        label.numberOfLines = 0
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    lazy private var consumePointBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .systemOrange
        view.addSubview(consumePointLabel)
        consumePointLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(7)
            make.bottom.equalToSuperview().inset(7)
            make.leading.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().inset(5)
        }
        return view
    }()

    lazy private var consumePointLabel: UILabel = {
        let label = UILabel()
        label.text = "무료"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }()

    lazy private var pointLeftLabel: UILabel = {
        let label = UILabel()
        label.text = "잔여 포인트: 0.0"
        label.textColor = .darkGray
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }()

    lazy private var purchaseView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        let border1 = UIView()
        border1.translatesAutoresizingMaskIntoConstraints = false
        border1.backgroundColor = .systemGray3

        let border2 = UIView()
        border2.translatesAutoresizingMaskIntoConstraints = false
        border2.backgroundColor = .systemGray3

        let dollarImageView = UIImageView()
        dollarImageView.image = UIImage(named: "ic_attach_money")
        dollarImageView.contentMode = .scaleAspectFit

        let purchasePointLabel = UILabel()
        purchasePointLabel.text = "포인트 구매"
        purchasePointLabel.numberOfLines = 0
        purchasePointLabel.textColor = .darkText
        purchasePointLabel.font = .systemFont(ofSize: 17)

        let forwardImageView = UIImageView()
        forwardImageView.image = UIImage(named: "ic_ios_forward_black")

        view.addSubview(border1)
        view.addSubview(dollarImageView)
        view.addSubview(purchasePointLabel)
        view.addSubview(pointLeftLabel)
        view.addSubview(forwardImageView)
        view.addSubview(border2)

        view.isUserInteractionEnabled = true
        ripple.activate(to: view)

        border1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.3)
            make.top.equalToSuperview()
        }

        dollarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(25)
            make.height.equalTo(25)
        }

        purchasePointLabel.snp.makeConstraints { make in
            make.leading.equalTo(dollarImageView.snp.trailing).inset(-10)
            make.centerY.equalToSuperview()
        }

        pointLeftLabel.snp.makeConstraints { make in
            make.leading.equalTo(purchasePointLabel.snp.trailing).inset(-10)
            make.centerY.equalToSuperview()
        }

        forwardImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.height.equalTo(10)
        }

        border2.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.3)
            make.bottom.equalToSuperview()
        }

        return view
    }()

    lazy private var timeLeftLabel: UILabel = {
        let label = UILabel()
        label.text = "무료로 요청이 가능합니다."
        label.textColor = .darkGray
        label.font = .boldSystemFont(ofSize: 12)
        return label
    }()

    lazy private var confirmButton: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.radius
        view.backgroundColor = .bumble3
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        ripple.activate(to: view)
        let label = UILabel()
        label.text = "확인"
        label.textColor = .white
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapConfirmButton))
        return view
    }()

    lazy private var purchaseButton: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.radius
        view.backgroundColor = .faceBook
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        ripple.activate(to: view)
        let label = UILabel()
        label.text = "포인트 구매"
        label.textColor = .white
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapPurchaseButton))
        view.visible(false)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureSubviews()
        configureConstraints()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        update()
    }

    private func configureSubviews() {
        contentView.addSubview(blancLabel)
        contentView.addSubview(userImage)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(consumePointBackgroundView)
        contentView.addSubview(purchaseView)
        contentView.addSubview(timeLeftLabel)
        contentView.addSubview(confirmButton)
        contentView.addSubview(purchaseButton)
    }

    private func configureConstraints() {

        blancLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(25)
            make.leading.equalToSuperview().inset(20)
        }

        userImage.snp.makeConstraints { make in
            make.top.equalTo(blancLabel.snp.bottom).inset(-25)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }

        subjectLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImage.snp.centerY)
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
        }

        consumePointBackgroundView.snp.makeConstraints { make in
            make.centerY.equalTo(userImage.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
        }

        purchaseView.snp.makeConstraints { make in
            make.top.equalTo(userImage.snp.bottom).inset(-25)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(55)
        }

        timeLeftLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top).inset(-20)
        }

        confirmButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(Constants.mediumButtonHeight)
        }

        purchaseButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(Constants.mediumButtonHeight)
        }
    }

    @objc private func update() {
        subjectLabel.text = getSubjectText()
        pointLeftLabel.text = getRemainingPointText()
        timeLeftLabel.text = getRemainingTimeText()
        consumePointLabel.text = getConsumePointText()

        if (isFreePassAvailable()) {
            confirmButton.visible(true)
            purchaseButton.visible(false)
        } else if (isPointAvailable()) {
            confirmButton.visible(true)
            purchaseButton.visible(false)
        } else {
            confirmButton.visible(false)
            purchaseButton.visible(true)
        }
    }

    func setUser(_ user: UserDTO?) {
        self.user = user
    }

    private func isPointAvailable() -> Bool {
        (session?.user?.point ?? 0) >= 1
    }

    private func isFreePassAvailable() -> Bool {
        let seconds = getRemainingSeconds()
        return seconds == 0
    }

    private func getRemainingSeconds() -> Int {
        let tokens = session?.user?.freeOpenTokens ?? []
        let availableAfter: Int = tokens.min() ?? 9223372036854775800
        let current = Int(NSDate().timeIntervalSince1970)
        let delta = availableAfter - current
        return (delta > 0) ? delta : 0
    }

    private func getRemainingTimeText() -> String {
        let remaining = getRemainingSeconds()
        if (remaining <= 0) {
            return "무료 요청이 가능 합니다."
        }
        let hours: Int = Int(remaining / 3600)
        let minutes: Int = Int((remaining % 3600) / 60)
        let seconds: Int = Int((remaining % 60))

        return "무료 요청까지 남은 시간: \(String(format: "%02d", hours)):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }

    private func getConsumePointText() -> String {
        isFreePassAvailable() ? "무료" : "포인트 5개"
    }

    private func getSubjectText() -> String {
        "\(user?.nickname ?? "[ERROR]")\n님에게 친구 신청을 합니다."
    }

    private func getRemainingPointText() -> String {
        let point: Float? = session?.user?.point
        return "잔여 포인트: " + ((point != nil && point! >= 0) ? "\(point!)" : "[ERROR]")
    }

    @objc private func didTapConfirmButton() {
        accept()
    }

    @objc private func didTapPurchaseButton() {
        purchase()
    }
}
