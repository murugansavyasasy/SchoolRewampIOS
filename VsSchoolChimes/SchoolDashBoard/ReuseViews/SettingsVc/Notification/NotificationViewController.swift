//
//  NotificationViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 25/10/24.
//

import UIKit

@available(iOS 14.0, *)
class NotificationViewController: UIViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    
    var name = ["Saranraj","Murugan","Gayathri","Sathish","Lakshmanan","Chandru","Reventh"]
    
    var type = ["Voice Message","Assignment Message","Image Message","Notice Board Message","Homework Message","Attendence Message","Exam Message"]
    var icon = [UIImage(named: "voice"),UIImage(named:"Phone"),UIImage(named: "message"),UIImage(named: "mail")]
    var content = ["Come to school","complete the Asssignment","Draw the Image","Follow the Noticeboard","Complete the Homework","You are absent Today","Chemistry Exam"]
    let MenuRedirect = MenuRedirectHandler.shared
    var passValue = 1
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var tvheadernotidata : [notificationData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.setTitle(MenuTapbar.Notifications.translated(), for: .normal)
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
        
        searchbar.delegate = self
        searchbar.addDoneButton()
        
       
        
        let nib = UINib(nibName: "NotificationsTvCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier:  "NotificationsTvCell")
        let nib1 = UINib(nibName: "NotiTvheader", bundle: nil)
        tableview
            .register(
                nib1,
                forHeaderFooterViewReuseIdentifier: "NotiTvheader"
            )
        
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getNotification()
    }

    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
}


@available(iOS 14.0, *)
extension NotificationViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
             return tvheadernotidata.count-1
         }
    
     
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NotiTvheader") as? NotiTvheader else { return nil }
        
        if let name = tvheadernotidata[section].menu_id {
            if #available(iOS 14.0, *) {
                let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == name }
                header.MenuImage.image = UIImage(named: filteredItems.first?.name ?? "")
                header.menuNameLbl.text = tvheadernotidata[section].menu_name
                
            }
        }
        
        return header
    }

     func tableView(_ tableView: UITableView,
                    heightForHeaderInSection section: Int) -> CGFloat {
         return 60
     }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvheadernotidata[section].details?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTvCell", for: indexPath) as? NotificationsTvCell else {
            return UITableViewCell()
        }
        
        
        cell.sentbyLbl.text = tvheadernotidata[indexPath.section].details?[indexPath.row].name ?? ""
        cell.messageLbl.text = tvheadernotidata[indexPath.section].details?[indexPath.row].message ?? ""
        cell.typeLbl.text = tvheadernotidata[indexPath.section].details?[indexPath.row].type ?? ""
    
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        
        let menuItem = tvheadernotidata[indexPath.section].details?[indexPath.row].menu_id
        if let menuName = tvheadernotidata.first(where: { $0.menu_id == menuItem })?.menu_name {
            print("Menu Name: \(menuName)")
            MenuStringFile.selectedMenuName = menuName
        }
        
        switch menuItem {
        case 2:
            MenuRedirect.receiverAssignmentNavigate(from: self)
        case 4:
            MenuRedirect.receiverAttendancereport(from: self)
        case 5:
            MenuRedirect.receiverCertificateRequest(from: self)
        case 6:
            MenuRedirect.receiverclassTimeTable(from: self)
        case 7:
            MenuRedirect.receiverCommunicationNavigate(from: self)
        case 9:
            MenuRedirect.receiverEvent(from: self)
        case 10:
            MenuRedirect.resiverExamMark(from: self)
        case 12:
            MenuRedirect.receiverFeeDetails(from: self)
        case 13:
            break    //fee payment
        case 15:
            MenuRedirect.receiverHomework(from: self)
        case 16:
            MenuRedirect.receiverchat(from: self)
        case 20:
            MenuRedirect.receiverLsrwNavigate(from: self)
        case 23:
            MenuRedirect.receiverNoticeBoardNavigate(from: self)
        case 24:
            MenuRedirect.receiverOnlineNavigate(from: self)
        case 25:
            MenuRedirect.receiverFeeDetails(from: self)
        case 26:
            MenuRedirect.receiverPtmNavigate(from: self)
        case 27:
            MenuRedirect.QuizExam(from: self)
        case 28:
            MenuRedirect.LeaveRquest(from: self)
        case 36:
            MenuRedirect.senderImportantInfoNavigate(from: self)
        case 39:
            
            //            clearNotification(
            //                id:append(tvheadernotidata[indexPath.section].details?[indexPath.row].id)){ finished in
            //
            MenuRedirect
                .receiverAttachment(
                    from: self,
                    notificationId: tvheadernotidata[indexPath.section].details?[indexPath.row].header_id ?? ""
                )
            //                }
            
        case 40:
            MenuRedirect.receiverPauckt(from: self)
        default:
            break
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    func getNotification() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }

        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_notifications,
            parameters: ["device_type" : "Iphone"],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<notificationSuc, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if response.status == true {
                        self.tvheadernotidata = response.data ?? []
                        self.tableview.dataSource = self
                        self.tableview.delegate = self
                        self.tableview.reloadData()
                    }else{
                        
                    }
                    
                    
                case .failure(let error):
                   ""
                }
            }
        }
    }
    
    
    func clearNotification(id:[String],onComplete:@escaping (Bool)->(Void)) {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }

        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_delete_notification,
            parameters: ["id" : id],
            type: ApitTypeSringFile.PUT,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<notificationSuc, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    
                    if response.status == true {
                        self.tvheadernotidata = response.data ?? []
                        self.tableview.dataSource = self
                        self.tableview.delegate = self
                        self.tableview.reloadData()
                    }else{
                        
                    }
                    
                    
                case .failure(let error):
                   ""
                }
                
                onComplete(true)
            }
        }
        
    }
}

@available(iOS 14.0, *)
extension NotificationViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }
    
}

