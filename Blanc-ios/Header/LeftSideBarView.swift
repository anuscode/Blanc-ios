import Foundation
import UIKit
import RxSwift

class LeftSideBarView: UIView {

    lazy private var label: UILabel = {
        let label = UILabel()
        label.text = "블랑"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .black
        return label
    }()

    lazy private var dot: UILabel = {
        let dot = UILabel()
        dot.text = "."
        dot.textColor = .bumble4
        dot.font = .boldSystemFont(ofSize: 30)
        return dot
    }()

    required init(title: String = "블랑") {
        super.init(frame: .zero)
        label.text = title
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setup() {
        addSubview(label)
        addSubview(dot)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        dot.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}
