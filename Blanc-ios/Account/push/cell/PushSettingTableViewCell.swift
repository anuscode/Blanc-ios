import Foundation
import UIKit

protocol PushSettingTableViewCellDelegate {
    func update(attribute: PushSettingAttribute)
}

class PushSettingTableViewCell: UITableViewCell {

    static var identifier: String = "PushSettingTableViewCell"

    private var attribute: PushSettingAttribute?

    private var delegate: PushSettingTableViewCellDelegate?

    lazy private var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()

    lazy private var enable: UISwitch = {
        let switchControl = UISwitch()
        switchControl.setOn(true, animated: true)
        switchControl.addTarget(self, action: #selector(didChangeSwitchValue), for: .valueChanged)
        switchControl.onTintColor = .bumble3
        return switchControl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSelf()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureSelf() {
        selectionStyle = .none
    }

    private func configureSubviews() {
        contentView.addSubview(label)
        contentView.addSubview(enable)
    }

    private func configureConstraints() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12.5)
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview().inset(12.5)
        }
        enable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }

    @objc private func didChangeSwitchValue() {
        if (attribute == nil) {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            delegate?.update(attribute: attribute!)
        }
    }

    func bind(attribute: PushSettingAttribute,
              isEnable: Bool,
              isBoldTitle: Bool,
              delegate: PushSettingTableViewCellDelegate) {

        self.attribute = attribute
        self.delegate = delegate

        label.text = attribute.rawValue
        enable.setOn(isEnable, animated: true)

        if (isBoldTitle) {
            label.font = .boldSystemFont(ofSize: 18)
            label.textColor = .black
        } else {
            label.font = .systemFont(ofSize: 16)
            label.textColor = .black
        }
    }
}