import Foundation
import UIKit

class InitSecondViewController: UIViewController {

    private let fireworkController = ClassicFireworkController()

    lazy private var pingme: UILabel = {
        let label = UILabel()
        label.text = "blanc;"
        label.font = UIFont(name: "JalnanOTF", size: 70)
        label.textColor = UIColor.tinderPink
        return label
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in
            fireworkController.addFireworks(count: 6, sparks: 8, around: pingme)
        }
    }

    private func configureSubviews() {
        view.addSubview(pingme)
    }

    private func configureConstraints() {
        pingme.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
