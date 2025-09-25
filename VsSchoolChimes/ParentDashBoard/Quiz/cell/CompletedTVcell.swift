//
//  CompletedTVcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 20/01/25.
//

import UIKit

class CompletedTVcell: UITableViewCell,UIScrollViewDelegate {

    @IBOutlet weak var crtAnsLbl: UILabel!
    @IBOutlet weak var pageControls: UIPageControl!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var Button4: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var ButtonStackView: UIStackView!
    @IBOutlet weak var QuestionLbl: UILabel!
    @IBOutlet weak var QuestionView: UIView!
    @IBOutlet weak var cellView: UIView!
    var file_path: [FilePath]?
    var buttons : [UIButton] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        buttons = [Button1,Button2,Button3,Button4]
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        QuestionView.layer.cornerRadius = 10
        Button1.layer.cornerRadius = 15
        Button2.layer.cornerRadius = 15
        Button3.layer.cornerRadius = 15
        Button4.layer.cornerRadius = 15
        
        QuestionLbl.setFont(style: .title, size: FontSize.TitleSize)
        for button in buttons{
            button.setTitleFont(style: .body, size: FontSize.BodySize)
        }
        
        
//        cv.isHidden = file_path?.count == 0
        cv.register(UINib(nibName: "MsgVoiceCvCell", bundle: nil),
    forCellWithReuseIdentifier: "MsgVoiceCvCell")
        cv.delegate = self
        cv.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}

extension CompletedTVcell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        cv.isHidden = file_path?.count == 0
//        pageControls.isHidden = file_path?.count == 1 || file_path?.count == 0
//        pageControls.numberOfPages = file_path?.count ?? 0
        return file_path?.count ?? 0
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MsgVoiceCvCell", for: indexPath) as? MsgVoiceCvCell else {
            return UICollectionViewCell()
        }
        
        if let url = URL(string: file_path?[indexPath.row].url ?? "") {
                    let request = URLRequest(url: url)
            cell.webView.load(request)
                }
      
        
        
        let urlString = file_path?[indexPath.row].url ?? ""
        if let url = URL(string: urlString) {
            let ext = url.pathExtension.lowercased()
            if ["png", "jpg", "jpeg", "webp"].contains(ext) {
               
                let imageUrl = urlString

                let htmlString = """
                <html>
                <head>
                <style>
                body { margin:0; padding:0; background:#000; }
                img { max-width:100%; height:auto; display:block; margin:auto; }
                </style>
                </head>
                <body>
                <img src="\(imageUrl)">
                </body>
                </html>
                """
                cell.webView.isUserInteractionEnabled = false
                cell.webView.loadHTMLString(htmlString, baseURL: nil)
            } else {
                cell.webView.isUserInteractionEnabled = true
                cell.webView
                    .load(
                        URLRequest(url: URL(string:file_path?[indexPath.row].url ?? "")!)
                    )
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = file_path?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
       
        
       
           
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = file_path ?? []
//            imageVC.subjectName = backBtn.title(for: .normal) ?? ""
            imageVC.pdfUrl = urlString
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
//            imageVC.type = isImage ? 2 : 0
            imageVC.modalPresentationStyle = .fullScreen
//            present(imageVC, animated: true)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.layer.frame.width, height: 180)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControls.currentPage = Int(pageIndex)
       }
    
}
