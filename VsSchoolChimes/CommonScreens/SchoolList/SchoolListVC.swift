//
//  SchoolListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit

class SchoolListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var sendBtnName: UIButton!
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var listTable: UITableView!
    var schools: [School] = [
        School(name: "ABC Public School", address: "123, Main Street, Chennai", isSelected: true),
        School(name: "XYZ International School", address: "45, Park Road, Coimbatore", isSelected: true),
        School(name: "Sunrise Academy", address: "78, MG Road, Madurai", isSelected: true),
        School(name: "Greenwood High", address: "56, Anna Nagar, Trichy", isSelected: true),
        School(name: "Bluebell School", address: "90, Gandhi Street, Salem", isSelected: true),
        School(name: "Oakridge School", address: "12, Nelson Road, Erode", isSelected: true),
        School(name: "Little Angels Academy", address: "67, Cross Road, Tirunelveli", isSelected: true),
        School(name: "Springfield High", address: "34, Lake View, Vellore", isSelected: true),
        School(name: "Elite Public School", address: "89, New Colony, Thanjavur", isSelected: true),
        School(name: "St. Joseph's Matric", address: "23, Temple Road, Kanyakumari", isSelected: true)
    ]
    var screen_type : String?
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    override func viewDidLoad() {
        super.viewDidLoad()
        sendBtnName.isHidden = true
        listTable.register(UINib(nibName:CellConfingName.SchoolListTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SchoolListTVC)
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @IBAction func segment_action(_ sender: Any) {
       
        if segmentName.selectedSegmentIndex == 0 {
            sendBtnName.isHidden = false
            listTable.reloadData()
        }else{
            sendBtnName.isHidden = true
            listTable.reloadData()
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return school_details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: CellConfingName.SchoolListTVC, for: indexPath) as! SchoolListTVC
        let schools_details  = school_details?[indexPath.row]
        cell.name.text = schools_details?.school_name
        cell.address.text = schools_details?.city
        cell.schoolRelignLangLbl.text = schools_details?.school_name_regional
        
        if segmentName.selectedSegmentIndex == 0{
            let img = schools[indexPath.row].isSelected ? UIImage(named: "checkedSquare") : UIImage(named: "uncheckedSquare")
            cell.selectedBtn.setImage(img, for: .normal)
        }else{
            
            cell.selectedBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        if segmentName.selectedSegmentIndex == 0{
           
            schools[indexPath.row].isSelected.toggle()
            listTable.reloadData()
        }else{
            ServiceUrl.token = school_details?[indexPath.row].access_token ?? ""
            let vc = RecipientVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func selectedSchool(_ sender: Any) {
        
        let vc = RecipientVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)

                
    }
    @objc func dismissBlurEffect() {
        // You can dismiss or handle the tap here
        print("Background tapped, but modal won't dismiss.")
    }
}
struct School {
    let name: String
    let address: String
    var isSelected: Bool
}
