import Foundation
import UIKit

class RegistrationTextFieldCell: UITableViewCell {

    static let identifier = "RegistrationTextFieldCell"

    public var onEndEditing: ((String?) -> Void)?

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "직접입력."
        textField.keyboardType = .default
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        selectionStyle = .none
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50).priority(500)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = ""
        textField.resignFirstResponder()
        textField.removeTarget(nil, action: nil, for: .allEvents)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onEndEditing?(textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
