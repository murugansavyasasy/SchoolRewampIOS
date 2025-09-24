//
//  InteractionVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/01/25.
//

import UIKit

class InteractionVC: UIViewController {
   
    @IBOutlet weak var chatCV: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var FullView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
   
    var passvalue = 0
    var staffMembersData: [StaffMember]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        searchBar.searchTextField.addDoneButton()
        backBtn.applyBackButton()
        FullView.layer.cornerRadius = 30
        FullView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        FullView.layer.masksToBounds = true
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        let name = studentDetails?.name ?? ""
        let standard = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        backBtn.configureAsBackButton(firstLine: name, secondLine: standard)
        let nib = UINib(nibName: CellConfingName.interactTvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.interactTvcell)
        chatCV.register(UINib(nibName: "ChatCVC", bundle: nil), forCellWithReuseIdentifier: "ChatCVC")
        tv.delegate = self
        tv.dataSource = self
        chatCV.delegate = self
        chatCV.dataSource = self
        getStaff()
        
    }
    @IBAction func search(_ sender: UIButton) {
        searchBar.becomeFirstResponder()
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        searchBar.isHidden = !sender.isSelected
    }
    
    
    @IBAction func backBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
 
}
extension InteractionVC: UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return staffMembersData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chatCV.dequeueReusableCell(withReuseIdentifier: "ChatCVC", for: indexPath) as! ChatCVC
        
        if let datas = staffMembersData?[indexPath.row] {
            cell.nameLbl.text = datas.name ?? ""
            cell.subjectLbl.text = datas.subject_name ?? ""
            
            // Unread count handling
            let unreadCount = datas.unread_count ?? 0
            cell.unReadCountBtn.isHidden = unreadCount == 0
            cell.unReadCountBtn.setTitle("\(unreadCount)", for: .normal)
//           cell.userImg.kf.setImage(with: URL(string: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//B571964C-A403-4C8C-AEFD-85C82EC127B0.jpg"))
            // Last update time
            if let submittedDate = datas.last_msg_time?.chatTimeDisplay() {
                let (timeAgo, _) = submittedDate
                cell.lastUpdateTimeLbl.text = timeAgo
                cell.lastUpdateTimeLbl.isHidden = cell.unReadCountBtn.isHidden
            } else {
                cell.lastUpdateTimeLbl.isHidden = true
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ChatVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        if let datas = staffMembersData?[indexPath.row]{
            vc.staffMembersData = datas
        }
       
        // vc.getValue = getValue
        present(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset: CGFloat = 5
        let spacing: CGFloat = 10
        let totalSpacing = inset * 2 + spacing
        let availableWidth = collectionView.frame.width - totalSpacing
        let itemWidth = availableWidth
        return CGSize(width: itemWidth, height: 110)
    }
}

extension InteractionVC : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffMembersData?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.interactTvcell,
            for: indexPath
        ) as? interactTvcell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if let datas = staffMembersData?[indexPath.row] {
            cell.nameLbl.text = datas.name ?? ""
            cell.subjectLbl.text = datas.subject_name ?? ""
            
            // Unread count handling
            let unreadCount = datas.unread_count ?? 0
            cell.unReadCountBtn.isHidden = unreadCount == 0
            cell.unReadCountBtn.setTitle("\(unreadCount)", for: .normal)
            // Last update time
            if let submittedDate = datas.last_msg_time?.chatTimeDisplay() {
                let (timeAgo, _) = submittedDate
                cell.lastUpdateTimeLbl.text = timeAgo
                cell.lastUpdateTimeLbl.isHidden = timeAgo == "Invalid time"
                cell.iconBtn.isHidden = timeAgo == "Invalid time"
            } else {
                cell.lastUpdateTimeLbl.isHidden = true
                cell.iconBtn.isHidden = true
            }
            
            cell.userImg.isHidden = datas.profile?.isEmpty ?? true
            cell.userBtn.isHidden = !cell.userImg.isHidden
            if let name = datas.name, !name.isEmpty {
                let firstTwo = String(name.prefix(2)).uppercased()
                cell.userBtn.setTitle(firstTwo, for: .normal)
            } else {
                cell.userBtn.setTitle("-", for: .normal) // fallback if empty
            }
        }
        return cell
        
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        let vc = ChatVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        if let datas = staffMembersData?[indexPath.row]{
            vc.staffMembersData = datas
        }
       
        // vc.getValue = getValue
        present(vc, animated: true)
        
        
    }
    

    func getStaff(){
        APIService.shared
            .makeApi(url: ServiceUrl.interaction_staff_details_for_chat , parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? ""){ [self] (
                result:Result <StaffListResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            staffMembersData = successMessage.data ?? []
                            tv.reloadData()
                            chatCV.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
}
