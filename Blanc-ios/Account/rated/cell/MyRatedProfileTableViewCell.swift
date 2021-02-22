import Foundation
import UIKit
import RxSwift
import FSPagerView

class MyRatedProfileTableViewCell: UITableViewCell {

    static let identifier: String = "MyRatedProfileTableViewCell"

    lazy private var progress: HorizontalGradientView = {
        let alpha0 = UIColor.bumble0
        let alpha1 = UIColor.systemPink
        let gradient = HorizontalGradientView(colors: [alpha0, alpha1], locations: [0.0, 1.2])
        gradient.layer.cornerRadius = 10
        gradient.layer.masksToBounds = true

        let view1 = UIView()
        gradient.addSubview(view1)
        view1.backgroundColor = .white
        view1.snp.makeConstraints { make in
            make.leading.equalTo(gradient.snp.trailing).multipliedBy(0.2)
            make.width.equalTo(1)
            make.height.equalTo(gradient.snp.height)
        }

        let view2 = UIView()
        gradient.addSubview(view2)
        view2.backgroundColor = .white
        view2.snp.makeConstraints { make in
            make.leading.equalTo(gradient.snp.trailing).multipliedBy(0.4)
            make.width.equalTo(1)
            make.height.equalTo(gradient.snp.height)
        }

        let view3 = UIView()
        gradient.addSubview(view3)
        view3.backgroundColor = .white
        view3.snp.makeConstraints { make in
            make.leading.equalTo(gradient.snp.trailing).multipliedBy(0.6)
            make.width.equalTo(1)
            make.height.equalTo(gradient.snp.height)
        }

        let view4 = UIView()
        gradient.addSubview(view4)
        view4.backgroundColor = .white
        view4.snp.makeConstraints { make in
            make.leading.equalTo(gradient.snp.trailing).multipliedBy(0.8)
            make.width.equalTo(1)
            make.height.equalTo(gradient.snp.height)
        }

        return gradient
    }()

    lazy private var indicator: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20 * 0.9 / 2
        view.layer.masksToBounds = true
        return view
    }()

    lazy private var label1: UILabel = {
        let label = UILabel()
        label.text = "내 평점: 5.0"
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    lazy private var label2: UILabel = {
        let label = UILabel()
        label.text = "백분위 100.0%"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    lazy private var label3: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .systemGray
        label.text = "경고 실제 순위가 아닙니다.\n운영 초기에는 임의의 표준분포 모형을 따른다고 가정 후 순위를 산출 합니다."
        label.textAlignment = .right
        label.numberOfLines = 3
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureSubviews() {
        contentView.addSubview(progress)
        contentView.addSubview(indicator)
        contentView.addSubview(label1)
        contentView.addSubview(label2)
        contentView.addSubview(label3)
    }

    private func configureConstraints() {
        progress.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(20).priority(800)
        }

        label1.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom).inset(-15)
            make.trailing.equalToSuperview().inset(20)
        }

        label2.snp.makeConstraints { make in
            make.top.equalTo(label1.snp.bottom).inset(-5)
            make.trailing.equalToSuperview().inset(20)
        }

        label3.snp.makeConstraints { make in
            make.top.equalTo(label2.snp.bottom).inset(-5)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }

        indicator.snp.makeConstraints { make in
            make.trailing.equalTo(progress.snp.trailing).inset(1)
            make.centerY.equalTo(progress.snp.centerY)
            make.height.equalTo(18)
            make.width.equalTo(0).priority(500)
        }
    }

    func bind(_ user: UserDTO?) {
        let avg = user?.starRatingAvg ?? 0.0
        label1.text = "내 평점: \(avg)"
        label2.text = "백분위: \(percentile(score: avg))"
        print(avg)
        score(avg)
    }

    func score(_ score: Float) {
        let percentage = score == 0 ? 0 : (5 - score) / 5
        indicator.snp.removeConstraints()

        if (score > 0) {
            indicator.snp.makeConstraints { make in
                make.trailing.equalTo(progress.snp.trailing).inset(1)
                make.centerY.equalTo(progress.snp.centerY)
                make.height.equalTo(18)
                make.width.equalTo(progress.snp.width).multipliedBy(percentage)
            }
            indicator.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            indicator.snp.makeConstraints { make in
                make.trailing.equalTo(progress.snp.trailing).inset(1)
                make.centerY.equalTo(progress.snp.centerY)
                make.height.equalTo(18)
                make.leading.equalTo(progress.snp.leading).inset(1)
            }
        }
    }

    private func percentile(score: Float) -> Float {
        let total: Float = 12.5
        var area: Float = 0.0
        if (score <= 2.5) {
            area = score * score
        } else {
            let rightSideScore: Float = score - 2.5
            area = 6.25 - (rightSideScore * rightSideScore) + (5 * rightSideScore)
        }
        return ceil(area / total * 100 * 10) / 10
    }
}