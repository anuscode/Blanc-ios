import Foundation
import UIKit
import RxSwift
import FSPagerView

class MatchingTableViewCell: UITableViewCell {

    static let identifier: String = "MatchingTableViewCell"

    lazy private var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    lazy private var content: UIView = {
        let view = UIView()
        view.backgroundColor = .bumble3
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        configConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func addSubviews() {
        contentView.addSubview(content)
    }

    private func configConstraints() {
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func bind(message: String?) {
        DispatchQueue.main.async { [unowned self] in
            label.text = message
        }
    }
}