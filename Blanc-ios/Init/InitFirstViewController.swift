import UIKit

class InitFirstViewController: UIViewController {

    lazy private var blanc: UILabel = {
        let label = UILabel()
        label.text = "blanc;"
        label.font = UIFont(name: "JalnanOTF", size: 70)
        label.textColor = .white
        return label
    }()

    lazy private var gradient: GradientView = {
        let alpha0 = UIColor.tinderPink
        let alpha1 = UIColor.bumble1
        let gradient = GradientView(
                colors: [alpha0, alpha1],
                locations: [0.0, 2],
                startPoint: CGPoint(x: 1, y: 0),
                endPoint: CGPoint(x: 0, y: 1)
        )
        return gradient
    }()

    lazy private var host: UIView = {
        let size = UIScreen.main.bounds.size
        let host = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        host.layer.addSublayer(particlesLayer)
        host.layer.masksToBounds = true
        particlesLayer.emitterCells = [cell1]
        return host
    }()

    lazy private var particlesLayer: CAEmitterLayer = {
        let particlesLayer = CAEmitterLayer()
        let size = UIScreen.main.bounds.size
        particlesLayer.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        particlesLayer.backgroundColor = UIColor.clear.cgColor
        particlesLayer.emitterShape = .point
        particlesLayer.emitterPosition = CGPoint(x: size.width / 4, y: -30)
        particlesLayer.emitterSize = size
        particlesLayer.emitterMode = .surface
        particlesLayer.renderMode = .oldestLast
        return particlesLayer
    }()

    lazy private var cell1: CAEmitterCell = {
        let image1 = UIImage(named: "Smoke")?.cgImage
        let cell1 = CAEmitterCell()
        cell1.contents = image1
        cell1.name = "Snow"
        cell1.birthRate = 15.0
        cell1.lifetime = 20.0
        cell1.velocity = 59.0
        cell1.velocityRange = -15.0
        cell1.xAcceleration = 5.0
        cell1.yAcceleration = 40.0
        cell1.emissionRange = 180.0 * (.pi / 180.0)
        cell1.spin = -28.6 * (.pi / 180.0)
        cell1.spinRange = 57.2 * (.pi / 180.0)
        cell1.scale = 0.06
        cell1.scaleRange = 0.3
        cell1.color = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        return cell1
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        view.addSubview(gradient)
        view.addSubview(blanc)
        view.addSubview(host)
    }

    private func configureConstraints() {
        blanc.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        gradient.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}