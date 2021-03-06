import Foundation
import UIKit
import Lottie

class StarFallView: UIView {

    private var ripple: Ripple = Ripple()

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

    required init() {
        super.init(frame: .zero)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func configureSubviews() {
        addSubview(host)
    }

    private func configureConstraints() {
        host.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}