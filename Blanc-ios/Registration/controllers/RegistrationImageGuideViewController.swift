import Foundation
import UIKit

class RegistrationImageGuideViewController: UIViewController {

    lazy private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy private var acceptableImageGuideTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 이런 사진으로 올려주세요."
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy private var rejectableImageGuideTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "2. 이런 사진은 반려 될 수 있습니다."
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    lazy private var guideImage1: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_1_1")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var guideImage2: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_1_2")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var guideImage3: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_2_1")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var guideImage4: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_2_2")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var guideImage5: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_3_1")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var guideImage6: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_3_2")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var guideImage7: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_4_1")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var guideImage8: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "image_guide_4_2")
        imageView.image = image
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 5
        return imageView
    }()

    lazy private var bottomGuideLine: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "블랑 이미지 가이드"
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    deinit {
        log.info("deinit registration image guide view controller..")
    }

    private func configureSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(acceptableImageGuideTitleLabel)
        scrollView.addSubview(guideImage1)
        scrollView.addSubview(guideImage2)
        scrollView.addSubview(guideImage3)
        scrollView.addSubview(guideImage4)
        scrollView.addSubview(rejectableImageGuideTitleLabel)
        scrollView.addSubview(guideImage5)
        scrollView.addSubview(guideImage6)
        scrollView.addSubview(guideImage7)
        scrollView.addSubview(guideImage8)
    }

    private func configureConstraints() {

        let screenWidth = UIScreen.main.bounds.width

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(guideImage8.snp.bottom).inset(-20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        acceptableImageGuideTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(RConfig.titleTopMargin)
        }

        let guideImageWidth = (screenWidth - 20 * 3) / 2
        guideImage1.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(acceptableImageGuideTitleLabel.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        guideImage2.snp.makeConstraints { make in
            make.leading.equalTo(guideImage1.snp.trailing).inset(-20)
            make.top.equalTo(acceptableImageGuideTitleLabel.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        guideImage3.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(guideImage1.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        guideImage4.snp.makeConstraints { make in
            make.leading.equalTo(guideImage3.snp.trailing).inset(-20)
            make.top.equalTo(guideImage1.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        rejectableImageGuideTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(guideImage4.snp.bottom).inset(-20)
        }

        guideImage5.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(rejectableImageGuideTitleLabel.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        guideImage6.snp.makeConstraints { make in
            make.leading.equalTo(guideImage5.snp.trailing).inset(-20)
            make.top.equalTo(rejectableImageGuideTitleLabel.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        guideImage7.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(guideImage5.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        guideImage8.snp.makeConstraints { make in
            make.leading.equalTo(guideImage7.snp.trailing).inset(-20)
            make.top.equalTo(guideImage5.snp.bottom).inset(-20)
            make.width.equalTo(guideImageWidth)
            make.height.equalTo(guideImageWidth)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
        }
    }
}
