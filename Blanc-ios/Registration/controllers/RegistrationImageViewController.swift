import CropViewController
import RxSwift
import UIKit
import Kingfisher


class RegistrationImageViewController: UIViewController, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let disposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var userService: UserService = UserService()

    private var image: UIImage?

    private var selectedImageView: UIImageView?

    private var user: UserDTO?

    internal var registrationViewModel: RegistrationViewModel?

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 15 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "이미지 등록"
        label.font = UIFont.boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var imageView: UIView = {
        let view = UIView()

        view.addSubview(imageView1)
        view.addSubview(imageView2)
        view.addSubview(imageView3)
        view.addSubview(imageView4)
        view.addSubview(imageView5)
        view.addSubview(imageView6)

        view.addSubview(necessaryLabel1)
        view.addSubview(necessaryLabel2)

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

        necessaryLabel1.snp.makeConstraints { make in
            make.trailing.equalTo(imageView1.snp.trailing).inset(10)
            make.top.equalTo(imageView1.snp.top).inset(10)
        }

        necessaryLabel2.snp.makeConstraints { make in
            make.trailing.equalTo(imageView2.snp.trailing).inset(10)
            make.top.equalTo(imageView2.snp.top).inset(10)
        }

        return view
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 2개 이상의 사진이 요구 됩니다."
        label.font = UIFont.systemFont(ofSize: RConfig.noticeSize)
        label.numberOfLines = 4;
        label.textColor = .black
        return label
    }()

    lazy private var necessaryLabel1: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true

        let label = UILabel()
        label.text = "필수"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.top.equalToSuperview().inset(2)
            make.bottom.equalToSuperview().inset(2)
        }
        return view
    }()

    lazy private var necessaryLabel2: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        let label = UILabel()
        label.text = "필수"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.top.equalToSuperview().inset(2)
            make.bottom.equalToSuperview().inset(2)
        }
        return view
    }()

    lazy private var imageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
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
        imageView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
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
        imageView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
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
        imageView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
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
        imageView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
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
        imageView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.8)
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

    lazy private var saveButton: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true

        let label = UILabel()
        label.text = "가입 완료"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapSaveButton))
        ripple.activate(to: view)
        return view
    }()

    lazy private var spinner: Spinner = {
        Spinner()
    }()

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

    public func cropViewController(_ cropViewController: CropViewController,
                                   didCropToImage image: UIImage,
                                   withRect cropRect: CGRect,
                                   angle: Int) {
        configureImagesClickable(false)
        spinner.visible(true)
        cropViewController.dismiss(animated: true, completion: nil)

        UIImage.resize(image: image, maxKb: 1000) { [unowned self] resizedImage in
            DispatchQueue.main.async {
                updateImageViewWithImage(resizedImage!, cropViewController: cropViewController)
            }

            guard resizedImage != nil else {
                spinner.visible(false)
                configureImagesClickable(true)
                toast(message: "이미지 업로드에 실패 하였습니다.")
                selectedImageView?.image = UIImage(named: "ic_avatar")
                return
            }

            registrationViewModel?.uploadUserImage(
                index: selectedImageView?.tag,
                file: resizedImage!,
                onSuccess: {
                    DispatchQueue.main.async {
                        spinner.visible(false)
                        configureImagesClickable(true)
                    }
                },
                onError: {
                    DispatchQueue.main.async {
                        spinner.visible(false)
                        configureImagesClickable(true)
                        toast(message: "이미지 업로드에 실패 하였습니다.")
                        selectedImageView?.image = UIImage(named: "ic_avatar")
                    }
                }
            )
        }
    }

    public func updateImageViewWithImage(_ image: UIImage, cropViewController: CropViewController) {
        selectedImageView?.image = image
        selectedImageView?.contentMode = .scaleAspectFill
        selectedImageView?.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(noticeLabel)
        view.addSubview(spinner)
        view.addSubview(saveButton)
    }

    private func configureConstraints() {

        let screenWidth = UIScreen.main.bounds.width

        starFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        progressView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(RConfig.progressTopMargin)
            make.height.equalTo(3)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(progressView.snp.bottom).offset(RConfig.titleTopMargin)
        }

        let imageViewWidth = screenWidth - (20 * 2)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(imageViewWidth)
            make.height.equalTo(imageViewWidth)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(imageView.snp.bottom).offset(RConfig.noticeTopMargin)
        }

        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?.observe()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] userDTO in
                user = userDTO
                DispatchQueue.main.async {
                    update(userDTO)
                }
            }, onError: { [unowned self] err in
                log.error(err)
                toast(message: "알 수 없는 에러가 발생 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func update(_ userDTO: UserDTO) {
        let url1 = userDTO.getTempImageUrl(index: 0)
        if url1 != "" {
            imageView1.url(url1)
            necessaryLabel1.visible(false)
        } else {
            imageView1.image = UIImage(named: "ic_avatar")
            necessaryLabel1.visible(true)
        }

        let url2 = userDTO.getTempImageUrl(index: 1)
        if url2 != "" {
            imageView2.url(url2)
            necessaryLabel2.visible(false)
        } else {
            imageView2.image = UIImage(named: "ic_avatar")
            necessaryLabel2.visible(true)
        }

        let url3 = userDTO.getTempImageUrl(index: 2)
        if url3 != "" {
            imageView3.url(url3)
        } else {
            imageView3.image = UIImage(named: "ic_avatar")
        }

        let url4 = userDTO.getTempImageUrl(index: 3)
        if url4 != "" {
            imageView4.url(url4)
        } else {
            imageView4.image = UIImage(named: "ic_avatar")
        }

        let url5 = userDTO.getTempImageUrl(index: 4)
        if url5 != "" {
            imageView5.url(url5)
        } else {
            imageView5.image = UIImage(named: "ic_avatar")
        }

        let url6 = userDTO.getTempImageUrl(index: 5)
        if url6 != "" {
            imageView6.url(url6)
        } else {
            imageView6.image = UIImage(named: "ic_avatar")
        }
    }

    private func getCropViewController(image: UIImage) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: .default, image: image)
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

    private func configureImagesClickable(_ clickable: Bool) {
        imageView1.isUserInteractionEnabled = clickable
        imageView2.isUserInteractionEnabled = clickable
        imageView3.isUserInteractionEnabled = clickable
        imageView4.isUserInteractionEnabled = clickable
        imageView5.isUserInteractionEnabled = clickable
        imageView6.isUserInteractionEnabled = clickable
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
            if (user?.getTempImageUrl(index: imageView.tag).isEmpty ?? true) {
                toast(message: "등록 된 이미지가 없습니다.")
                return
            }
            imageView.image = UIImage(named: "ic_avatar")
            registrationViewModel?.deleteUserImage(index: imageView.tag)
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

    @objc private func didTapSaveButton() {

        let isRequiredImage1Registered = user?.userImagesTemp?.first {
            $0.index == 0
        } != nil

        let isRequiredImage2Registered = user?.userImagesTemp?.first {
            $0.index == 1
        } != nil

        if (!isRequiredImage1Registered) {
            toast(message: "메인 이미지는 필수 사항입니다.")
            return
        }

        if (!isRequiredImage2Registered) {
            toast(message: "필수 이미지가 등록 되지 않았습니다.")
            return
        }

        spinner.visible(true)
        registrationViewModel?.updateUserStatusPending(
            onSuccess: { [unowned self] in
                DispatchQueue.main.async {
                    spinner.visible(false)
                    presentPendingViewController()
                }
            },
            onError: { [unowned self] in
                DispatchQueue.main.async {
                    spinner.visible(false)
                    toast(message: "심사 요청에 실패 하였습니다.")
                }
            }
        )
    }

    private func presentPendingViewController() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "PendingViewController", animated: true)
    }
}

