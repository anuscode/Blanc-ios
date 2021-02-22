import Foundation
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import UIKit

class TextFieldCell: UITableViewCell {

    static let identifier = "TextFieldCell"

    public var onEndEditing: ((String?) -> Void)?

    let textField: MDCOutlinedTextField = {
        let textField = MDCOutlinedTextField()
        let rightImage = UIImageView(image: UIImage(systemName: "pencil.and.outline"))
        rightImage.image = rightImage.image?.withRenderingMode(.alwaysTemplate)
        textField.label.text = "직접입력."
        textField.trailingView = rightImage
        textField.trailingViewMode = .always
        textField.placeholder = "직접입력."
        textField.keyboardType = .default
        textField.frame.size.height = 10
        textField.backgroundColor = .secondarySystemBackground
        textField.containerRadius = FragmentConfig.textFieldCornerRadius
        textField.setColor(primary: .deepGray, secondary: .secondaryLabel)
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        selectionStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(1)
            make.trailing.equalToSuperview().inset(1)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
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
        self.onEndEditing?(textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
