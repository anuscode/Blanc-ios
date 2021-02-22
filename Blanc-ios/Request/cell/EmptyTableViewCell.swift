import Foundation
import UIKit
import Lottie

class EmptyTableViewCell: UITableViewCell {

    static var identifier: String = "EmptyTableViewCell"

    lazy private var lottieView: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("bad_emoji")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()

    lazy private var message: UILabel = {
        let label = UILabel()
        label.text = "아직 받은 요청이 없습니다."
        label.textColor = .darkText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        contentView.addSubview(lottieView)
        contentView.addSubview(message)
    }

    private func configureConstraints() {
        lottieView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(100).priority(800)
        }

        message.snp.makeConstraints { make in
            make.top.equalTo(lottieView.snp.bottom).offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50).priority(800)
            make.bottom.equalToSuperview().inset(50)
        }
    }
}