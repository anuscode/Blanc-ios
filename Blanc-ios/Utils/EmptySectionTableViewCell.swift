import UIKit
import Lottie


class EmptySectionTableViewCell: UITableViewCell {

    static let identifier: String = "EmptySectionTableViewCell"

    private lazy var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("bad_emoji")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        return animationView
    }()

    lazy private var mainLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    lazy private var secondaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 3
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureContents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureContents() {
        contentView.backgroundColor = .white
        contentView.addSubview(animationView)
        contentView.addSubview(mainLabel)
        contentView.addSubview(secondaryLabel)

        animationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(100).priority(800)
        }
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
        }
    }

    func bind(mainText: String, secondaryText: String) {
        mainLabel.text = mainText
        secondaryLabel.text = secondaryText
    }
}