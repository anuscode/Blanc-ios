import Foundation
import UIKit

class Spinner: UIView {

    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configSelf()
        addSubViews()
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func configSelf() {
        backgroundColor = .black
        alpha = 0.7
        layer.cornerRadius = 15
    }

    private func addSubViews() {
        addSubview(spinner)
    }

    override func visible(_ flag: Bool) {
        super.visible(_: flag)
        if (flag) {
            self.snp.makeConstraints { make in
                make.width.equalTo(55)
                make.height.equalTo(55)
                make.center.equalToSuperview()
            }
        }
    }
}
