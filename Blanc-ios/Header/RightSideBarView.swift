import Foundation
import UIKit
import RxSwift
import RxGesture

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

        imageView.rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in
                    self.delegate?()
                })
                .disposed(by: disposeBag)

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
        configureSubviews()
        configureConstraints()
        bind()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func configureSubviews() {
        addSubview(bell)
        addSubview(outside)
        addSubview(point)
    }

    private func configureConstraints() {
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

    func delegate(_ delegate: @escaping () -> Void) {
        self.delegate = delegate
    }

    private func bind() {

        rightSideBarViewModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ data -> UIColor in
                    let isShown = data.hasUnreadPushes
                    return isShown ? .systemPink : .systemGray3
                })
                .observeOn(MainScheduler.asyncInstance)
                .bind(to: inside.rx.backgroundColor)
                .disposed(by: disposeBag)

        rightSideBarViewModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .map({ data -> String in
                    "\(data.point)"
                })
                .observeOn(MainScheduler.asyncInstance)
                .bind(to: amountLabel.rx.text)
                .disposed(by: disposeBag)
    }
}
