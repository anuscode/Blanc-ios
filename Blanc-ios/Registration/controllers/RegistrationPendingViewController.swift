import Foundation
import UIKit
import RxSwift
import SnapKit
import TTGTagCollectionView


class RegistrationPendingViewController: UIViewController {

    var registrationViewModel: RegistrationViewModel?

    private let disposeBag: DisposeBag = DisposeBag()

    var ripple = Ripple()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "blanc"
        label.font = .boldSystemFont(ofSize: 35)
        label.textColor = .black
        return label
    }()

    lazy private var dot: UILabel = {
        let dot = UILabel()
        dot.text = "."
        dot.textColor = .bumble4
        dot.font = .boldSystemFont(ofSize: 40)
        return dot
    }()

    lazy private var secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.text = "승인 시 메인 화면으로 자동 전환 됩니다."
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 2;
        label.textColor = .lightBlack
        return label
    }()

    lazy private var imageView: GradientCircleImageView = {
        let width = UIScreen.main.bounds.width
        let imageView = GradientCircleImageView(diameter: width / 3.5)
        return imageView
    }()

    lazy private var noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.addSubview(progressTextLabel)
        progressTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.trailing.equalToSuperview().inset(40)
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var progressTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = .darkText
        label.alpha = 1
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    lazy private var imageButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitle("이미지 변경 하기", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        button.visible(false)
        ripple.activate(to: button)
        return button
    }()

    lazy private var host: UIView = {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let size = CGSize(width: width, height: height)
        let host = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        host.layer.addSublayer(particlesLayer)
        host.layer.masksToBounds = true
        return host
    }()

    lazy private var particlesLayer: CAEmitterLayer = {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let size = CGSize(width: width, height: height)

        let particlesLayer = CAEmitterLayer()
        particlesLayer.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        particlesLayer.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        particlesLayer.emitterShape = .circle
        particlesLayer.emitterPosition = CGPoint(x: 420.6, y: 375.2)
        particlesLayer.emitterSize = CGSize(width: 1648.0, height: 941.0)
        particlesLayer.emitterMode = .surface
        particlesLayer.renderMode = .oldestLast
        particlesLayer.emitterCells = [cell0, cell1, cell2, cell3, cell4, cell5]
        return particlesLayer
    }()

    lazy private var cell0: CAEmitterCell = {
        let image1 = UIImage(named: "Star")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 30.0
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        return cell
    }()

    lazy private var cell1: CAEmitterCell = {
        let image1 = UIImage(named: "Star")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 20.0
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor(red: 255.0 / 255.0, green: 196.0 / 255.0, blue: 3.7 / 255.0, alpha: 0.9).cgColor
        return cell
    }()

    lazy private var cell2: CAEmitterCell = {
        let image1 = UIImage(named: "Star")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 5.0
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor(red: 255.0 / 255.0, green: 197.5 / 255.0, blue: 59.9 / 255.0, alpha: 0.9).cgColor
        return cell
    }()

    lazy private var cell3: CAEmitterCell = {
        let image1 = UIImage(named: "Star")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 5.0
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor(red: 192.5 / 255.0, green: 255.0 / 255.0, blue: 119.1 / 255.0, alpha: 0.9).cgColor
        return cell
    }()

    lazy private var cell4: CAEmitterCell = {
        let image1 = UIImage(named: "Star")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 5.0
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor(red: 255.0 / 255.0, green: 10.8 / 255.0, blue: 163.4 / 255.0, alpha: 0.9).cgColor
        return cell
    }()

    lazy private var cell5: CAEmitterCell = {
        let image1 = UIImage(named: "Star")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 5.0
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor(red: 149.2 / 255.0, green: 162.4 / 255.0, blue: 255.0 / 255.0, alpha: 0.9).cgColor
        return cell
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
        subscribeBroadcast()
    }

    private func configureSubviews() {
        view.addSubview(host)
        view.addSubview(titleLabel)
        view.addSubview(dot)
        view.addSubview(secondaryTextLabel)
        view.addSubview(imageView)
        view.addSubview(noticeView)
        view.addSubview(imageButton)
    }

    private func configureConstraints() {

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageButton.snp.leading)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
        }

        dot.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.bottom.equalTo(titleLabel.snp.bottom)
        }

        secondaryTextLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.80)
        }

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.9)
        }

        noticeView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }

        imageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?.observe()
                .take(1)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { user in
                    self.update(user)
                }, onError: { err in
                    self.toast(message: "알 수 없는 에러가 발생 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

    private func subscribeBroadcast() {
        Broadcast.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { push in
                    if (push.isApproval()) {
                        self.parent?.replace(storyboard: "Main", withIdentifier: "InitPagerViewController")
                    }
                }, onError: { err in
                    self.toast(message: "알 수 없는 에러가 발생 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

    private func update(_ userDTO: UserDTO) {

        imageView.url(userDTO.getTempImageUrl(index: 0))

        if (userDTO.status == Status.BLOCKED) {
            secondaryTextLabel.text = "고객센터로 연락 바랍니다."
            progressTextLabel.text = "해당 계정은 이용 정지 되었습니다."
            progressTextLabel.textColor = .systemRed
            return
        }

        if (userDTO.status == Status.REJECTED) {
            progressTextLabel.text = "사진이 반려 되었습니다.\n수정 후 다시 이용 바랍니다."
            progressTextLabel.textColor = .systemRed
            imageButton.visible(true)
            return
        }

        if (userDTO.status == Status.PENDING) {
            progressTextLabel.text = "관리자의 프로필 검수 후\n가입이 완료 됩니다."
            return
        }
    }

    @objc private func didTapImageButton() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationImageViewController", animated: true)
    }
}
