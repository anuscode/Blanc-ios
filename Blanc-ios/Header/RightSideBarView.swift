import Foundation
import UIKit
import RxSwift

class RightSideBarView: UIView {

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var rightSideBarViewModel: RightSideBarViewModel

    private var delegate: (() -> Void)?

    lazy private var bell: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = UIImage(named: "ic_bell_gray")
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapBellImage))
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var outside: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6.5
        view.layer.masksToBounds = true
        view.width(13, priority: 800)
        view.height(13, priority: 800)
        view.addSubview(inside)
        view.isUserInteractionEnabled = false
        inside.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var inside: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.width(10, priority: 800)
        view.height(10, priority: 800)
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy private var point: UIView = {
        let view = UIView()
        view.addSubview(pointLabel)
        view.addSubview(amountLabel)
        pointLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(pointLabel.snp.trailing).inset(-5)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        return view
    }()

    lazy private var pointLabel: UILabel = {
        let point = UILabel()
        point.layer.cornerRadius = 10
        point.layer.masksToBounds = true
        point.textColor = .white
        point.backgroundColor = .bumble4
        point.font = .systemFont(ofSize: 16)
        point.text = "P"
        point.textAlignment = .center
        return point
    }()

    lazy private var amountLabel: UILabel = {
        let amount = UILabel()
        amount.textColor = .black
        amount.font = .systemFont(ofSize: 16)
        return amount
    }()

    required init(rightSideBarViewModel: RightSideBarViewModel) {
        self.rightSideBarViewModel = rightSideBarViewModel
        super.init(frame: .zero)
        setup()
        subscribeRightSideBarViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setup() {
        addSubview(bell)
        addSubview(outside)
        addSubview(point)

        point.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }

        bell.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalTo(point.snp.trailing).inset(-10)
            make.trailing.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        outside.snp.makeConstraints { make in
            make.top.equalTo(bell.snp.top).inset(3)
            make.trailing.equalTo(bell.snp.trailing).inset(3)
        }
    }

    @objc private func didTapBellImage() {
        delegate?()
    }

    private func badge(_ isShown: Bool) {
        inside.backgroundColor = isShown ? .systemPink : .systemGray3
    }

    private func amount(_ amount: Float) {
        amountLabel.text = "\(amount)"
    }

    func delegate(_ delegate: @escaping () -> Void) {
        self.delegate = delegate
    }

    private func subscribeRightSideBarViewModel() {
        rightSideBarViewModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] data in
                    DispatchQueue.main.async {
                        badge(data.hasUnreadPushes)
                        amount(data.point)
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
