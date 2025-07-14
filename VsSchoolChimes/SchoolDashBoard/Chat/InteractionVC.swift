//
//  InteractionVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/01/25.
//

import UIKit

class InteractionVC: UIViewController {
    @IBOutlet weak var NameStandardStackView: UIStackView!
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var HeaderLbl: UILabel!
   
    var passvalue = 0
    var staffMembersData: [StaffMember]?
    var childDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn.applyBackButton()
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        HeaderLbl.setFont(style: .header, size: 17)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        let nib = UINib(nibName: CellConfingName.interactTvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.interactTvcell)
        tv.delegate = self
        tv.dataSource = self
        getStaff()
        
       
        
    }
    
    override func viewDidLayoutSubviews() {
        if passvalue == 1{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            backBtn.setTitle("Interact With Staff", for: .normal)
            NameStandardStackView.isHidden = false
        }
        else if passvalue == 2{
            backBtn.setTitle("Interact With Student", for: .normal)
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            NameStandardStackView.isHidden = true
        }
    }
    
    @IBAction func BackAct(_ sender: Any) {
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
            .makeApi(url: ServiceUrl.interaction_staff_details_for_chat , parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? ""){ [self] (
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
