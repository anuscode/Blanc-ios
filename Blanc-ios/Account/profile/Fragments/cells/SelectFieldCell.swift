import Foundation
import UIKit

class SelectFieldCell: UITableViewCell {
    static let identifier = "SelectFieldCell"

    var ripple = Ripple()

    lazy private var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectedBackgroundView = bgView
        tintColor = .tinderPink
        textLabel?.font = .systemFont(ofSize: 16)
        textLabel?.textColor = .black
        textLabel?.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        ripple.activate(to: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        deselect()
    }

    func select() {
        accessoryType = UITableViewCell.AccessoryType.checkmark
        textLabel?.textColor = .tinderPink
    }

    func deselect() {
        accessoryType = UITableViewCell.AccessoryType.none
        textLabel?.textColor = .black
    }
}
