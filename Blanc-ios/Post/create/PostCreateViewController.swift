import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard
import CropViewController

private typealias AddViewCell = AddCollectionViewCell
private typealias ResourceViewCell = AddResourceCollectionViewCell

class PostCreateViewController: UIViewController {

    private class Const {
        static let navigationUserImageSize: Int = 28
        static let navigationUserLabelFont: UIFont = .systemFont(ofSize: 15)
        static let bottomViewHeight: Int = 55
        static let navigationUserImageCornerRadius: Int = {
            Const.navigationUserImageSize / 2
        }()
    }

    private var disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    private var images: [UIImage?] = []

    private var isFirstBeginEditing = true

    internal var postCreateViewModel: PostCreateViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "글 작성"))
    }()

    lazy private var transparentView: UIView = {
        let view = UIView()
        view.visible(false)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTransparentView))
        return view
    }()

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
        textView.keyboardType = .default
        textView.sizeToFit()
        textView.layer.cornerRadius = 10
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.rx
            .text
            .observeOn(MainScheduler.asyncInstance)
            .map({ text in !text.isEmpty() })
            .bind(to: placeholder.rx.isHidden)
            .disposed(by: disposeBag)
        return textView
    }()

    lazy private var placeholder: UILabel = {
        let label = UILabel()
        label.text = "하고싶은 말을 입력 하세요."
        label.textColor = .darkGray
        return label
    }()

    lazy private var enableCommentLabel: UILabel = {
        let label = UILabel()
        label.text = "댓글 허용"
        label.textColor = .darkGray
        return label
    }()

    lazy private var enableCommentSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.setOn(true, animated: true)
        return switchControl
    }()

    lazy private var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
        let size = ((view.width - 20) / 3) - 4
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 6
        return layout
    }()

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        collectionView.register(AddViewCell.self, forCellWithReuseIdentifier: AddViewCell.identifier)
        collectionView.register(ResourceViewCell.self, forCellWithReuseIdentifier: ResourceViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    lazy private var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubview(createButton)

        let window = UIApplication.shared.windows[0]
        let bottomPadding = window.safeAreaInsets.bottom

        createButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(bottomPadding + 5)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(45)
        }
        return view
    }()

    lazy private var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bumble3
        button.setTitle("게시글 등록", for: .normal)
        button.layer.cornerRadius = 5
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCreateButton))
        ripple.activate(to: button)
        return button
    }()

    lazy private var loadingView: Spinner = {
        let spinner = Spinner()
        spinner.visible(false)
        return spinner
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.barTintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribePostCreateViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // should remove view model and model otherwise it shows the previous one.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        log.info("deinit PostCreateViewController..")
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(textView)
        view.addSubview(placeholder)
        view.addSubview(enableCommentLabel)
        view.addSubview(enableCommentSwitch)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        view.addSubview(transparentView)
        view.addSubview(loadingView)
    }

    private func configureConstraints() {
        starFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(300)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        placeholder.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.top).inset(23)
            make.leading.equalTo(textView.snp.leading).inset(20)
        }
        enableCommentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(enableCommentSwitch.snp.centerY)
            make.trailing.equalTo(enableCommentSwitch.snp.leading).inset(-10)
        }
        enableCommentSwitch.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).inset(-10)
            make.trailing.equalTo(textView.snp.trailing)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(enableCommentSwitch.snp.bottom).inset(-10)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(bottomView.snp.top).inset(-30)
        }
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        transparentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribePostCreateViewModel() {
        postCreateViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        postCreateViewModel?
            .loading
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] value in
                loadingView.visible(value)
            })
            .disposed(by: disposeBag)

        postCreateViewModel?
            .popView
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] _ in
                navigationController?.popViewController(animated: true)
                SwinjectStoryboard.defaultContainer.resetObjectScope(.postCreateScope)
                disposeBag = DisposeBag()
            })
            .disposed(by: disposeBag)

        postCreateViewModel?
            .createButton
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: createButton.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
    }

    @objc func didTapCreateButton() {

        let isDescriptionRegistered = textView.text.isNotEmpty()
        let isImageRegistered = images.count > 0

        if (!isDescriptionRegistered && !isImageRegistered) {
            let title = "등록 된 내용이 없습니다."
            let message = "이미지, 게시글 중 최소 한개는 반드시 충족 되야합니다."
            toast(title: title, message: message)
            return
        }

        let files = images.filter({ $0 != nil }) as! [UIImage]
        let description = textView.text
        let enableComment = enableCommentSwitch.isOn

        postCreateViewModel?.createPost(files: files, description: description, enableComment: enableComment)
    }

    @objc private func didTapTransparentView() {
        view.endEditing(true)
    }
}

extension PostCreateViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        transparentView.visible(true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        transparentView.visible(false)
    }
}

extension PostCreateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == images.count) {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddViewCell.identifier, for: indexPath) as! AddViewCell
            cell.bind(delegate: self)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ResourceViewCell.identifier, for: indexPath) as! ResourceViewCell
            cell.bind(images[indexPath.row], delegate: self)
            return cell
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

extension PostCreateViewController: PostCreateResourceCollectionViewCellDelegate {
    func delete(image: UIImage?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "이미지 삭제", style: .default) { [unowned self] (action) in
            guard let index = images.firstIndex(of: image) else {
                toast(message: "예상치 못한 에러가 발생 하였습니다.")
                return
            }
            images.remove(at: index)
            collectionView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.modalPresentationStyle = .popover

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension PostCreateViewController: PostCreateAddCollectionViewCellDelegate {
    func addImage() {
        if (images.count >= 3) {
            toast(message: "사진은 3장까지 허용 됩니다.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

extension PostCreateViewController: CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else {
            return
        }
        let controller = CropViewController.getCropViewController(delegate: self, image: image)
        picker.dismiss(animated: true, completion: {
            self.present(controller, animated: true, completion: nil)
        })
    }

    public func cropViewController(_ cropViewController: CropViewController,
                                   didCropToImage image: UIImage,
                                   withRect cropRect: CGRect,
                                   angle: Int) {
        loadingView.visible(true)
        UIImage.resize(image: image) { [unowned self] resizedImage in
            DispatchQueue.main.async {
                images.append(resizedImage)
                collectionView.reloadData()
                loadingView.visible(false)
            }
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}