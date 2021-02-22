import Foundation
import UIKit

class RegistrationSelectFieldCell: UITableViewCell {
    static let identifier = "RegistrationSelectFieldCell"

    var ripple = Ripple()

    lazy private var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        tintColor = .systemBlue
        selectedBackgroundView = bgView
        textLabel?.font = .systemFont(ofSize: 18)
        textLabel?.textColor = .black
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
        textLabel?.textColor = .systemBlue
    }

    func deselect() {
        accessoryType = UITableViewCell.AccessoryType.none
        textLabel?.textColor = .black
    }
}
