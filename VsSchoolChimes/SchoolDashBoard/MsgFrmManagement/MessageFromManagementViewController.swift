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
        
        tv.register(UINib(nibName: CellConfingName.MessageFromManagementTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.MessageFromManagementTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    //MARK: Get Message Data Api call
    
    func Get_messages() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_msg_from_management_get_messages_staff, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[self] (result: Result<MessageFromManagementResp,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    messageData = success.data
                    SearchData = messageData
                    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.MessageFromManagementTableViewCell, for: indexPath)as! MessageFromManagementTableViewCell
        
        let Message = SearchData?[indexPath.row]
        
        switch Message?.type {
            
        case "ATTACHMENT":
            ""
        case "TEXT":
            ""
        case "VOICE":
            ""
        default:
            ""
        }
        
        let voiceTapGest = UITapGestureRecognizer(target: self, action: #selector(voiceTap))
        cell.voiceView.addGestureRecognizer(voiceTapGest)
        
        let textTapGest = UITapGestureRecognizer(target: self, action: #selector(textTap))
        cell.textView.addGestureRecognizer(textTapGest)
        
        let pdfTapGest = UITapGestureRecognizer(target: self, action: #selector(pdfTap))
        cell.pdfView.addGestureRecognizer(pdfTapGest)
        
        let imgTapGest = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        cell.imgView.addGestureRecognizer(imgTapGest)
        
        let videoTapGest = UITapGestureRecognizer(target: self, action: #selector(videoTap))
        cell.videoView.addGestureRecognizer(videoTapGest)
        return cell
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
