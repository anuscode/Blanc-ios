import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard
import CropViewController

private typealias AddViewCell = PostCreateAddCollectionViewCell
private typealias ResourceViewCell = PostCreateResourceCollectionViewCell

class PostCreateViewController: UIViewController {

    private class Const {
        static let navigationUserImageSize: Int = 28
        static let navigationUserLabelFont: UIFont = .systemFont(ofSize: 15)
        static let bottomViewHeight: Int = 55
        static let navigationUserImageCornerRadius: Int = {
            Const.navigationUserImageSize / 2
        }()
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    private var images: [UIImage?] = []

    private var isFirstBeginEditing = true

    var session: Session?

    var postCreateViewModel: PostCreateViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "게시물 작성"))
    }()

    lazy private var transparentView: UIView = {
        let view = UIView()
        view.visible(false)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTransparentView))
        return view
    }()

    lazy private var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .secondarySystemBackground
        textView.keyboardType = .default
        textView.sizeToFit()
        textView.layer.cornerRadius = 10
        textView.text = "글 작성은 이곳에서 가능합니다."
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return textView
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
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        let size = ((view.width - 4) * 0.8 / 3) - 2
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 3
        return layout
    }()

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .white
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
        createButton.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCreateButton))
        return view
    }()

    lazy private var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bumble3
        button.setTitle("게시글 등록", for: .normal)
        button.layer.cornerRadius = 5
        ripple.activate(to: button)
        return button
    }()

    lazy private var loadingView: LoadingView = {
        let loadingView = LoadingView()
        loadingView.visible(false)
        return loadingView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // should remove view model and model otherwise it shows the previous one.
        SwinjectStoryboard.defaultContainer.resetObjectScope(.postSingleScope)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureSubviews() {
        view.addSubview(enableCommentLabel)
        view.addSubview(enableCommentSwitch)
        view.addSubview(bottomView)
        view.addSubview(collectionView)

        view.addSubview(transparentView)
        view.addSubview(textView)
        view.addSubview(loadingView)
    }

    private func configureConstraints() {

        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalToSuperview().multipliedBy(0.8)
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
            make.width.equalToSuperview().multipliedBy(0.8)
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

    @objc func didTapCreateButton() {

        let isDescriptionRegistered = (textView.text ?? "").count > 0 && !isFirstBeginEditing
        let isImageRegistered = images.count > 0

        if (!isDescriptionRegistered && !isImageRegistered) {
            toast(title: "등록 된 내용이 없습니다.", message: "이미지 or 게시글 중 최소 한개는 반드시 충족 되야합니다.", seconds: 2.5)
            return
        }

        let files = images.filter {
            $0 != nil
        } as! [UIImage]
        let description = textView.text
        let enableComment = enableCommentSwitch.isOn

        loadingView.visible(true)

        postCreateViewModel?.createPost(
                files: files,
                description: description,
                enableComment: enableComment,
                onCompleted: { [self] in
                    DispatchQueue.main.async {
                        loadingView.visible(false)
                        toast(message: "게시물이 등록 되었습니다.") {
                            navigationController?.popViewController(animated: true)
                        }
                    }
                },
                onError: { [self] in
                    DispatchQueue.main.async {
                        loadingView.visible(false)
                        toast(message: "핑스타그램 게시물 등록에 실패 하였습니다.")
                    }
                })
    }

    @objc private func didTapTransparentView() {
        view.endEditing(true)
    }
}

extension PostCreateViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        transparentView.visible(true)
        if (isFirstBeginEditing) {
            textView.text = ""
            isFirstBeginEditing = false
        }
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddViewCell.identifier, for: indexPath) as! AddViewCell
            cell.bind(delegate: self)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResourceViewCell.identifier, for: indexPath) as! ResourceViewCell
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

        let deleteAction = UIAlertAction(title: "이미지 삭제", style: .default) { [self] (action) in
            let index = images.firstIndex(of: image)
            if (index == nil) {
                toast(message: "예상치 못한 에러가 발생 하였습니다.")
            }
            images.remove(at: index!)
            collectionView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.modalPresentationStyle = .popover

        present(alertController, animated: true, completion: nil)
    }
}

extension PostCreateViewController: PostCreateAddCollectionViewCellDelegate {
    func addImage() {
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
        UIImage.resize(image: image, maxKb: 1500) { [self] resizedImage in
            DispatchQueue.main.async {
                images.append(resizedImage)
                collectionView.reloadData()
                loadingView.visible(false)
            }
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}