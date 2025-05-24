//
//  AssignmentListCTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit
protocol SumitionDelegate{
    func sumition(index:Int)
}
class AssignmentListCTVC: UITableViewCell {
    
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var SendBySecLbl: UILabel!
    @IBOutlet weak var SubCountSec: UILabel!
    @IBOutlet weak var DueSecLbl: UILabel!
    @IBOutlet weak var CategorySecLbl: UILabel!
    @IBOutlet weak var imgHeght: NSLayoutConstraint!
    @IBOutlet weak var spirelview: UIView!
    @IBOutlet weak var outImg: UIImageView!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var sendByLbl: UILabel!
    @IBOutlet weak var sumissionLbl: UILabel!
    @IBOutlet weak var dueDateLbl: UILabel!
    @IBOutlet weak var CreaterdDate: UILabel!
    @IBOutlet weak var SubmitedBtn: UIButton!
    @IBOutlet weak var NotSubmitedBtn: UIButton!
    @IBOutlet weak var ForwardBtn: UIButton!
    @IBOutlet weak var AttachmentCV: UICollectionView!
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var cvBaseview: UIView!
    @IBOutlet weak var PageController: UIPageControl!
    
    var didSelectDelegate : DidSelectDelegate?
    var Delegate : SumitionDelegate?
    var FilesUrl : [FilePath]?
    
       override func awakeFromNib() {
           super.awakeFromNib()
           
           spirelview.layer.cornerRadius = 10
           spirelview.layer.shadowColor = UIColor.black.cgColor
           spirelview.layer.shadowOffset = CGSize(width: 4, height: 4)
           spirelview.layer.shadowRadius = 3
           spirelview.layer.shadowOpacity = 0.5
           spirelview.layer.masksToBounds = false
           outImg.translatesAutoresizingMaskIntoConstraints = false
           SubmitedBtn.layer.cornerRadius = 10
           NotSubmitedBtn.layer.cornerRadius = 10
           SubmitBtn.layer.cornerRadius = 10
           
           ForwardBtn.layer.cornerRadius = 4
           
           cvBaseview.layer.cornerRadius = 10
           cvBaseview.layer.shadowColor = UIColor.black.cgColor
           cvBaseview.layer.shadowOffset = CGSize(width: 0, height: 2)
           cvBaseview.layer.shadowRadius = 5
           cvBaseview.layer.shadowOpacity = 0.3
           cvBaseview.layer.masksToBounds = false
           
           AttachmentCV.layer.masksToBounds = true
           AttachmentCV.layer.cornerRadius = 10
           
           //MARK: Label Font
           SendBySecLbl.setFont(style: .body, size: FontSize.BodySize)
           SubCountSec.setFont(style: .body, size: FontSize.BodySize)
           DueSecLbl.setFont(style: .body, size: FontSize.BodySize)
           CategorySecLbl.setFont(style: .body, size: FontSize.BodySize)
           SubjectLabel.setFont(style: .title, size: FontSize.TitleSize)
           DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)

           
           tittleLbl.setFont(style: .title, size: FontSize.TitleSize)
           categoryLbl.setFont(style: .body, size: FontSize.BodySize)
           sendByLbl.setFont(style: .body, size: FontSize.BodySize)
           sumissionLbl.setFont(style: .body, size: FontSize.BodySize)
           dueDateLbl.setFont(style: .body, size: FontSize.BodySize)
           CreaterdDate.setFont(style: .body, size: FontSize.BodySize)

           //MARK: Button Font
           SubmitedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           NotSubmitedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           ForwardBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           
           let collection = UINib(nibName:CellConfingName.ImagePdfCvCell, bundle: nil)
           AttachmentCV.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
           
           AttachmentCV.delegate = self
           AttachmentCV.dataSource = self

       }

       override func layoutSubviews() {
           super.layoutSubviews()
           let contentViewHeight = contentView.frame.height - 30
           imgHeght.constant = contentViewHeight
       }
    
    @IBAction func viewAssignment(_ sender: UIButton) {
        didSelectDelegate?.select(index: 1, value:"\(sender.tag)",Img:[""],Pdf:"https://icseindia.org/document/sample.pdf",text:"sjedgwvfefjd xuvu dvs dhv sshgdvsg",type:"")
    }
    
}

extension AssignmentListCTVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return FilesUrl?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = AttachmentCV.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        
        if let img = FilesUrl?[indexPath.row] {
            let fileURL = URL(fileURLWithPath: img.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            if iconName != "image" {
                if let pdfURL = URL(string: img.url ?? "") {
                    let request = URLRequest(url: pdfURL)
                    cell.webView.load(request)
                    cell.webView.isHidden = false
                    cell.webView.isUserInteractionEnabled = false  // ✅ Add this
                    cell.webView.scrollView.isScrollEnabled = false // ✅ Optional
                    cell.imageView.isHidden = true
                } else {
                    cell.webView.isHidden = true
                    cell.imageView.isHidden = false
                }
            } else {
                cell.webView.isHidden = true
                cell.imageView.isHidden = false
                cell.imageView.sd_setImage(with: URL(string: img.url ?? ""), placeholderImage: ImageName.placeholder)
            }
            let iconImage = UIImage(named: iconName)
            cell.IndicaterImageView.image = iconImage
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt")
        guard let file = FilesUrl?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
                let fileExtension = url.pathExtension.lowercased()
        
                //        if isWebViewPreviewable(fileExtension) || file.type?.lowercased() == "image" {
        
                let vc = getCurrentViewController()
                let vcc = ImageShowVc(nibName: nil, bundle: nil)
                vcc.imageURL = FilesUrl?.filter({ img in
                    img.type?.uppercased() == CommonStringFile.IMAGE
                }) ?? []
                vcc.FileURL = FilesUrl ?? []
                vcc.pdfUrl = FilesUrl?[indexPath.row].url
                vcc.scrollIndex = indexPath
                vcc.type = FilesUrl?[indexPath.row].type?.uppercased() != CommonStringFile.IMAGE ? 0 : 2
                vcc.modalPresentationStyle = .fullScreen
                vc?.present(vcc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        PageController.currentPage = indexPath.item
    }
    
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
}
