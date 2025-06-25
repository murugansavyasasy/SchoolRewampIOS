//
//  MessageFromManagementViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

import UIKit

@available(iOS 14.0, *)
class MessageFromManagementViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    
    
    let MenuRedirect = MenuRedirectHandler.shared
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var messageData: [ManagemantMessageData]?
    var SearchData: [ManagemantMessageData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.MessagesFromManagement, secondLine: staffDetails?.school_name ?? "")
        BackBtn.applyBackButton()
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
        SearchBar.searchTextField.addDoneButton()
        SearchBar.delegate = self
        
        FilterCV.isHidden = true
        SearchBar.isHidden = true
        NoDataLbl.isHidden = true
        NoDataImage.isHidden = true
        
        Cell_Registration()
        
        tv.register(UINib(nibName: CellConfingName.MessageFromManagementTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.MessageFromManagementTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        
        Get_messages()
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func Cell_Registration() {
        tv.register(UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
        
        tv.register(UINib(nibName: CellConfingName.HistoryTC, bundle: nil), forCellReuseIdentifier: CellConfingName.HistoryTC)
        
        tv.register(UINib(nibName: CellConfingName.HomeWorkTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.HomeWorkTVC)
        
        tv.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }
    
    //MARK: Get Message Data Api call
    
    func Get_messages() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_msg_from_management_get_messages_staff, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[self] (result: Result<MessageFromManagementResp,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    messageData = success.data
                    SearchData = messageData
                    
                    NoDataLbl.text = success.message
                    NoDataImage.isHidden = !(messageData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(messageData?.isEmpty ?? false)
                    SearchBar.isHidden = (messageData?.isEmpty ?? false)
                    tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    
                    NoDataImage.isHidden = false
                    NoDataLbl.isHidden = false
                    SearchBar.isHidden = true
                    NoDataLbl.text = error.localizedDescription
                    tv.reloadData()
                }
            }
        }
    }
    
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let Message = SearchData?[indexPath.row]
        
        switch Message?.type {
            
        case "ATTACHMENT":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HomeWorkTVC, for: indexPath) as! HomeWorkTVC
            
            return cell
            
        case "TEXT":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
            
            cell.MessageTitle.text = Message?.title
            cell.descriptContent.text = Message?.content
            cell.DateLabel
            
            
            return cell
            
        case "VOICE":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
            
            return cell
            
        default:
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HomeWorkTVC, for: indexPath) as! HomeWorkTVC
            
            return cell
        }
    }
    
    @IBAction func voiceTap() {
        
        let vc = ParentCommunicationVc(nibName: nil, bundle: nil)
        vc.passValue = 1
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        //MenuRedirect.receiverCommunicationNavigate(from: self)
    }
    
    @IBAction func textTap() {
        let vc = ParentCommunicationVc(nibName: nil, bundle: nil)
        vc.passValue = 1
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
       // MenuRedirect.receiverCommunicationNavigate(from: self)
    }
    
    @IBAction func imageTap() {
//        MenuRedirect.receiverImgPdfNavigate(from: self)
        let vc = ImagePdfVC(nibName: nil, bundle: nil)
        vc.passValue = 1
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func pdfTap() {
       // MenuRedirect.receiverImgPdfNavigate(from: self)
        let vc = ImagePdfVC(nibName: nil, bundle: nil)
        vc.passValue = 1
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func videoTap() {
       // MenuRedirect.receiverVideoNavigate(from: self)
        let vc = VideoVC(nibName: nil, bundle: nil)
        vc.passValue = 1
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

@available(iOS 14.0, *)
extension MessageFromManagementViewController: UISearchBarDelegate {
    
}
