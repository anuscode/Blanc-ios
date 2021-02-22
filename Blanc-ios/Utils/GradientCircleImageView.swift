import Foundation
import UIKit


class GradientCircleImageView: UIView {

    private let inset: CGFloat = CGFloat(2)

    private let contentDiameter: CGFloat

    lazy private var whiteDiameter: CGFloat = {
        contentDiameter - (inset * 2)
    }()

    lazy private var imageDiameter: CGFloat = {
        contentDiameter - (inset * 4)
    }()

    lazy private var content: Gradient45View = {
        let view = Gradient45View(colors: [.bumble3, .purple])

        view.layer.cornerRadius = contentDiameter / 2
        view.layer.masksToBounds = true
        view.width(contentDiameter)
        view.height(contentDiameter)

        let white = UIView()
        white.backgroundColor = .white
        white.layer.cornerRadius = whiteDiameter / 2
        white.layer.masksToBounds = true

        view.addSubview(white)
        view.addSubview(userImage)

        white.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(whiteDiameter)
            make.height.equalTo(whiteDiameter)
        }

        userImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(imageDiameter)
            make.height.equalTo(imageDiameter)
        }

        return view
    }()

    lazy private var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.width(imageDiameter)
        imageView.height(imageDiameter)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageDiameter / 2
        imageView.image = UIImage(named: "ic_avatar")
        return imageView
    }()

    required init(diameter: CGFloat) {
        contentDiameter = diameter
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setup() {
        addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(contentDiameter)
            make.height.equalTo(contentDiameter)
        }
    }

    func url(_ url: String?) {
        userImage.url(url ?? "", cornerRadius: imageDiameter)
    }
}
