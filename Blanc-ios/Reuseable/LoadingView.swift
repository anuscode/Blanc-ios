import UIKit
import SnapKit
import Lottie

class LoadingView: UIView {

    lazy private var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.5)
        view.layer.cornerRadius = 30
        return view
    }()

    lazy private var animationView1: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("girl_cycling")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()

    lazy private var animationView2: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("loading")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func configureSubviews() {
        addSubview(contentView)
        contentView.addSubview(animationView1)
        contentView.addSubview(animationView2)
    }

    private func configureConstraints() {

        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }

        animationView1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(150)
        }

        animationView2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(-35)
            make.width.equalToSuperview().multipliedBy(1.5)
            make.height.equalTo(150)
        }
    }

    override func visible(_ flag: Bool) {
        isHidden = !flag
        if (flag) {
            animationView1.play()
            animationView2.play()
        }
    }
}
