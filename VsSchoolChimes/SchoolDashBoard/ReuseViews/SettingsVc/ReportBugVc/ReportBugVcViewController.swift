import UIKit
import PhotosUI
import UniformTypeIdentifiers
import MessageUI
import AVFoundation

@available(iOS 14.0, *)
class ReportBugVcViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var remarkDefaultLbl: UILabel!
    @IBOutlet weak var selectDefaultLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var BugsTextview: UITextView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var AttachmentView: ImageSelection!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var ModuleDropDown: UIView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var selectModuleLbl: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var textViewStack: UIStackView!
    @IBOutlet weak var outerView: UIView!

    // MARK: - Properties
    var attachments: [Attachments] = []
    let dropDown = DropDown()
    var docController: UIDocumentInteractionController?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickerCallbacks()
        setupCollectionView()
        ModuleDropDown.setShadow()
        noteView.layer.cornerRadius = 10
        sendBtn.layer.cornerRadius = 10
    }

    // MARK: - UI Setup
    func setupUI() {
        BugsTextview.text = "Type content"
        BugsTextview.textColor = .lightGray
        BugsTextview.delegate = self
        BugsTextview.layer.cornerRadius = 8
        BugsTextview.layer.borderWidth = 0.5
        BugsTextview.layer.borderColor = UIColor.lightGray.cgColor
        scrollView.keyboardDismissMode = .interactive
        remarkDefaultLbl.setRequiredText("Remarks")
        selectDefaultLbl.setRequiredText("Select Module")
        hideKeyboardWhenSwipedDown()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(categoryDropdown))
        ModuleDropDown.addGestureRecognizer(gesture)
    }

    func hideKeyboardWhenSwipedDown() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        swipeDown.delegate = self
        view.addGestureRecognizer(swipeDown)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

    func setupCollectionView() {
        AttachmentView.imageCollectionview.delegate = self
        AttachmentView.imageCollectionview.dataSource = self
    }

    // MARK: - Picker Callbacks
    func setupPickerCallbacks() {
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            let added = images.map { Attachments(image: $0, videoURL: nil, fileType: "image", displayName: "image.jpg") }
            self.attachments.append(contentsOf: added)
            self.AttachmentView.imageCollectionview.reloadData()
            self.adjustHeight()
        }

        PhotoPickerManager.shared.onVideoPicked = { [weak self] url in
            guard let self = self else { return }
            let item = Attachments(image: nil, videoURL: url, fileType: "video", displayName: "video.mp4")
            self.attachments.append(item)
            self.AttachmentView.imageCollectionview.reloadData()
            self.adjustHeight()
        }
    }

    func adjustHeight() {
        let rows = ceil(CGFloat(attachments.count + 1) / 3.0)
        collectionViewHeight.constant = rows * 110
    }

    // MARK: - TextView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if BugsTextview.text == "Type content" {
            BugsTextview.text = ""
            BugsTextview.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if BugsTextview.text.isEmpty {
            BugsTextview.text = "Type content"
            BugsTextview.textColor = .lightGray
        }
    }

    // MARK: - Dropdown
    @objc func categoryDropdown() {
        dropDown.dataSource = user_inputs.menuList
        dropDown.anchorView = ModuleDropDown
        dropDown.bottomOffset = CGPoint(x: 0, y: ModuleDropDown.frame.height)
        dropDown.direction = .bottom
        dropDown.selectionAction = { [weak self] index, item in
            self?.selectModuleLbl.text = item
        }
        dropDown.show()
    }

    // MARK: - Send Button
    @IBAction func SendBtnAct(_ sender: Any) {
        let module = selectModuleLbl.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let details = BugsTextview.text.trimmingCharacters(in: .whitespacesAndNewlines)

            let modulePlaceholder = "Select the menu"
            let detailsPlaceholder = "Type Content"
            let isModuleEmpty = module.isEmpty || module == modulePlaceholder
            let isDetailsEmpty = details.isEmpty || details == detailsPlaceholder
            if isModuleEmpty && isDetailsEmpty {
                showAlert(title: "Missing Information",
                          message: "Please select a module and enter bug details.")
                return
            }
            if isModuleEmpty {
                showAlert(title: "Missing Module",
                          message: "Please select a module.")
                return
            }
            if isDetailsEmpty {
                showAlert(title: "Missing Details",
                          message: "Please enter bug details.")
                return
            }

            // Case 4: All good
            sendEmailWithAttachmentsToGmail()
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Gmail / Share Sheet
    func sendEmailWithAttachmentsToGmail() {

        let toEmail = "support@gmail.com"
        let ccEmails = "team@gmail.com,dev@gmail.com"
        let subject = "Bug Report - \(selectModuleLbl.text ?? "")"
        let body = BugsTextview.text ?? ""

        let gmailURLString =
            "googlegmail://co?to=\(toEmail)&cc=\(ccEmails)&subject=\(subject)&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let gmailURL = URL(string: gmailURLString),
           UIApplication.shared.canOpenURL(gmailURL) {
            UIApplication.shared.open(gmailURL)

        } else {
            let gmailWebURLString =
                "https://mail.google.com/mail/u/0/?view=cm&to=\(toEmail)&cc=\(ccEmails)&su=\(subject)&body=\(body)"
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            if let gmailWebURL = URL(string: gmailWebURLString) {
                UIApplication.shared.open(gmailWebURL)
            }
        }

        // Attachments
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var items: [Any] = []

            for item in self.attachments {
                if let img = item.image,
                   let data = img.jpegData(compressionQuality: 0.8) {
                    let tempURL = self.saveTempFile(
                        data: data,
                        fileName: item.displayName ?? "image.jpg"
                    )
                    items.append(tempURL)
                }

                if let url = item.videoURL {
                    items.append(url)
                }
            }

            let activityVC = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true)
        }
    }
    func saveTempFile(data: Data, fileName: String) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: url)
        return url
    }

    // MARK: - iOS Mail (optional)
    func composeEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert("Mail is not configured on this device")
            return
        }

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["support@example.com"])
        mail.setSubject("Bug Report - \(selectModuleLbl.text ?? "")")
        mail.setMessageBody(BugsTextview.text, isHTML: false)

        for item in attachments {
            if let img = item.image,
               let data = img.jpegData(compressionQuality: 0.8) {
                mail.addAttachmentData(data, mimeType: "image/jpeg", fileName: item.displayName ?? "image.jpg")
            }
            if let url = item.videoURL,
               let data = try? Data(contentsOf: url) {
                mail.addAttachmentData(data, mimeType: getMimeType(for: url), fileName: url.lastPathComponent)
            }
        }
        present(mail, animated: true)
    }

    func getMimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "pdf": return "application/pdf"
        default: return "application/octet-stream"
        }
    }

    func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - CollectionView
@available(iOS 14.0, *)
extension ReportBugVcViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count + 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCVCell", for: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCvCell", for: indexPath) as! ImageCvCell
        let item = attachments[indexPath.item - 1]

        cell.imageViews.image = item.image ?? UIImage(named: "file_icon")
        cell.deleteBtn.tag = indexPath.item - 1
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let alert = UIAlertController(title: "Select", message: "Choose option", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { _ in
                PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 10 - self.attachments.count), from: self)
            }))
            alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
                PhotoPickerManager.shared.presentPicker(ofType: .video, from: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }

        let item = attachments[indexPath.item - 1]
        let vc = PreviewImageVC()
        vc.modalPresentationStyle = .fullScreen

        if item.fileType == "image" {
            vc.img = item.image
        } else {
            vc.selectedFileURL = item.videoURL
        }

        vc.type = item.fileType
        present(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.frame.width - 20) / 3
        return CGSize(width: w, height: w)
    }
}

// MARK: - Delete Protocol
@available(iOS 14.0, *)
extension ReportBugVcViewController: DeleteImge {
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        AttachmentView.imageCollectionview.reloadData()
        adjustHeight()
    }
}

// MARK: - Swipe Down Gesture Delegate
@available(iOS 14.0, *)
extension ReportBugVcViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: AttachmentView.imageCollectionview) == true {
            return false
        }
        return true
    }
}

// MARK: - Attachment Struct
struct Attachments {
    var image: UIImage?
    var videoURL: URL?
    var fileType: String
    var displayName: String?
}
