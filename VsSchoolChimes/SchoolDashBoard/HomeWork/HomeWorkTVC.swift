import UIKit
import UniformTypeIdentifiers

class HomeWorkTVC: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var newView: UIImageView!
    @IBOutlet weak var forwordBtn: UIButton!
    @IBOutlet weak var dateLble: ShimmerLabel!
    @IBOutlet weak var descriptionLbl: ShimmerLabel!
    @IBOutlet weak var topics: ShimmerLabel!
    @IBOutlet weak var pageViewController: UIPageControl!
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    @IBOutlet weak var subjectName: ShimmerLabel!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var SelectBtnHeight: NSLayoutConstraint!

    var delegate: SelectNotice?
    var ishomework = false
    var isreciver = false
    var issenderEvent = false
    var homeworkDocs: [FilePath]?
    var countShimmer = 0

    private var docController: UIDocumentInteractionController?

    override func awakeFromNib() {
        super.awakeFromNib()

        dateLble.setFont(style: .body, size: FontSize.BodySize)
        descriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        topics.setFont(style: .title, size: FontSize.TitleSize)
        forwordBtn.layer.cornerRadius = 4
        forwordBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        cellview.layer.cornerRadius = 10
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false

        let collection = UINib(nibName: CellConfingName.ImagePdfCvCell, bundle: nil)
        ImageCollectionView.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)

        ImageCollectionView.delegate = self
        ImageCollectionView.dataSource = self

        pageViewController.numberOfPages = homeworkDocs?.count ?? 0

        if let flowLayout = ImageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 10
        }

        ImageCollectionView.reloadData()
        countShimmer = 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureShimmer()
    }

    func configureShimmer() {
        dateLble.removeShimmer()
        descriptionLbl.removeShimmer()
        topics.removeShimmer()
        subjectName.removeShimmer()
    }

    func loadImage(urls: [FilePath]) {
        homeworkDocs = urls
        ImageCollectionView.reloadData()
    }

    @IBAction func forword(_ sender: UIButton) {
        delegate?.didTapButton(title: topics.text ?? "", content: descriptionLbl.text ?? "", items: homeworkDocs ?? [])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeworkDocs?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        if let img = homeworkDocs?[indexPath.row] {
            cell.imageView.sd_setImage(with: URL(string: img.path ?? ""), placeholderImage: ImageName.placeholder)
            let fileURL = URL(fileURLWithPath: img.path ?? "")
            let iconName = getFileIconName(for: fileURL)
            let iconImage = UIImage(named: iconName)
            cell.IndicaterImageView.image = iconImage
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: ImageCollectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = homeworkDocs?[indexPath.row], let urlString = file.path, let url = URL(string: urlString) else { return }
        let fileExtension = url.pathExtension.lowercased()
        
//        if isWebViewPreviewable(fileExtension) || file.type?.lowercased() == "image" {
            let vc = getCurrentViewController()
            let vcc = ImageShowVc(nibName: nil, bundle: nil)
            vcc.imageURL = homeworkDocs ?? []
            vcc.subjectName = subjectName.text
            vcc.type = 2
            vcc.modalPresentationStyle = .fullScreen
            vc?.present(vcc, animated: true)
//        } else {
//                openWithDocumentInteraction(url: url)
//        }
    }

//    func isWebViewPreviewable(_ ext: String) -> Bool {
//        return ["pdf", "txt", "docx", "pptx", "xlsx"].contains(ext)
//    }
    func isWebViewPreviewable(_ ext: String) -> Bool {
        return ["pdf", "txt"].contains(ext.lowercased())
    }

    func openWithDocumentInteraction(url: URL) {
        docController = UIDocumentInteractionController(url: url)
        docController?.delegate = getCurrentViewController() as? UIDocumentInteractionControllerDelegate

        if !(docController?.presentPreview(animated: true) ?? false) {
            let fileExtension = url.pathExtension.lowercased()
            let appSuggestion = getAppSuggestion(for: fileExtension)

            let alert = UIAlertController(
                title: "App Required",
                message: "To open this '\(fileExtension)' file, please install a suitable app. For example: \(appSuggestion).",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            getCurrentViewController()?.present(alert, animated: true)
        }
    }

    func getAppSuggestion(for ext: String) -> String {
        switch ext {
        case "pdf":
            return "Adobe Acrobat Reader"
        case "doc", "docx":
            return "Microsoft Word or WPS Office"
        case "ppt", "pptx":
            return "Microsoft PowerPoint"
        case "xls", "xlsx":
            return "Microsoft Excel"
        case "txt", "rtf":
            return "Notepad++ or Apple Notes"
        default:
            return "a compatible document viewer"
        }
    }


    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
}

// MARK: - TopMost VC helper
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
