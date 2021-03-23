import UIKit

class HomeTableViewHeaderView: UITableViewHeaderFooterView {

    static let identifier = "HomeTableViewHeaderView"

    lazy private var label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hexCode: "0C090A")
        return label
    }()

    lazy private var underline: UIView = {
        let underline = UIView()
        underline.backgroundColor = .bumble1
        return underline
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureContents() {
        contentView.backgroundColor = .white
        contentView.addSubview(label)
        contentView.addSubview(underline)

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
        }
        underline.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(2)
            make.leading.equalTo(label.snp.leading)
            make.trailing.equalTo(label.snp.trailing)
            make.height.equalTo(3)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    func bind(text: String) {
        label.text = text
    }
}