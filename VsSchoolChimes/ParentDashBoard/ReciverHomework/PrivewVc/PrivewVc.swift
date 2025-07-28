//
//  PrivewVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/07/25.
//

import UIKit

class PrivewVc: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var doneHomeWorkBtnName: UIButton!
    @IBOutlet weak var postedByLbl: UILabel!
    @IBOutlet weak var attachDefultLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var discreption: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    
    
    let itemsPerRow: CGFloat = 3
    let spacing: CGFloat = 10
    let sectionInset: CGFloat = 10
    var FilterHomeWorkList: [Homework] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var homeWorkid : String?
    var selectedDate : String?
    private var confettiLayer: CAEmitterLayer?
    private var isAnimating = true
    private let confetti1: ConfettiView = .top
    var isThumbedUp = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyTopToWhiteGradient(topColor: UIColor.homeWorkClr)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiAndReadStatus()
        
        cv.register(UINib(nibName: "PreviewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewCell")
        cv.delegate = self
        cv.dataSource = self
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = spacing
            layout.minimumLineSpacing = spacing
            layout.sectionInset = UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
        }
        
        reloadCollectionAndUpdateHeight()
    }
    
    
    
    func uiAndReadStatus(){
        
        let selectedDate = selectedDate ?? ""
        let displayText = formattedDateStatus(from: selectedDate)
        dateLbl.text = "Posted On : " + displayText
        titleLbl.text = FilterHomeWorkList.first?.title
        discreption.text = FilterHomeWorkList.first?.description
        homeWorkid = FilterHomeWorkList.first?.id
        postedByLbl.text = ("Posted By : ") + (
            FilterHomeWorkList.first?.sent_by ?? ""
        )
        
        if FilterHomeWorkList.first?.is_unread == true{
            ReadStatusUpdateArchive(
                type: "HOMEWORK",
                detail_id: FilterHomeWorkList.first?.detail_id ?? ""
            )
        }
        
        doneHomeWorkBtnName.isHidden = FilterHomeWorkList.first?.is_completed ?? false
        backBtn
            .setTitle( FilterHomeWorkList.first?.subject_name, for: .normal)
        backBtn.setImage(UIImage(systemName: "chevron.backward"), for: .normal) // Use your own image if needed
        backBtn.tintColor = .white // Change based on your theme
        
        // Set image to the left of text
        backBtn.semanticContentAttribute = .forceLeftToRight
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 8)
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        backBtn.contentHorizontalAlignment = .leading
        
        
        doneHomeWorkBtnName.setTitle("\"Click\" here when you’re done", for: .normal)
        doneHomeWorkBtnName.setTitleColor(.systemBlue, for: .normal)
        
        let thumbImage = UIImage(systemName: "hand.thumbsup") // outline version
        doneHomeWorkBtnName.setImage(thumbImage, for: .normal)
        doneHomeWorkBtnName.contentHorizontalAlignment = .right
        doneHomeWorkBtnName.semanticContentAttribute = .forceRightToLeft // Puts image on trailing
        doneHomeWorkBtnName.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        attachDefultLbl.isHidden = FilterHomeWorkList.first?.file_path?.count == 0
        cv.isHidden = (
            (FilterHomeWorkList.first?.file_path?.isEmpty) == nil
        )
    }
    
    func isCompletedOrNot(bool : Bool){
        
        doneHomeWorkBtnName.isHidden = bool
        
    }
    
    
    func formattedDateStatus(from selectedDateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let selectedDate = inputFormatter.date(from: selectedDateString) else {
            return selectedDateString // Fallback if parsing fails
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(selectedDate, inSameDayAs: today) {
            return "Today"
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  calendar.isDate(selectedDate, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM, yyyy" // e.g., 24 July, 2025
            return outputFormatter.string(from: selectedDate)
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
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
            parameters: ["id" : homeWorkid ?? ""],
            type: ApitTypeSringFile.PUT,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<CommonApiSuc, Error>) in
            DispatchQueue.main.async { [self] in
                if #available(iOS 15.0, *) { self?.hideLottieProgressLoader() }
                
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    
                    CustomAlert
                        .showAlertWithOkAction(
                            title: "🎉 Well Done!",
                            message: "That’s it! Homework done – you’re amazing!",
                            on: self,
                            okAction: {
                                self.doneHomeWorkBtnName.isHidden = true
                                self.dismiss(animated: true)})
                    
                case .failure(let error):
                    
                    ""
                }
            }
        }
    }
    
    func reloadCollectionAndUpdateHeight() {
        cv.reloadData()
        DispatchQueue.main.async {
            self.updateCollectionHeight()
        }
    }
    
    func updateCollectionHeight() {
        self.cv.layoutIfNeeded()
        
        let rows = ceil(
            CGFloat(FilterHomeWorkList.first?.file_path?.count ?? 0) / itemsPerRow
        )
        let itemHeight: CGFloat = self.getItemSize().height
        let totalHeight = (rows * itemHeight) + ((rows - 1) * spacing) + (2 * sectionInset)
        self.cvHeight.constant = totalHeight
    }
    
    // MARK: UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterHomeWorkList.first?.file_path?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data  = FilterHomeWorkList.first?.file_path?[indexPath.item]
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        if data?.type == "IMAGE"{
            cell.imageView.isHidden = false
            cell.webview.isHidden = true
            cell.imageView.sd_setImage(with: URL(string: data?.url ?? ""), placeholderImage: UIImage(named: "placeholder"))
        }else  if data?.type == "VIDEO" {
            cell.imageView.image = UIImage(named: "video (1)")
        }else{
            let fileURL = URL(fileURLWithPath: data?.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            let iconImage = UIImage(named: iconName)
            cell.imageView.image = iconImage
//            cell.imageView.layer.borderColor = UIColor.black.cgColor
//            cell.imageView.layer.borderWidth = 0.5
            
        }
        // Customize your cell if needed
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let file = FilterHomeWorkList.first?.file_path?[indexPath.row],
              let urlString = file.url,
             let url = URL(string: urlString) else { return }
        
        let fileType = file.type?.uppercased()
        
        if fileType == CommonStringFile.VIDEO {
            
            playVideo(for: file.url ?? "")
        }else{
            
            let isImage = fileType == CommonStringFile.IMAGE
            
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.imageURL = FilterHomeWorkList.first?.file_path?.filter { $0.type?.uppercased() == CommonStringFile.IMAGE } ?? []
            let homeworkDocs = FilterHomeWorkList.first?.file_path ?? []
            
            imageVC.FileURL = homeworkDocs
            imageVC.subjectName = backBtn.title(for: .normal) ?? ""
            imageVC.pdfUrl = file.url
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
            imageVC.type = isImage ? 2 : 0
            imageVC.modalPresentationStyle = .fullScreen
            imageVC.FileURL = FilterHomeWorkList.first?.file_path ?? []
            present(imageVC, animated: true)
        }
    }
    
    
    
    func playVideo(for item: String) {
        let vc = VideoPreviewVc(nibName: nil, bundle: nil)
        vc.url = item
        vc.titles =  backBtn.titleLabel?.text ?? ""
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getItemSize()
    }
    
    private func getItemSize() -> CGSize {
        let totalSpacing = (itemsPerRow - 1) * spacing + 2 * sectionInset
        let width = (cv.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width) // Height can be customized
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
