import UIKit


class HomeLoading: UIView {

    private class Const {
        static let horizontalInset: CGFloat = 10
        static let bottomMargin: CGFloat = 10
        static let starSize: CGFloat = 40
        static let starHorizontalInset: CGFloat = -6
    }

    lazy private var length: CGFloat = {
        let width = UIScreen.main.bounds.width - (Const.horizontalInset * 2)
        return width
    }()

    lazy private var carousel: UIView = {
        let view = UIView()

        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)

        label1.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(20)
            make.bottom.equalTo(label2.snp.top).inset(-8)
        }
        label2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(20)
            make.bottom.equalTo(label3.snp.top).inset(-8)
        }
        label3.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().inset(10)
        }
        return view
    }()

    lazy private var bottomView: UIView = {
        let view = UIView()
        view.addSubview(button2)
        view.addSubview(button1)

        button1.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.width.equalTo(55)
            make.height.equalTo(50)
        }
        button2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(15)
        }
        return view
    }()

    lazy private var button1: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.silverBlue.withAlphaComponent(0.7)
        view.layer.cornerRadius = Constants.radius
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1

        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "paperplane.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.width.equalTo(25)
            make.height.equalTo(25)
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var button2: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.radius
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true

        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .silverBlue
        label.text = "밀어서 친구 신청"

        let imageView = UIImageView()

        view.addSubview(label)
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
        }
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var button3: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.radius
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true

        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 10)
        label.textColor = .silverBlue
        label.text = " "

        let imageView = UIImageView()

        view.addSubview(label)
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(3)
        }
        return view
    }()

    lazy private var label1: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy private var label2: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy private var label3: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.silverBlue.withAlphaComponent(0.7)
        layer.cornerRadius = 15
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        addSubview(carousel)
        addSubview(bottomView)
    }

    private func configureConstraints() {
        carousel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(length)
            make.height.equalTo(length * 0.85)
            make.centerX.equalToSuperview()
        }
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(carousel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}