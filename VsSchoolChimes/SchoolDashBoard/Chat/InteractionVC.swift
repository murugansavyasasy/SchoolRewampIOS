//
//  InteractionVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/01/25.
//

import UIKit

class InteractionVC: UIViewController {
   
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
      
        backBtn.applyBackButton()
        FullView.layer.cornerRadius = 30
        FullView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        FullView.layer.masksToBounds = true
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        let name = studentDetails?.name ?? ""
        let standard = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        backBtn.configureAsBackButton(firstLine: name, secondLine: standard, colour: .white)
        let nib = UINib(nibName: CellConfingName.interactTvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.interactTvcell)
        tv.delegate = self
        tv.dataSource = self
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
        
        let datas = staffMembersData?[indexPath.row]
        cell.teacherNameLbl.text = datas?.name ?? ""
        cell.subjectNameLbl.text = datas?.subject_name ?? ""
        
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
