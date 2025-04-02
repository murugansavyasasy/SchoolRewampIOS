//
//  RecipientVc.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit
import DropDown

class RecipientVc: UIViewController, CustomCollectionViewCellDelegate {
   
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
    var lastSelectedButton: UIButton?
    
    var Group: [Section] = [
           Section(title: "Group", items: ["Teachers group", "Students group"])
       ]
    
   var standard : [Section] = [
    Section(title: "Standard", items: ["LKG", "UKG", "1st Standard", "2nd Standard", "3rd Standard", "4th Standard", "5th Standard"])
]
    
    
    
    var sections: [Section] = [
           Section(title: "Section", items: ["A section", "B section", "C section", "D section", "E section"])
       ]
    
    let segmentTitles: [String] = ["Entier School","Group","Standard","Section/Student"]
    
    let dropDown = DropDown()
    let StdDropdown = DropDown()
    var flag = 0
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
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectSec))
        selectSectionDropdown.addGestureRecognizer(tap3)
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        
        tv.register(UINib(nibName:"Std_Grp_header", bundle: nil), forHeaderFooterViewReuseIdentifier: "Std_Grp_header")
        
        
        
               
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
            flag = 1
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        }else if segmentName.selectedSegmentIndex == 2{ // standard
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            flag = 3
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            tv.dataSource = self
            tv.delegate = self
            tv.reloadData()
        }else if segmentName.selectedSegmentIndex == 3{ // section / spefic student
            speficBtnName.isHidden = false
            contentLbl.isHidden = true
            flag = 2
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
        }
    }
    
    @IBAction func selectStd(){
        setupStdDropdown ()
    }
    
    @IBAction func selectSec(){
        
//        setupSecDropdown()
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
extension RecipientVc : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
       
        
        return CGSize(width: 180, height: 50)
    }
}
extension RecipientVc : UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cv_itemsarry.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipientCVcell", for: indexPath) as! RecipientCVcell
        
        cell.btnName.setTitle(cv_itemsarry[indexPath.item], for: .normal)
        cell.delegate = self
        
        cell.configureCell(indexPath: indexPath)
        return cell
        
    }
    
    
    func didTapButtonInCell(at indexPath: IndexPath,button: UIButton) {
            // Handle button tap action here
        
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 2
        
        let selectedItem = cv_itemsarry[indexPath.item]
        if selectedItem == "Entier School"{
            
            contentLbl.isHidden = false
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
        }else if selectedItem == "Group"{
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            flag = 1
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            tv.dataSource = self
            tv.delegate = self
            tv.reloadData()
        }else if selectedItem == "Standard"{
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            flag = 3
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            tv.dataSource = self
            tv.delegate = self
            tv.reloadData()
        }else if selectedItem == "Section/Student"{
            speficBtnName.isHidden = false
            contentLbl.isHidden = true
            flag = 2
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
        }
        
        }
}

extension RecipientVc : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if flag == 1 {
            return Group.count
        }
        else if flag == 2{
            return sections.count
        }else if flag == 3{
            return standard.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Std_Grp_header") as! Std_Grp_header
        
        if flag == 1 {
            head.HeaderLabel.text = Group[section].title
        }
        else if flag == 2{
            head.HeaderLabel.text = sections[section].title
        }
        else if flag == 3{
            head.HeaderLabel.text = standard[section].title
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if flag == 1 {
            return Group[section].items.count
        }
        else if flag == 2{
            return sections[section].items.count
        }
        else if flag == 3{
            return standard[section].items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell , for: indexPath) as! RecipientTvCell
        
        
        
        if flag == 1{
            cell.checkboxImg.isUserInteractionEnabled = true
            cell.cellLabel.text = Group[indexPath.section].items[indexPath.row]
            let checkClick = checkClick(target: self, action: #selector(CheckBoxclick))
            checkClick.index = indexPath.row
            checkClick.indexs = indexPath
            cell.checkboxImg.addGestureRecognizer(checkClick)
        }
        else if flag == 2{
           
            cell.cellLabel.text = sections[indexPath.section].items[indexPath.row]
        }else{
            
            
            cell.cellLabel.text = standard[indexPath.section]
                .items[indexPath.row]
        }
        return cell
    }
    
    
    @IBAction func CheckBoxclick(ges : checkClick){
        
        let cell = tv.dequeueReusableCell(
            withIdentifier: CellConfingName.RecipientTvCell ,
            for: ges.indexs
        ) as! RecipientTvCell
        
        cell.checkboxImg.image = ImageName.checkedsquare
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
                            print("Success")
                            
                            tv.dataSource = self
                            tv.delegate = self
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
                        print("success")
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
                        print("success")
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
                        print("success")
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
