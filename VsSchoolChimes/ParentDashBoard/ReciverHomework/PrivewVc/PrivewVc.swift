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
    var attachmetList: [FilePath]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var titleString:String?
    var descriptionString:String?
    var postedBy:String?
    var homeWorkid : String?
    var selectedDate : String?
    private var confettiLayer: CAEmitterLayer?
    private var isAnimating = true
    private let confetti1: ConfettiView = .top
    var isThumbedUp = false
    var isCompleted = false
    var subject_name:String?
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
        
//        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumInteritemSpacing = spacing
//            layout.minimumLineSpacing = spacing
//            layout.sectionInset = UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
//        }
        
        reloadCollectionAndUpdateHeight()
    }
    
    
    
    func uiAndReadStatus(){
        
        let selectedDate = selectedDate ?? ""
        let displayText = formattedDateStatus(from: selectedDate)
        dateLbl.text = "Posted On : " + displayText
        titleLbl.text = titleString
        discreption.text = descriptionString
        postedByLbl.text = ("Posted By : ") + (
            postedBy ?? ""
        )
        
        if FilterHomeWorkList.first?.is_unread == true{
            ReadStatusUpdateArchive(
                type: "HOMEWORK",
                detail_id: homeWorkid ?? ""
            )
        }
        if let homeWorkid = homeWorkid, !homeWorkid.isEmpty {
            doneHomeWorkBtnName.isHidden = isCompleted
        }

        
        backBtn
            .setTitle(subject_name ?? "", for: .normal)
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
        attachDefultLbl.isHidden = attachmetList?.count == 0
//        cv.isHidden = (
//            (attachmetList?.isEmpty) == nil
//        )
    }
    
    func isCompletedOrNot(bool : Bool){
        
        doneHomeWorkBtnName.isHidden = bool
        
    }
    
    
    func formattedDateStatus(from selectedDateString: String) -> String {
        let possibleFormats = [
            "dd-MM-yyyy",
            "yyyy-MM-dd",
            "dd/MM/yyyy",
            "MM/dd/yyyy",
            "dd MMM yyyy",
            "dd MMMM yyyy",
            "yyyy/MM/dd",
            "MMM dd, yyyy",
            
            // DateTime formats
            "dd-MM-yyyy HH:mm",
            "dd-MM-yyyy hh:mm a",
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy/MM/dd HH:mm:ss",
            "MM/dd/yyyy HH:mm",
            "dd MMM yyyy HH:mm",
            "dd MMMM yyyy HH:mm",
            "MMM dd, yyyy HH:mm"
        ]

        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        var selectedDate: Date? = nil

        for format in possibleFormats {
            inputFormatter.dateFormat = format
            if let date = inputFormatter.date(from: selectedDateString) {
                selectedDate = date
                break
            }
        }

        guard let date = selectedDate else {
            return selectedDateString // fallback if parsing fails
        }

        let calendar = Calendar.current
        let today = Date()

        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMMM, yyyy"
            return outputFormatter.string(from: date)
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
        cv.performBatchUpdates(nil) { _ in
            let newHeight = self.cv.collectionViewLayout.collectionViewContentSize.height
            self.cvHeight.constant = newHeight
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    // MARK: UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmetList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data  = attachmetList?[indexPath.item]
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        if data?.type == "IMAGE"{
            cell.imageView.isHidden = false
            cell.webview.isHidden = true
            cell.imageView.sd_setImage(with: URL(string: data?.url ?? ""), placeholderImage: UIImage(named: "placeholder"))
            cell.outerView.clearShadow()
            cell.outerView.backgroundColor = .clear
        }else  if data?.type == "VIDEO" {
            cell.imageView.image = UIImage(named: "video (1)")
            cell.outerView.clearShadow()
            cell.outerView.backgroundColor = .clear
        }else{
            let fileURL = URL(fileURLWithPath: data?.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            let iconImage = UIImage(named: iconName)
            cell.imageView.image = iconImage
            cell.outerView.setShadow()
            cell.outerView.backgroundColor = .white
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
        guard let file = attachmetList?[indexPath.row],
              let urlString = file.url,
             let url = URL(string: urlString) else { return }
        
        let fileType = file.type?.uppercased()
        
        if fileType == CommonStringFile.VIDEO {
            
            playVideo(for: file.url ?? "")
        }else{
            
            let isImage = fileType == CommonStringFile.IMAGE
            
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.imageURL = FilterHomeWorkList.first?.file_path?.filter { $0.type?.uppercased() == CommonStringFile.IMAGE } ?? []
            let homeworkDocs = attachmetList ?? []
            
            imageVC.FileURL = homeworkDocs
            imageVC.subjectName = backBtn.title(for: .normal) ?? ""
            imageVC.pdfUrl = file.url
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
            imageVC.type = isImage ? 2 : 0
            imageVC.modalPresentationStyle = .fullScreen
            imageVC.FileURL = attachmetList ?? []
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
        // Assuming 3 items per row
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = 3
        let totalSpacing = (itemsPerRow - 1) * spacing + 6 // 3pt left + 3pt right

        let width = (collectionView.frame.width - totalSpacing) / itemsPerRow
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
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
