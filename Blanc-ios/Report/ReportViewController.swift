import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard
import CropViewController

private typealias AddViewCell = PostCreateAddCollectionViewCell
private typealias ResourceViewCell = PostCreateResourceCollectionViewCell

class ReportViewController: UIViewController {

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

    internal var reportViewModel: ReportViewModel!

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "신고"))
    }()

    lazy private var transparentView: UIView = {
        let view = UIView()
        view.visible(false)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapTransparentView))
        return view
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()

    lazy private var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .secondarySystemBackground
        textView.keyboardType = .default
        textView.sizeToFit()
        textView.layer.cornerRadius = 10
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.rx
            .text
            .observeOn(MainScheduler.asyncInstance)
            .map({ text in text.isEmpty() })
            .subscribe(onNext: placeholder.visible)
            .disposed(by: disposeBag)
        return textView
    }()

    lazy private var placeholder: UILabel = {
        let label = UILabel()
        label.text = "신고 내용을 입력하세요."
        label.textColor = .systemGray
        return label
    }()

    lazy private var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "무분별한 신고 시 계정 정지를 당할 수 있습니다."
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        return label
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
        view.addSubview(reportButton)

        let window = UIApplication.shared.windows[0]
        let bottomPadding = window.safeAreaInsets.bottom

        reportButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(bottomPadding + 5)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(45)
        }
        return view
    }()

    lazy private var reportButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bumble3
        button.setTitle("신고 접수", for: .normal)
        button.layer.cornerRadius = 5
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapReportButton))
        ripple.activate(to: button)
        return button
    }()

    lazy private var loadingView: Spinner = {
        let view = Spinner()
        view.visible(false)
        return view
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
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func configureSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(textView)
        view.addSubview(placeholder)
        view.addSubview(warningLabel)
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        view.addSubview(transparentView)
        view.addSubview(loadingView)
    }

    private func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.equalTo(textView.snp.leading)
        }
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        placeholder.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.top).inset(23)
            make.leading.equalTo(textView.snp.leading).inset(20)
        }
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).inset(-10)
            make.leading.equalTo(textView.snp.leading)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(warningLabel.snp.bottom).inset(-20)
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
    }

    private func subscribePostCreateViewModel() {
        reportViewModel
            .reportee
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] reportee in
                let nickname = reportee.nickname ?? ""
                titleLabel.text = "\(nickname) 님을 신고합니다."
            })
            .disposed(by: disposeBag)

        reportViewModel
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        reportViewModel
            .loading
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] value in
                loadingView.visible(value)
            })
            .disposed(by: disposeBag)

        reportViewModel
            .popView
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] _ in
                navigationController?.popViewController(animated: true)
                SwinjectStoryboard.defaultContainer.resetObjectScope(.postCreateScope)
            })
            .disposed(by: disposeBag)

        reportViewModel
            .reportButton
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: reportButton.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
    }

    @objc func didTapReportButton() {
        let files = images.filter({ $0 != nil }) as! [UIImage]
        let description: String = textView.text ?? ""
        if (description.isEmpty) {
            let title = "등록 된 내용이 없습니다."
            let message = "신고 내용을 적어 주세요."
            toast(title: title, message: message)
            return
        }
        reportViewModel.report(files: files, description: description)
    }

    @objc private func didTapTransparentView() {
        view.endEditing(true)
    }
}

extension ReportViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        transparentView.visible(true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        transparentView.visible(false)
    }
}

extension ReportViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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

extension ReportViewController: PostCreateResourceCollectionViewCellDelegate {
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
                let sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.sourceView = view
                popoverController.sourceRect = sourceRect
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension ReportViewController: PostCreateAddCollectionViewCellDelegate {
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

extension ReportViewController: CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        UIImage.resize(image: image, maxKb: 1200) { [unowned self] resizedImage in
            DispatchQueue.main.async {
                images.append(resizedImage)
                collectionView.reloadData()
                loadingView.visible(false)
            }
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}