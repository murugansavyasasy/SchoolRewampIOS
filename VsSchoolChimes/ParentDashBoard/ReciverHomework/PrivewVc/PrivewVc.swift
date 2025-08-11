
//
//  PreviewVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/07/25.

import UIKit

protocol readStatusUpdate{
    
    func ReadCompleted(Id:String,IscompletedStatus:Bool)
}
class PrivewVc: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var doneHomeWorkBtnName: UIButton!
    @IBOutlet weak var postedByLbl: UILabel!
    @IBOutlet weak var attachDefultLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var discreption: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    
    var attachmetList: [FilePath]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var titleString: String?
    var descriptionString: String?
    var postedBy: String?
    var homeWorkid: String?
    var homeWorkdetail_id: String?
    var selectedDate: String?
    var isThumbedUp = false
    var isCompleted = false
    var subject_name: String?
    var delegate : readStatusUpdate?
    var is_unreadStatus : Bool?
    var buttonTitle:String?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Reload collection view once the view has appeared and frame is set
        cv.reloadData()
        reloadCollectionAndUpdateHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyTopToWhiteGradient(topColor: UIColor.homeWorkClr)
        
        // Invalidate layout when bounds change
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
        let displayText = formattedDateStatus(from: selectedDate ?? "")
        dateLbl.text = "Posted On : " + displayText
        titleLbl.text = titleString
        discreption.text = descriptionString
        postedByLbl.text = "Posted By : " + (postedBy ?? "")
        
        
        if is_unreadStatus ?? false{
            ReadStatusUpdateArchive(
                type: "HOMEWORK",
                detail_id: homeWorkdetail_id ?? ""
            )
        }
        
        
        
        if let homeWorkid = homeWorkdetail_id, !homeWorkid.isEmpty {
            doneHomeWorkBtnName.isHidden = isCompleted
        }
     
        backBtn.setTitle(subject_name ?? "", for: .normal)
        backBtn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backBtn.tintColor = .white
        backBtn.semanticContentAttribute = .forceLeftToRight
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 8)
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        backBtn.contentHorizontalAlignment = .leading
        
        doneHomeWorkBtnName.setTitle("\"Click\" here when you're done", for: .normal)
        doneHomeWorkBtnName.setTitleColor(.systemBlue, for: .normal)
        doneHomeWorkBtnName.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        doneHomeWorkBtnName.contentHorizontalAlignment = .right
        doneHomeWorkBtnName.semanticContentAttribute = .forceRightToLeft
        doneHomeWorkBtnName.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        
        attachDefultLbl.isHidden = attachmetList?.isEmpty ?? true
    }
    
    private func setupCollectionView() {
        cv.register(UINib(nibName: "PreviewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewCell")
        cv.delegate = self
        cv.dataSource = self
        
        // Configure flow layout
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 6
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = .zero // Important: disable self-sizing
        }
        
        // Reload after a slight delay to ensure frame is available
        DispatchQueue.main.async {
            self.reloadCollectionAndUpdateHeight()
        }
    }
    @IBAction func backBtn(_ sender: Any) {
        delegate?.ReadCompleted(Id: homeWorkid ?? "", IscompletedStatus: isCompleted)
        dismiss(animated: false)
    }
    
    @IBAction func markAsDone(_ sender: Any) {
        isThumbedUp.toggle()
        let imageName = isThumbedUp ? "hand.thumbsup.fill" : "hand.thumbsup"
        doneHomeWorkBtnName.setImage(UIImage(systemName: imageName), for: .normal)
        homeWorkFinished()
    }
    
    func homeWorkFinished() {
        if #available(iOS 15.0, *) { showLottieProgressLoader(animationName: "loader (2)") }
        
        APIService.shared.makeApi(
            url: ServiceUrl.homework_mark_complete,
            parameters: ["id": homeWorkid ?? ""],
            type: ApitTypeSringFile.PUT,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<CommonApiSuc, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideLottieProgressLoader() }
                
                guard let self = self else { return }
                switch result {
                case .success(_):
                    CustomAlert.showAlertWithOkAction(
                        title: "🎉 Well Done!",
                        message: "That's it! Homework done – you're amazing!",
                        on: self,
                        okAction: {
                            self.doneHomeWorkBtnName.isHidden = true
//                            self.dismiss(animated: true)
                        })
                    
                    self.isCompleted = true
                    self.doneHomeWorkBtnName.isHidden = true
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func ReadStatusUpdateArchive(type: String,detail_id: String){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                ""
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func reloadCollectionAndUpdateHeight() {
        cv.reloadData()
        cv.layoutIfNeeded()
        
        DispatchQueue.main.async {
            let contentHeight = self.cv.collectionViewLayout.collectionViewContentSize.height
            self.cvHeight.constant = contentHeight
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmetList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        guard let data = attachmetList?[indexPath.item] else { return cell }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = attachmetList?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
       
        
       
           
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = attachmetList ?? []
            imageVC.subjectName = backBtn.title(for: .normal) ?? ""
            imageVC.pdfUrl = urlString
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
//            imageVC.type = isImage ? 2 : 0
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
        }
    
    
//    func playVideo(for item: String) {
//        let vc = VideoPreviewVc(nibName: nil, bundle: nil)
//        vc.url = item
//        vc.titles = backBtn.titleLabel?.text ?? ""
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Get the collection view's actual width
        let collectionViewWidth = collectionView.bounds.width
        let screenWidth = collectionViewWidth > 0 ? collectionViewWidth : UIScreen.main.bounds.width - 32
        
        // Define spacing and insets (0 spacing as requested)
        let sectionInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        let minimumInteritemSpacing: CGFloat = 0
        let itemsPerRow: CGFloat = 3
        
        // Calculate available width for items
        let totalHorizontalSpacing = (itemsPerRow - 1) * minimumInteritemSpacing + sectionInsets.left + sectionInsets.right
        let availableWidth = screenWidth - totalHorizontalSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        let finalWidth = max(itemWidth, 80)
        
        // Return square cells
        return CGSize(width: finalWidth, height: finalWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension UIView {
    func applyTopToWhiteGradient(topColor: UIColor, heightRatio: CGFloat = 0.3) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [topColor.cgColor, UIColor.white.cgColor]
        gradient.locations = [0, NSNumber(value: Float(heightRatio))]
        self.layer.insertSublayer(gradient, at: 0)
    }
}
