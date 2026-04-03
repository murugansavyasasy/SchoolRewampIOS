
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
    
    @IBOutlet weak var yourTargetImageView: UIImageView!
    @IBOutlet weak var sendToInnerView: UIView!
    @IBOutlet weak var attachmentInnerView: UIView!
    @IBOutlet weak var targetFullView: UIView!
    @IBOutlet weak var attachmentFullView: UIView!
    @IBOutlet weak var targetCvHeight: NSLayoutConstraint!
    @IBOutlet weak var targetCv: UICollectionView!
    
    @IBOutlet weak var yourTargetLbl: UILabel!
    @IBOutlet weak var doneHomeWorkBtnName: UIButton!
    @IBOutlet weak var postedByLbl: UILabel!
    @IBOutlet weak var attachDefultLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var discreption: UITextView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    @IBOutlet weak var assignmentTable: UITableView!
    
    var homeworkDetails: [HomeworkDetails]?
    var filterhomeworkDetails: [HomeworkDetails]?
    var attachmetList: [FilePath]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    let staffDetails = UserDefaultFileManager.get_staff_Details()
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
    var targetCvdata : [targetInfoData] = []
    var ComFromNoticeBoard : Bool = false
    var targetId : String?
    var EndUrl : String?
    var isStaffAndStudent : Bool = false
    var isStudent : Bool = false
    var standarSenction : [String] = []
    var params : [String : Any] = [:]
    let id = "id"
    let HOMEWORK = "HOMEWORK"
    var dateAndTimeForVideo : String = ""
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cv.reloadData()
        assignmentTable.rowHeight = UITableView.automaticDimension
        assignmentTable.isHidden = isStudent
        assignmentTable.estimatedRowHeight = 80
        reloadCollectionAndUpdateHeight()
        assignmentTable.register(UINib(nibName: "SubmitedStudentTVC", bundle: nil), forCellReuseIdentifier: "SubmitedStudentTVC")
        assignmentTable.register(UINib(nibName: "AssignmentsearchTVC", bundle: nil), forCellReuseIdentifier: "AssignmentsearchTVC")
        assignmentTable.delegate = self
        assignmentTable.dataSource = self
        assignmentTable.tableFooterView = UIView()
        PrivewHomeWork()
    }
    func PrivewHomeWork() {
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_homework_submissions_list,
            parameters: ["id": homeWorkid ?? ""],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "",
            isBaseUrl: false
        ) { [weak self] (result: Result<HomeWorkSubmissionList, Error>) in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let response):
                
                DispatchQueue.main.async {
                    
                    if response.status ?? false {
                        
                        self.homeworkDetails = response.data ?? []
                        self.filterhomeworkDetails = response.data ?? []
                    }
                    
                    self.assignmentTable.reloadData()
                    
                    self.assignmentTable.layoutIfNeeded()
                    
                    self.tableviewHeight.constant = self.assignmentTable.contentSize.height
                }
                
            case .failure(let error):
                
                print("API Error: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    self.assignmentTable.reloadData()
                }
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
        setupTopRoundedCorners(for: sendToInnerView)
        setupTopRoundedCorners(for: attachmentInnerView)
    }
    
    private func setupTopRoundedCorners(for view: UIView) {
        // Top corners radius
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 12, height: 12)
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
        // Remove previous border if any
        view.layer.sublayers?.removeAll(where: { $0.name == "bottomBorder" })
        // Add bottom line
        let border = CALayer()
        border.name = "bottomBorder"
        border.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        border.frame = CGRect(
            x: 0,
            y: view.bounds.height - 1,
            width: view.bounds.width,
            height: 1
        )
        view.layer.addSublayer(border)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetFullView.layer.cornerRadius = 10
        attachmentFullView.layer.cornerRadius = 10
        attachmentFullView.isHidden = attachmetList?.count == 0
        setupUI()
        setupCollectionView()
        if EndUrl == "" || EndUrl == nil {
            targetFullView.isHidden = true
        }else{
            targetFullView.isHidden = false
            getTargetReport(EndUrl: EndUrl ?? "", params: params)
        }
        
        if ComFromNoticeBoard{
                switch staffDetails?.priority_level {
                case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                    yourTargetLbl.text = "Message sent to SCHOOL"
                    targetFullView.isHidden = false
                    cv.delegate = self
                    cv.dataSource = self
                    cv.reloadData()
                    DispatchQueue.main.async {
                        self.reloadss()
                    }
                    ComFromNoticeBoard = false
                default:
                    targetFullView.isHidden = true
                }
           
        }
    }
    
    private func setupUI() {
        let displayText = selectedDate?.convertToTargetDateFormat() ?? ""
        titleLbl.text = titleString
        discreption.text = descriptionString
        discreption.isScrollEnabled = false
        discreption.textContainerInset = .zero
        discreption.textContainer.lineFragmentPadding = 0
        dateLbl.text =  MenuStringFile.posted_on + "\(displayText)"
        postedByLbl.text = MenuStringFile.Posted_By + "\(postedBy ?? "")"
        
        if is_unreadStatus ?? false{
            ReadStatusUpdateArchive(
                type: HOMEWORK,
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
        backBtn.titleLabel?.numberOfLines = 0
        backBtn.titleLabel?.lineBreakMode = .byWordWrapping
        
        doneHomeWorkBtnName.setTitle("\"Click\" here when you're done", for: .normal)
        doneHomeWorkBtnName.setTitleColor(.systemBlue, for: .normal)
        doneHomeWorkBtnName.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        doneHomeWorkBtnName.contentHorizontalAlignment = .right
        doneHomeWorkBtnName.semanticContentAttribute = .forceRightToLeft
        doneHomeWorkBtnName.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        
        attachDefultLbl.isHidden = attachmetList?.isEmpty ?? true
    }
    
    private func setupCollectionView() {
        cv.register(UINib(nibName: CellConfingName.PreviewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.PreviewCell)
        targetCv.register(UINib(nibName: CellConfingName.TargetCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.TargetCvCell)
        
        cv.delegate = self
        cv.dataSource = self
        targetCv.delegate = self
        targetCv.dataSource = self
        
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10 // Customize spacing between items
        layout.minimumLineSpacing = 10 // Customize line spacing
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
        targetCv.collectionViewLayout = layout
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
        if #available(iOS 15.0, *) { showActivityLoader() }
        
        APIService.shared.makeApi(
            url: ServiceUrl.homework_mark_complete,
            parameters: [id: homeWorkid ?? ""],
            type: ApitTypeSringFile.PUT,
            token: studentDetails?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<CommonApiSuc, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideActivityLoader() }
                guard let self = self else { return }
                switch result {
                case .success(_):
                    CustomAlert.showAlertWithOkAction(
                        title: "🎉 Well Done!".translated(),
                        message: "That's it! Homework done – you're amazing!".translated(),
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
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "", isBaseUrl: true) { [self] (result : Result<ReadStatusResponse,Error>) in
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
    
    func reloadss(){
        targetCv.reloadData()
        targetCv.layoutIfNeeded()
        DispatchQueue.main.async {
            self.targetCvHeight.constant = self.targetCv.collectionViewLayout.collectionViewContentSize.height
        }
    }
    
    func getTargetReport(EndUrl : String ,params:[String:Any]) {
        APIService.shared.makeApi(url: EndUrl,parameters: params,type: ApitTypeSringFile.GET,token: staffDetails?.access_token ?? "", isBaseUrl: false) {[weak self] (result: Result<targetSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.status == true{
                        self.yourTargetLbl.text = res.data?.first?.type?.translated()
                        self.isStaffAndStudent = true
                        if res.data?.first?.type == MessageType.toStandard {
                            self.yourTargetImageView.image = UIImage(systemName: "graduationcap.fill")
                            self.standarSenction = res.data?.first?.name?.first?.standard ?? []
                            
                        } else if res.data?.first?.type == MessageType.toSchool {
                            self.yourTargetImageView.image = UIImage(systemName: "building.columns")
                            self.standarSenction = res.data?.first?.name?.first?.institute ?? []
                            
                        } else if res.data?.first?.type == MessageType.toGroup {
                            
                            self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                            self.standarSenction = res.data?.first?.name?.first?.group ?? []
                            
                        } else if res.data?.first?.type == MessageType.toStudents {
                            self.isStaffAndStudent = false
                            self.targetCvdata = res.data?.first?.name ?? []
                            self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                            
                        } else if res.data?.first?.type == MessageType.toSection {
                            self.standarSenction = res.data?.first?.name?.first?.section ?? []
                            self.yourTargetImageView.image = UIImage(systemName: "graduationcap.fill")
                            
                        } else if res.data?.first?.type == MessageType.toStaff {
                            
                            self.isStaffAndStudent = false
                            self.targetCvdata = res.data?.first?.name ?? []
                            self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        }
                        
                        self.reloadss()
                    }
                case .failure(let err):
                    print(err.localizedDescription)
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
        switch collectionView {
        case cv:
            return attachmetList?.count ?? 0
        case targetCv:
            if isStaffAndStudent{
                return standarSenction.count
            }else{
                return targetCvdata.count
            }
        default:
            return  4
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  collectionView == cv{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.PreviewCell, for: indexPath) as? PreviewCell else {
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
                cell.imageView.tintColor = .black
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
        
        else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.TargetCvCell, for: indexPath) as? TargetCvCell else {
                return UICollectionViewCell()
            }
            if isStaffAndStudent{
                cell.nameLbl.text = standarSenction[indexPath.row]
            }else{
                cell.nameLbl.text =  targetCvdata[indexPath.row].name ?? ""
            }
            return  cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  collectionView == cv{
            guard let file = attachmetList?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = attachmetList ?? []
            imageVC.subjectName = backBtn.title(for: .normal) ?? ""
            imageVC.pdfUrl = urlString
            imageVC.dateAndTimeForVideo = dateAndTimeForVideo
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  collectionView == cv{
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
            
        }else{
            
            if isStaffAndStudent{
                let titleString = standarSenction[indexPath.item]
                let font = UIFont.systemFont(ofSize: 14) // Customize as needed
                let titleWidth = titleString.size(
                    withAttributes: [NSAttributedString.Key.font: font]
                ).width
                return CGSize(width: titleWidth + 70, height: 40) // Add padding if needed
            }else{
                
                let item = targetCvdata[indexPath.item]
                let titleString = item.name
                let font = UIFont.systemFont(ofSize: 14)
                let titleWidth = titleString?.size(
                    withAttributes: [NSAttributedString.Key.font: font]
                ).width
                return CGSize(width: (titleWidth ?? 0) + 70, height: 40)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if  collectionView == cv{
            return 0
        }else{
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if  collectionView == cv{
            return 0
        }
        else{
            return 8
        }
    }
}
extension PrivewVc:UITableViewDataSource, UITableViewDelegate, SearchDelegate{
    func searchText(_ searchText: String) {
        
        print(searchText)
        
        guard let list = homeworkDetails else { return }
        
        if searchText == "All" {
            
            filterhomeworkDetails = list
            
        } else if searchText == "Submited" {
            
            filterhomeworkDetails = list.filter { $0.status ?? "" == "Complete" }
            
        } else if searchText == "Pending" {
            
            filterhomeworkDetails = list.filter { $0.status ?? "" == "Not Complete" }
            
        } else if searchText.isEmpty {
            
            filterhomeworkDetails = list
            
        } else {
            
            filterhomeworkDetails = list.filter {
                ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.roll_no?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.admission_no?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        DispatchQueue.main.async {
            
            if self.assignmentTable.numberOfSections > 1 {
                
                UIView.performWithoutAnimation {
                    self.assignmentTable.reloadSections(IndexSet(integer: 1), with: .none)
                }
                
            } else {
                
                self.assignmentTable.reloadData()
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            return 1
        default:
            return filterhomeworkDetails?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentsearchTVC", for: indexPath) as? AssignmentsearchTVC else {
                return UITableViewCell()
            }
            cell.allBtn.setTitle("All Students(\(filterhomeworkDetails?.count ?? 0))", for: .normal)
            let submitedCount = filterhomeworkDetails?.filter {$0.status == "Completed"}
            let notsubmitedCount = filterhomeworkDetails?.filter {$0.status == "Not Complete"}
            cell.submitedBtn.setTitle("Submitted(\(submitedCount?.count ?? 0))", for: .normal)
            cell.pendingBtn.setTitle("Pending(\(notsubmitedCount?.count ?? 0))", for: .normal)
            cell.delegate = self
            return cell

        case 1:
            guard !(filterhomeworkDetails?.isEmpty ?? true) else {
                let noDataCell = UITableViewCell(style: .default, reuseIdentifier: "NoDataCell")
                    noDataCell.selectionStyle = .none
                    noDataCell.backgroundColor = .clear

                    // Image
                    let imageView = UIImageView(image: UIImage(named: "noSearchData"))
                    imageView.contentMode = .scaleAspectFit
                    imageView.translatesAutoresizingMaskIntoConstraints = false

                    // Label
                    let label = UILabel()
                    label.text = "No Data Found"
                    label.textColor = .gray
                    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                    label.textAlignment = .center
                    label.numberOfLines = 0
                    label.translatesAutoresizingMaskIntoConstraints = false

                    noDataCell.contentView.addSubview(imageView)
                    noDataCell.contentView.addSubview(label)

                    NSLayoutConstraint.activate([
                        // Image constraints
                        imageView.topAnchor.constraint(equalTo: noDataCell.contentView.topAnchor, constant: 40),
                        imageView.centerXAnchor.constraint(equalTo: noDataCell.contentView.centerXAnchor),
                        imageView.widthAnchor.constraint(equalToConstant: 150),
                        imageView.heightAnchor.constraint(equalToConstant: 150),

                        // Label constraints
                        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                        label.leadingAnchor.constraint(equalTo: noDataCell.contentView.leadingAnchor, constant: 20),
                        label.trailingAnchor.constraint(equalTo: noDataCell.contentView.trailingAnchor, constant: -20),
                        label.bottomAnchor.constraint(lessThanOrEqualTo: noDataCell.contentView.bottomAnchor, constant: -40)
                    ])
                    return noDataCell
            }

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitedStudentTVC", for: indexPath) as? SubmitedStudentTVC else {
                return UITableViewCell()
            }

            let student = filterhomeworkDetails?[indexPath.row]
            cell.studentNameLbl.text = student?.name ?? ""
            if let firstLetter = student?.name?.first {
                cell.initialBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
            } else {
                cell.initialBtn.setTitle("-", for: .normal)
            }
            cell.standerdScection?.text = "RoleNo : \(student?.roll_no ?? "")"
            let isNotSubmitted = student?.status == "Not Complete"
            let statusText = isNotSubmitted ? "Pending" : "Submitted"
            let statusColor = isNotSubmitted ? UIColor.brown : UIColor.systemGreen

            cell.statusView.backgroundColor = isNotSubmitted ? UIColor.systemGray5 : UIColor.systemGray6
            cell.statusView.layer.cornerRadius = 8
            cell.statusView.clipsToBounds = true

            let fullText = NSMutableAttributedString(
                string: statusText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                    .foregroundColor: statusColor
                ]
            )
            cell.statusView.setAttributedTitle(fullText, for: .normal)

            let iconSize: CGFloat = 13
            let iconConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
            let icon = UIImage(systemName: isNotSubmitted ? "arrowshape.down.circle" : "checkmark.circle.fill", withConfiguration: iconConfig)

            let lastSubmittedOn = "13-08-2025"
//            let date: String? = lastSubmittedOn?.isEmpty == false ? lastSubmittedOn : data?.end_date
            let txt = (lastSubmittedOn.isEmpty == false) ? "Submitted" : "Due Date"

            cell.submitDate.text = "\(txt): \(formattedDateStatus(from: "13-08-2025"))"
            cell.statusView.setImage(icon, for: .normal)
            cell.statusView.tintColor = statusColor
            cell.statusView.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            cell.statusView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            return cell

        default:
            return UITableViewCell()
        }
    }

//    // MARK: - TableView Delegate
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard indexPath.section == 3, indexPath.row < filterAssignment.count else { return }
//
//        let selectedStudent = filterAssignment[indexPath.row]
//        if selectedStudent.submit_status == "NOTSUBMITTED" {
//            let alert = UIAlertController(
//                title: "No Submission",
//                message: "\(selectedStudent.student_name ?? "This student") has not submitted the assignment yet.",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//            return
//        }
//
//        let submissionVC = AssignmentSummitionVC(nibName: nil, bundle: nil)
//        submissionVC.subject = data?.subject
//        submissionVC.titleName = data?.title
//        submissionVC.submitedList = true
//        submissionVC.submissions_details = selectedStudent.submissions_details
//        submissionVC.backBtnTittle1 = userNameValue ?? ""
//        submissionVC.backBtnTittle2 = sectionValue ?? ""
//        submissionVC.isStudent = "Submission"
//        submissionVC.modalPresentationStyle = .fullScreen
//        present(submissionVC, animated: false)
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
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
struct MessageType {
    static let toStandard = "Message sent to STANDARD"
    static let toSchool   = "Message sent to SCHOOL"
    static let toGroup    = "Message sent to GROUP"
    static let toStudents = "Message sent to STUDENTS"
    static let toSection  = "Message sent to SECTION"
    static let toStaff    = "Message sent to STAFF"
}
