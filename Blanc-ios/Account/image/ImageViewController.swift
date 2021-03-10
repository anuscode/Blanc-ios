import CropViewController
import RxSwift
import UIKit
import Kingfisher


class ImageViewController: UIViewController, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var croppingStyle = CropViewCroppingStyle.default

    private var userService: UserService = UserService()

    private var image: UIImage?

    private var selectedImageView: UIImageView?

    internal weak var pendingViewModel: ImageViewViewModel?

    internal weak var user: UserDTO?

    lazy private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy private var imageView: UIView = {
        let view = UIView()

        view.addSubview(imageView1)
        view.addSubview(imageView2)
        view.addSubview(imageView3)
        view.addSubview(imageView4)
        view.addSubview(imageView5)
        view.addSubview(imageView6)
        view.addSubview(guideLine1)
        view.addSubview(guideLine2)
        view.addSubview(guideLine3)
        view.addSubview(guideLine4)

        let screenWidth = UIScreen.main.bounds.width
        let parentWidth = screenWidth - (20 * 2)
        let unitWidth = (parentWidth - 10) / 3

        imageView1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(unitWidth * 2 + 5)
            make.height.equalTo(unitWidth * 2 + 5)
        }

        imageView2.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(imageView1.snp.trailing).inset(-5)
            make.top.equalToSuperview()
            make.width.equalTo(unitWidth)
            make.height.equalTo(unitWidth)
        }

        imageView3.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(imageView1.snp.trailing).inset(-5)
            make.top.equalTo(imageView2.snp.bottom).inset(-5)
            make.width.equalTo(unitWidth)
            make.height.equalTo(unitWidth)
        }

        imageView4.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(imageView1.snp.bottom).inset(-5)
            make.width.equalTo(unitWidth)
            make.height.equalTo(unitWidth)
        }

        imageView5.snp.makeConstraints { make in
            make.leading.equalTo(imageView4.snp.trailing).inset(-5)
            make.top.equalTo(imageView1.snp.bottom).inset(-5)
            make.width.equalTo(unitWidth)
            make.height.equalTo(unitWidth)
        }

        imageView6.snp.makeConstraints { make in
            make.leading.equalTo(imageView5.snp.trailing).inset(-5)
            make.top.equalTo(imageView3.snp.bottom).inset(-5)
            make.width.equalTo(unitWidth)
            make.height.equalTo(unitWidth)
        }

        return view
    }()

    lazy private var imageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.tag = 0
        imageView.image = UIImage(named: "ic_avatar")
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapRecognizer)
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var imageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.tag = 1
        let image = UIImage(named: "ic_avatar")
        imageView.image = image
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapRecognizer)
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var imageView3: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.tag = 2
        let image = UIImage(named: "ic_avatar")
        imageView.image = image
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapRecognizer)
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var imageView4: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.tag = 3
        let image = UIImage(named: "ic_avatar")
        imageView.image = image
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapRecognizer)
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var imageView5: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.tag = 4
        let image = UIImage(named: "ic_avatar")
        imageView.image = image
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapRecognizer)
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var imageView6: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.tag = 5
        let image = UIImage(named: "ic_avatar")
        imageView.image = image
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapRecognizer)
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var guideLine1: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy private var guideLine2: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy private var guideLine3: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy private var guideLine4: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy private var warningView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.layer.borderColor = UIColor.systemOrange.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true

        let label = UILabel()
        label.text = "사진은 2장 이상 등록해야 합니다."
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
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

    lazy private var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    lazy private var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bumble3
        button.setTitle("검토 요청", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var spinner: Spinner = {
        Spinner()
    }()

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "이미지 변경"))
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
        log.info("deinit image view controller..")
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else {
            return
        }

        let controller = getCropViewController(image: image)
        self.image = image
        picker.dismiss(animated: true, completion: {
            self.present(controller, animated: true, completion: nil)
        })
    }

    private func configureSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
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
        bottomView.addSubview(saveButton)
        view.addSubview(bottomView)
        view.addSubview(spinner)
    }

    private func configureConstraints() {

        let screenWidth = UIScreen.main.bounds.width

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(guideImage8.snp.bottom).inset(-20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let imageViewWidth = screenWidth - (20 * 2)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(imageViewWidth)
            make.height.equalTo(imageViewWidth)
        }

        acceptableImageGuideTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(imageView6.snp.bottom).inset(-20)
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

        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view.snp.centerX)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(55)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(bottomView.snp.top)
            make.leading.equalToSuperview()
        }
    }

    private func subscribeViewModel() {
        pendingViewModel?
            .user
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] user in
                update(user)
            })
            .disposed(by: disposeBag)

        pendingViewModel?
            .loading
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] boolean in
                loading(boolean)
            })
            .disposed(by: disposeBag)

        pendingViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] message in
                toast(message)
            })
            .disposed(by: disposeBag)

        pendingViewModel?
            .imagesClickable
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] boolean in
                imagesClickable(boolean)
            })
            .disposed(by: disposeBag)

        pendingViewModel?
            .user
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] user in
                submitButtonClickable(user)
            })
            .disposed(by: disposeBag)
    }

    private func update(_ user: UserDTO) {
        let url1 = user.getTempImageUrl(index: 0)
        if url1 != "" {
            imageView1.url(url1)
        } else {
            imageView1.image = UIImage(named: "ic_avatar")
        }

        let url2 = user.getTempImageUrl(index: 1)
        if url2 != "" {
            imageView2.url(url2)
        } else {
            imageView2.image = UIImage(named: "ic_avatar")
        }

        let url3 = user.getTempImageUrl(index: 2)
        if url3 != "" {
            imageView3.url(url3)
        } else {
            imageView3.image = UIImage(named: "ic_avatar")
        }

        let url4 = user.getTempImageUrl(index: 3)
        if url4 != "" {
            imageView4.url(url4)
        } else {
            imageView4.image = UIImage(named: "ic_avatar")
        }

        let url5 = user.getTempImageUrl(index: 4)
        if url5 != "" {
            imageView5.url(url5)
        } else {
            imageView5.image = UIImage(named: "ic_avatar")
        }

        let url6 = user.getTempImageUrl(index: 5)
        if url6 != "" {
            imageView6.url(url6)
        } else {
            imageView6.image = UIImage(named: "ic_avatar")
        }
    }

    private func loading(_ value: Bool) {
        spinner.visible(value)
    }

    private func toast(_ message: String) {
        self.toast(message: message)
    }

    private func imagesClickable(_ clickable: Bool) {
        imageView1.isUserInteractionEnabled = clickable
        imageView2.isUserInteractionEnabled = clickable
        imageView3.isUserInteractionEnabled = clickable
        imageView4.isUserInteractionEnabled = clickable
        imageView5.isUserInteractionEnabled = clickable
        imageView6.isUserInteractionEnabled = clickable
    }

    private func submitButtonClickable(_ user: UserDTO) {
        if user.status == .OPENED {
            saveButton.isUserInteractionEnabled = true
            saveButton.backgroundColor = UIColor.bumble3.withAlphaComponent(1)
        } else {
            saveButton.isUserInteractionEnabled = false
            saveButton.backgroundColor = UIColor.bumble3.withAlphaComponent(0.6)
        }
    }

    private func getCropViewController(image: UIImage) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = self
        cropViewController.title = "이미지 영역을 선택 하세요."
        cropViewController.aspectRatioPreset = .presetSquare; // Set the initial aspect ratio as a square
        cropViewController.aspectRatioLockEnabled = true  // The crop box is locked to the aspect ratio and can't be resized away from it
        cropViewController.resetAspectRatioEnabled = false  // When tapping 'reset', the aspect ratio will NOT be reset back to default
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.rotateButtonsHidden = true
        cropViewController.rotateClockwiseButtonHidden = true
        cropViewController.doneButtonTitle = "확인"
        cropViewController.cancelButtonTitle = "취소"
        return cropViewController
    }

    public func cropViewController(_ cropViewController: CropViewController,
                                   didCropToImage image: UIImage,
                                   withRect cropRect: CGRect,
                                   angle: Int) {
        imagesClickable(false)
        spinner.visible(true)

        UIImage.resize(image: image, maxKb: 800) { [unowned self] resizedImage in
            guard let resizedImage = resizedImage else {
                toast(message: "이미지 리사이즈 도중 에러가 발생 하였습니다.")
                return
            }
            DispatchQueue.main.async {
                updateImageViewWithImage(resizedImage, cropViewController: cropViewController)
            }
            pendingViewModel?.uploadUserImage(index: selectedImageView?.tag, file: resizedImage)
        }
    }

    public func updateImageViewWithImage(_ image: UIImage, cropViewController: CropViewController) {
        selectedImageView?.image = image
        selectedImageView?.contentMode = .scaleAspectFill
        selectedImageView?.clipsToBounds = true
        cropViewController.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapSaveButton() {
        pendingViewModel?.updateUserStatusPending(onSuccess: {
            self.navigationController?.popToRootViewController(animated: true)
        })
    }

    @objc public func didTapImage(sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let imagePickerAction = UIAlertAction(title: "이미지 지정", style: .default) { (action) in
            self.selectedImageView = (sender.view as! UIImageView)
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }

        let deleteAction = UIAlertAction(title: "이미지 삭제", style: .default) { [unowned self] (action) in
            let imageView = sender.view as! UIImageView
            imageView.image = UIImage(named: "ic_avatar")
            pendingViewModel?.deleteUserImage(index: imageView.tag)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        alertController.addAction(cancelAction)
        alertController.addAction(imagePickerAction)
        alertController.addAction(deleteAction)
        alertController.modalPresentationStyle = .popover

        let presentationController = alertController.popoverPresentationController
        presentationController?.barButtonItem = (sender as! UIBarButtonItem)
        present(alertController, animated: true, completion: nil)
    }
}

