//
//  PriorityViewController1.swift
//  SchoolchimesDemo
//
//  Created by Admin on 28/10/24.
//

import UIKit

@available(iOS 14.0, *)
class PriorityVC: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var ProceedInstructionLbl: UILabel!
    @IBOutlet weak var TeacherParentlbl: UILabel!
    @IBOutlet weak var ChooseRoleLabel: UILabel!
    @IBOutlet weak var NextButtonView: UIButton!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var priorityview: UIView!
    @IBOutlet weak var teacherButton: UIButton!
    @IBOutlet weak var ParentButton: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    var selectedIndexPath : IndexPath!
    let assetColors: [String] = ["Priority", "priortitClr1", "PriorityClr2"]
    let gradientcolour : [String] = ["gradient1", "gradient2", "gradient3"]
    let ProfileImage : [String] = ["Default_profile", "Default_profile_Male", "Default_profile_Female"]
    var login_astype = 1
    var Language :String?
    var staffDetails = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var childDetails = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    var staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    let rollname = UserDefaultFileManager.getUserDetails()?.user_details?.role_name ?? ""
    var IsAddPointApiCheck : Bool = false
    let alert = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerViewHeightConstraint.constant = 300
        Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        UserDefaults.standard.set(login_astype, forKey: "passvalue")
        StyleAndTranslate()
        teacherButton.tintColor = .white
        let nib1 = UINib(nibName: CellConfingName.SchoolTVCell, bundle: nil)
        tableview.register(nib1, forCellReuseIdentifier: CellConfingName.SchoolTVCell)
        let nib2 = UINib(nibName: CellConfingName.StudentTVCell, bundle: nil)
        let nib3 = UINib(nibName: CellConfingName.PriorityStudentTVC, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.StudentTVCell)
        tableview.register(nib3, forCellReuseIdentifier: CellConfingName.PriorityStudentTVC)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.layoutIfNeeded()
        if user_inputs.clearTempData(){
            let parms = [ "mobile_number": UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? "",
                          "activity": "LOGIN",
                          "user_type": login_astype == 1 ? 2 : 1,
                          "menu_id": 0] as [String : Any]
            paketApiCall(params:parms)
        }
    }
    
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token:  UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async { [self] in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                    if self.login_astype == 2{
                        self.IsAddPointApiCheck = true
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        apply_gradients()
    }
    
    
    func StyleAndTranslate(){
        
        //MARK: UI Changes
        NextButtonView.layer.cornerRadius = 18
        priorityview.setShadow()
        teacherButton.layer.cornerRadius = 10
        ParentButton.layer.cornerRadius = 10
        ParentButton.setTitleColor(.black, for:.normal)
        
        
        //MARK: Font Style
        TeacherParentlbl.setFont(style: .body, size: FontSize.BodySize)
        ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)
        NextButtonView.setTitleFont(style: .body, size: FontSize.BodySize)
        ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)
        teacherButton.setTitleFont(style: .body, size: FontSize.BodySize)
        ParentButton.setTitleFont(style: .body, size: FontSize.BodySize)
        ProceedInstructionLbl.setFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Translate
        ChooseRoleLabel.text =  CommonStringFile.ChooseYourRole.translated()
        let isstaff = UserDefaultFileManager.getUserDetails()?.user_details?.is_staff ?? false
        let isParent = UserDefaultFileManager.getUserDetails()?.user_details?.is_parent ?? false
        
        if(isstaff == true && isParent == true ){
            ParentButton.isHidden = false
            teacherButton.isHidden = false
        }else if(isstaff == true){
            ParentButton.isHidden = true
            teacherButton.isHidden = false
        }else if(isParent == true){
            ParentButton.isHidden = false
            teacherButton.isHidden = true
        }
        
        if staff_role == PriorityType.is_principal || staff_role == PriorityType.is_admin || staff_role == PriorityType.is_grouphead{
             NextButtonView.isHidden = false
             bottomView.isHidden = false
             ProceedInstructionLbl.isHidden = false
         }
         else{
          
             
             NextButtonView.isHidden = true
             bottomView.isHidden = true
             ProceedInstructionLbl.isHidden = true
         }
        
        
        if staff_role == PriorityType.is_principal{
            
            TeacherParentlbl.text = "\(CommonStringFile.LoginAs.translated()) \( "Management".translated() )"
        }else{
            
            TeacherParentlbl.text = CommonStringFile.LoginAsStudentParent.translated()
        }
        
        ParentButton.setTitle(CommonStringFile.Parent.translated(), for: .normal)
        teacherButton.setTitle(rollname.translated(), for: .normal)
    }
    
    func apply_gradients() {
        // Always apply gradient for NextButtonView
        gradientcolours(button: NextButtonView, colours: [UIColor.blue.cgColor, UIColor.systemTeal.cgColor])
        
        // Check visibility of teacher and parent buttons
        let teacherVisible = !teacherButton.isHidden
        let parentVisible = !ParentButton.isHidden
        
        if teacherVisible && parentVisible {
            if login_astype == 0 { // no selection yet
                login_astype = 1
            }
        } else if teacherVisible {
            // Only teacher visible
            login_astype = 1
        } else if parentVisible {
            // Only parent visible
            login_astype = 2
        }
        
        // Apply gradient based on login_astype
        if teacherVisible {
            if login_astype == 1 {
                let hexColors = ["#1E3A8A", "#3B82F6"]
                let cgColors = hexColors.map { UIColor(hex: $0.replacingOccurrences(of: "#", with: "")).cgColor }
                gradientcolours(button: teacherButton, colours: cgColors)
                teacherButton.setTitleColor(.white, for: .normal)
            } else {
                gradientcolours(button: teacherButton, colours: [UIColor.clear.cgColor, UIColor.clear.cgColor])
                teacherButton.setTitleColor(.black, for: .normal)
            }
        }
        
        if parentVisible {
            if login_astype == 2 {
                // Convert hex strings to CGColor
                let hexColors = ["#1E3A8A", "#3B82F6"]
                let cgColors = hexColors.map { UIColor(hex: $0.replacingOccurrences(of: "#", with: "")).cgColor }
                gradientcolours(button: ParentButton, colours: cgColors)
                ParentButton.setTitleColor(.white, for: .normal)
            } else {
                gradientcolours(button: ParentButton, colours: [UIColor.clear.cgColor, UIColor.clear.cgColor])
                ParentButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    
    @IBAction func teacherAct(_ sender: Any) {
        DispatchQueue.main.async {
            self.apply_gradients()
        }
        
        if staff_role == PriorityType.is_principal{
            TeacherParentlbl.text = "\(CommonStringFile.LoginAs.translated()) \( "Management".translated() )"
            
        }else{
            
            TeacherParentlbl.text = (CommonStringFile.LoginAs.translated()) + " " + (rollname.translated())
        }
        
       if staff_role == PriorityType.is_principal || staff_role == PriorityType.is_admin || staff_role == PriorityType.is_grouphead{
            NextButtonView.isHidden = false
            bottomView.isHidden = false
            ProceedInstructionLbl.isHidden = false
        }
        else{
            NextButtonView.isHidden = true
            bottomView.isHidden = true
            ProceedInstructionLbl.isHidden = true
        }
        login_astype = 1
        UserDefaults.standard.set(login_astype, forKey: "passvalue")
        tableview.reloadData()
    }
    
    
    @IBAction func ParentAct(_ sender: Any) {
        DispatchQueue.main.async {
            self.apply_gradients()
        }
        NextButtonView.isHidden = true
        bottomView.isHidden = true
        ProceedInstructionLbl.isHidden = true
        TeacherParentlbl.text = CommonStringFile.LoginAsStudentParent.translated()
        if staff_role == PriorityType.is_principal || staff_role == PriorityType.is_admin || staff_role == PriorityType.is_grouphead{
             NextButtonView.isHidden = false
             bottomView.isHidden = false
             ProceedInstructionLbl.isHidden = false
         }
         else{
             NextButtonView.isHidden = true
             bottomView.isHidden = true
             ProceedInstructionLbl.isHidden = true
         }
        
        login_astype = 2
        UserDefaults.standard.set(login_astype, forKey: "passvalue")
        tableview.reloadData()
        
    }
    
    func gradientcolours(button: UIView, colours: [CGColor]) {
        button.layoutIfNeeded()
        button.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.colors = colours
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = button.layer.cornerRadius
        gradient.frame = button.bounds
        button.layer.insertSublayer(gradient, at: 0)
    }
    
    
    
    
    @IBAction func NextAction(_ sender: Any) {
        if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
            UserDefaultFileManager.saveStaffDetails(data: data)}
        
        let vc = TapBarVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.login_astype = login_astype
        present(vc, animated: true)
    }
    @IBAction func logout(_ sender: UIButton) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "Logout")
        
        let vc = LogoutViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
    
}

@available(iOS 14.0, *)
extension PriorityVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if login_astype == 1 {
            return staffDetails?.count ?? 0
        }else{
            return childDetails?.count ?? 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let colorName = assetColors[indexPath.row % assetColors.count]
        let colour1 = UIColor(named: colorName)
        let gradient = gradientcolour[indexPath.row % gradientcolour.count]
        let colour2 =  UIColor(named: gradient)
        
        if login_astype  == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SchoolTVCell, for: indexPath) as! SchoolTVCell
            
            cell.NameLbl.text = staffDetails?[indexPath.row].name
            cell.RoleLbl.text = staffDetails?[indexPath.row].role
            cell.SchoolNamelbl.text = staffDetails?[indexPath.row].school_name
            cell.imgview.layer.cornerRadius = 8
            cell.imgview.kf
                .setImage(
                    with: URL(
                        string: staffDetails?[indexPath.row].school_logo ?? ""
                    ),
                    placeholder: UIImage(systemName: "schoolss")
                )
            if (staffDetails?[indexPath.row].school_name_regional == "") {
                cell.SchoolNameRegional.isHidden = true
            }else{
                cell.SchoolNameRegional.isHidden = false
                cell.SchoolNameRegional.text = staffDetails?[indexPath.row].school_name_regional
            }
            
            if let color1 = colour1, let color2 = colour2 {
                cell.setGradientColors([color2.cgColor, color1.cgColor])
            }
            cell.AddressLbl.text = staffDetails?[indexPath.row].school_address
            cell.arrowImage.isHidden = PriorityType.is_staff == staff_role ? false : true
            DispatchQueue.main.async {
                self.containerViewHeightConstraint.constant = self.tableview.contentSize.height
                self.view.layoutIfNeeded()
            }
            return cell
            
        } else {
            
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.PriorityStudentTVC, for: indexPath) as! PriorityStudentTVC
            cell.NameLbl.text = childDetails?[indexPath.row].name
            cell.RollNo.text = CommonStringFile.RollNo + " : " + (childDetails?[indexPath.row].roll_number ?? "")
            cell.ClassLbl.text = (childDetails?[indexPath.row].standard_name ?? "") + " - " + (childDetails?[indexPath.row].section_name ?? "")
            cell.SchoolNameLbl.text = childDetails?[indexPath.row].school_name
            cell.bloodLbl.text = childDetails?[indexPath.row].blood_group
            cell.StudentImage.kf.setImage(with: URL(string: childDetails?[indexPath.row].profile ?? ""),placeholder: UIImage(systemName: "person.fill"))
            if #available(iOS 15.0, *) {
                let gradientSets: [[CGColor]] = [ [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor], [UIColor.systemPurple.cgColor,UIColor.systemPink.cgColor], [UIColor.systemOrange.cgColor,UIColor.systemRed.cgColor], [UIColor.systemGreen.cgColor,UIColor.systemMint.cgColor], [UIColor.systemIndigo.cgColor,UIColor.systemBlue.cgColor]]
                
                let colors = gradientSets[indexPath.row % gradientSets.count]
                cell.setGradientColors(colors)
                
            }
            
            cell.SchoolAdressLbl.text = childDetails?[indexPath.row].school_city ?? ""
            cell.academicYearLbl.text = CommonStringFile.Academic_Year.translated() + " : " + (childDetails?[indexPath.row].academic_year_name ?? "")
            DispatchQueue.main.async {
                self.containerViewHeightConstraint.constant = self.tableview.contentSize.height
                self.view.layoutIfNeeded()
            }
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if login_astype  == 2 {
           
            if let data = childDetails?[indexPath.row]{
                UserDefaultFileManager.saveChildDetails(data: data)}
           
            if UserDefaultFileManager.get_child_Details()?.is_not_allow ?? false{
                alert.showAlert(title: AlertstringFile.Oops,
                                message: UserDefaultFileManager.get_child_Details()?.display_message ?? "",
                                on: self)
            }else{
                if IsAddPointApiCheck == false{
                    let parms = ["mobile_number": UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? "",
                                 "activity": "LOGIN",
                                 "user_type": login_astype == 2 ? 1 : 2,
                                 "menu_id": 0] as [String : Any]
                    paketApiCall(params:parms)
                }
                let vc = TapBarVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.login_astype = login_astype
                present(vc, animated: true)
            }
            
        }else if login_astype  == 1 {
            if staff_role == PriorityType.is_staff{
                if let data = staffDetails?[indexPath.row]{
                    UserDefaultFileManager.saveStaffDetails(data: data)
                    if IsAddPointApiCheck == false{
                        let parms = ["mobile_number": UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? "",
                                     "activity": "LOGIN",
                                     "user_type": login_astype == 2 ? 1 : 2,
                                     "menu_id": 0] as [String : Any]
                        paketApiCall(params:parms)
                    }
                    let vc = TapBarVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    vc.login_astype = login_astype
                    present(vc, animated: true)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}






