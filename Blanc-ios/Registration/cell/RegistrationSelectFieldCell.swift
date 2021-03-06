import Foundation
import UIKit

class RegistrationSelectFieldCell: UITableViewCell {

    static let identifier = "RegistrationSelectFieldCell"

    var ripple = Ripple()

    lazy private var container: UIView = {
        let view = UIView()
        view.backgroundColor = .tinderPink
        view.addSubview(subjectLabel)
        subjectLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }
        return view
    }()

    lazy private var subjectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        tintColor = .black
        backgroundColor = .systemYellow
        ripple.activate(to: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        deselect()
    }

    func configureSubviews() {
        contentView.addSubview(container)
    }

    func configureConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.height.equalTo(50)
        }
    }

    func select() {
        accessoryType = .checkmark
        textLabel?.textColor = .tinderPink
    }

    func deselect() {
        accessoryType = .none
        textLabel?.textColor = .black
    }
}
