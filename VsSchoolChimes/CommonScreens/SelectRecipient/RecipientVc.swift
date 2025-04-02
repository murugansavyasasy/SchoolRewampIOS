//
//  RecipientVc.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit
import DropDown

class RecipientVc: UIViewController{
   
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var speficBtnName: UIButton!
    @IBOutlet weak var sendbtnName: UIButton!
    @IBOutlet weak var selectGroupsDropDown: UIView!
    @IBOutlet weak var selectStandardDropDown: UIView!
    @IBOutlet weak var selectSectionDropdown: UIView!
    @IBOutlet weak var tv: UITableView!
  
    var cv_itemsarry : [String] = ["Entier School","Group","Standard","Section/Student"]
    var subjectDetails: [GetSubjectDetails]?
    var studentsDetails: [StudentDetails]?
    var sectionsDetails: [sectionsDetail]?
    var groupDetails: [GroupDetail]?
    var lastSelectedButton: UIButton?
    let dropDown = DropDown()
    let StdDropdown = DropDown()
    var selectedId : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        
        selectStandardDropDown.layer.cornerRadius = 10
        selectStandardDropDown.layer.shadowColor = UIColor.black.cgColor
        selectStandardDropDown.layer.shadowOffset = CGSize(width: 4, height: 4)
        selectStandardDropDown.layer.shadowOpacity = 0.5
        selectStandardDropDown.layer.shadowRadius = 4
        selectStandardDropDown.backgroundColor = .white
        selectSectionDropdown.isHidden = true
        selectStandardDropDown.isHidden = true
        selectGroupsDropDown.isHidden = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStd))
        selectStandardDropDown.addGestureRecognizer(tap2)
      
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        
        tv
            .register(
                UINib(nibName:CellConfingName.Std_Grp_header, bundle: nil),
                forHeaderFooterViewReuseIdentifier: CellConfingName.Std_Grp_header
            )
       
    }

    
    @IBAction func backbtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
   
    @IBAction func segmentAction(_ sender: Any) {
        
        
        if segmentName.selectedSegmentIndex == 0{ // Entier
            contentLbl.isHidden = false
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
        }else if segmentName.selectedSegmentIndex == 1{ // group
            getGrouplistAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        }else if segmentName.selectedSegmentIndex == 2{ // standard
            getStandardsAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
        }else if segmentName.selectedSegmentIndex == 3{ // section / spefic student
            getStudentListAPI()
            speficBtnName.isHidden = false
            contentLbl.isHidden = true
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
        }
    }
    
    @IBAction func selectStd(){
        setupStdDropdown ()
    }
    
    func setupStdDropdown (){
        
        StdDropdown.anchorView = selectStandardDropDown
        StdDropdown.dataSource = ["LKG", "UKG", "1st Standard", "2nd Standard", "3rd Standard", "4th Standard", "5th Standard"]
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectStandardDropDown.bounds.height)
        StdDropdown.show()
//        DropDown.Direction = .bottom
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
               print("Selected item: \(item) at index: \(index)")
               
               // Update the label inside the UIView
            if let label = self?.selectStandardDropDown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                   label.text = item
               }
               
           
            self!.tv.isHidden = false
           }
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    

   
   

}


extension RecipientVc : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Std_Grp_header") as! Std_Grp_header
        
        if segmentName.selectedSegmentIndex == 1 {
            head.HeaderLabel.text = "Group"
        }
        else if segmentName.selectedSegmentIndex == 2{
            head.HeaderLabel.text =  "Standard"
        }
        else if segmentName.selectedSegmentIndex == 3{
            head.HeaderLabel.text = "Section"
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentName.selectedSegmentIndex == 1 {
            return groupDetails?.count ?? 0
        }
        else if segmentName.selectedSegmentIndex == 2{
            return sectionsDetails?.count ?? 0
        }
        else if segmentName.selectedSegmentIndex == 3{
            return studentsDetails?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell , for: indexPath) as! RecipientTvCell
        
        
        
        if segmentName.selectedSegmentIndex == 1{
            cell.checkboxImg.isUserInteractionEnabled = true
            cell.cellLabel.text = groupDetails?[indexPath.row].name
        }
        else if segmentName.selectedSegmentIndex ==  2{
            cell.cellLabel.text = sectionsDetails?[indexPath.row].name
        }else{
            cell.cellLabel.text = studentsDetails?[indexPath.row].name
        }
        return cell
    }
    
    
   
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    
    func getGrouplistAPI(){
        APIService.shared
            .makeApi(
                url: ServiceUrl.recipient_get_group_list,
                parameters: [:],
                type: ApitTypeSringFile.GET ,
                token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
            ) {
                [self] (result: Result<GrouplistSuc,Error>) in
                switch result {
                case .success(let successmessage):
                    
                    if successmessage.status == true{
                        
                        DispatchQueue.main.async {[self] in
                            groupDetails = successmessage.data
                            tv.delegate = self
                            tv.dataSource = self
                            tv.reloadData()
                            
                        }
                    }else{
                        DispatchQueue.main.async {
                            print("failure")
                        }
                    }
                    
                    
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
        
    }

        

    func getStandardsAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { (result:Result <GetStandardsSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        sectionsDetails = successMessage.data
                        tv.reloadData()
                    }
                    
                }else{
                    print("Failure")
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    func getStudentListAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_student_list, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ (result:Result <GetStudentlistSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        studentsDetails = successMessage.data
                        tv.reloadData()
                    }
                }else{
                    print("Failure")
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }

        

    func getSubjectListAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_subject_list, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ (result:Result <GetSubjectlistSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        subjectDetails = successMessage.data
                        tv.reloadData()
                    }
                    
                }else{
                    print("Failure")
                    
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }

}
