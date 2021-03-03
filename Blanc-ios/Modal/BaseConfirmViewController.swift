import Foundation
import UIKit
import RxSwift

import Foundation


enum ConfirmResult {
    case accept, decline, purchase
}


class BaseConfirmViewController: UIViewController {

    internal let observable: ReplaySubject = ReplaySubject<ConfirmResult>.create(bufferSize: 1)

    lazy private var background: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 30
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapBackgroundView))
        return view
    }()

    lazy internal var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.visible(false)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        configureConstraints()
        configureInitialTransform()
        showContentView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        decline()
    }

    private func addSubviews() {
        view.addSubview(background)
        view.addSubview(contentView)
    }

    private func configureConstraints() {
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let window = UIApplication.shared.windows[0]
        let bottomPadding = window.safeAreaInsets.bottom
        contentView.snp.makeConstraints { make in
            make.height.equalTo(303 + bottomPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func configureInitialTransform() {
        contentView.transform = CGAffineTransform(translationX: 0, y: view.height * 0.4)
        contentView.visible(false)
    }

    private func showContentView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
            let top = CGAffineTransform(translationX: 0, y: 0)
            contentView.visible(true)
            UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                contentView.transform = top
            })
        }
    }

    @objc private func didTapBackgroundView() {
        decline()
    }

    internal func observe() -> Observable<ConfirmResult> {
        observable
    }

    internal func accept() {
        observable.onNext(.accept)
        dismiss(animated: true)
    }

    internal func purchase() {
        observable.onNext(.purchase)
        dismiss(animated: true)
    }

    internal func decline() {
        observable.onNext(.decline)
        dismiss(animated: true)
    }
}