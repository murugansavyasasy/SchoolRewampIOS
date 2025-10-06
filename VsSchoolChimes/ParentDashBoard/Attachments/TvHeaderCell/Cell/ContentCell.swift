//
//  ContentCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 31/07/25.
//

import UIKit

class ContentCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SelectedId,UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id:id, edit: edit)
    }
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var editAndDeleteBtnName: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var sendByLbl: UILabel!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var cv: UICollectionView!
    var attachmentFiles: [FilePath]?
    var delegate:SelectedId?
    var edit:Bool?
    var delete:Bool?
    var selectedId:String?
    private weak var parentTableView: UITableView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        roundView.layer.cornerRadius = roundView.frame.width/2
        
        cv.register(UINib(nibName: "PreviewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewCell")
        cv.delegate = self
        cv.dataSource = self
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
                   layout.estimatedItemSize = .zero
               }
               cv.isScrollEnabled = false
    }
    
    
    
    @IBAction func EditAndDeletBtn(_ sender: UIButton) {
        
        let popoverContentVC = PopupVC(edit: self.edit ?? false, delete: self.delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: 70)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .right
            popoverController.delegate = self
        }
        
        // For iPhones: Present as a pop-up instead of full-screen
        if UIDevice.current.userInterfaceIdiom == .phone {
            popoverContentVC.modalPresentationStyle = .overFullScreen
            popoverContentVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3) // Optional dim effect
        }
        if let topVC = getCurrentViewController() {
            topVC.present(popoverContentVC, animated: true, completion: nil)
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
    
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
        editAndDeleteBtnName.isHidden = !(edit || delete)
    }
    
    
   
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        descriptionLbl.preferredMaxLayoutWidth = descriptionLbl.frame.width
//        cv.layoutIfNeeded()
//        cvHeight.constant = cv.contentSize.height
//    }

    private func updateCollectionHeight() {
        self.cv.layoutIfNeeded()
        let newHeight = self.cv.collectionViewLayout.collectionViewContentSize.height
        
        if abs(cvHeight.constant - newHeight) > 1 {
            cvHeight.constant = newHeight
            parentTableView?.beginUpdates()
            parentTableView?.endUpdates()
        }
    }

   
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cv.collectionViewLayout.invalidateLayout()
        self.cv.layoutIfNeeded()
        self.updateCollectionHeight()
    }

    func configureCell(with files: [FilePath]?,
                       title: String,
                       description: String,
                       date: String,
                       sendBy: String,
                       isunread: Bool,
                       parentTableView: UITableView) {
        
        self.titleLbl.text = title
        self.sendByLbl.text = sendBy
        self.dateLbl.text = date
        self.roundView.isHidden = !isunread
        self.attachmentFiles = files
        self.parentTableView = parentTableView

        // Reload and force layout updates for collection view
        DispatchQueue.main.async {
            self.cv.reloadData()
            self.cv.collectionViewLayout.invalidateLayout()
            self.cv.layoutIfNeeded()
            self.updateCollectionHeight()
        }
    }


   

      

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentFiles?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PreviewCell",
            for: indexPath) as? PreviewCell
        else{
            return UICollectionViewCell()
        }
      
      

        guard let data = attachmentFiles?[indexPath.item] else { return cell }
        
        switch data.type?.uppercased() {
        case CommonStringFile.IMAGE:
            cell.imageView.isHidden = false
            cell.webview.isHidden = true
            cell.imageView.sd_setImage(with: URL(string: data.url ?? ""), placeholderImage: UIImage(named: "placeholder"))
            cell.outerView.clearShadow()
            cell.outerView.backgroundColor = .white
        case CommonStringFile.VIDEO:
            cell.imageView.image = UIImage(named: "video (1)")
            cell.outerView.setShadow()
            cell.outerView.backgroundColor = .white
        default:
            let iconName = getFileIconName(for: URL(fileURLWithPath: data.url ?? ""))
            cell.imageView.image = UIImage(named: iconName)
            cell.outerView.setShadow()
            cell.outerView.backgroundColor = .white
        }
        
        
       
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let file = attachmentFiles?[indexPath.row],
              let urlString = file.url,
             let url = URL(string: urlString) else { return }
        

            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            let homeworkDocs = attachmentFiles ?? []
            imageVC.fileURL = homeworkDocs
            imageVC.subjectName = "Attachments"
            imageVC.pdfUrl = file.url
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
//            imageVC.type = isImage ? 2 : 0
            
            imageVC.modalPresentationStyle = .fullScreen
//            imageVC.FileURL = attachmetList ?? []
            let currentController = getCurrentViewController()
            currentController?.present(imageVC, animated: true)
        
        
    }
    
   
    func playVideo(for item: String) {
        let vc = VideoPreviewVc(nibName: nil, bundle: nil)
        vc.url = item
        vc.titles =  "Attachments"
        vc.modalPresentationStyle = .fullScreen
        let currentController = getCurrentViewController()
        currentController?.present(vc, animated: true)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.frame.width-20)/3
        return CGSize(width: size, height: size)
    }
    
    
}
