//
//  PriorityViewController1.swift
//  SchoolchimesDemo
//
//  Created by Admin on 28/10/24.
//

import UIKit

@available(iOS 14.0, *)
class PriorityViewController1: UIViewController {
    
    @IBOutlet weak var TeacherParentlbl: UILabel!
    @IBOutlet weak var ChooseRoleLabel: UILabel!
    @IBOutlet weak var NextButtonView: UIButton!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var priorityview: UIView!
    @IBOutlet weak var teacherButton: UIButton!
    @IBOutlet weak var ParentButton: UIButton!
    
    var selectedIndexPath : IndexPath!
    
    let assetColors: [String] = ["Priority", "priortitClr1", "PriorityClr2"]
    let gradientcolour : [String] = ["gradient1", "gradient2", "gradient3"]
    let ProfileImage : [String] = ["Default_profile", "Default_profile_Male", "Default_profile_Female"]
    var passedValue = 1
    var Language :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        UserDefaults.standard.set(passedValue, forKey: "passvalue")
    
        StyleAndTranslate()
        
        gradientcolours(button: NextButtonView, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
       
        gradientcolours(button: teacherButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        teacherButton.tintColor = .white
        
        let nib = UINib(nibName: CellConfingName.DemoTVCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.DemoTVCell)
        
        let nib1 = UINib(nibName: CellConfingName.principalTVCell, bundle: nil)
        tableview.register(nib1, forCellReuseIdentifier: CellConfingName.principalTVCell)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }

 
   func StyleAndTranslate(){
        
       //MARK: UI Changes
       NextButtonView.layer.cornerRadius = 18
       priorityview.layer.cornerRadius = 20
       teacherButton.layer.cornerRadius = 20
       ParentButton.layer.cornerRadius = 20
       ParentButton.setTitleColor(.black, for:.normal)
      
       
       //MARK: Font Style
       TeacherParentlbl.setFont(style: .body, size: FontSize.BodySize)
       ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)
       NextButtonView.setTitleFont(style: .body, size: FontSize.BodySize)
       TeacherParentlbl.setFont(style: .body, size: FontSize.BodySize)
       ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)
       teacherButton.setTitleFont(style: .body, size: FontSize.BodySize)
       ParentButton.setTitleFont(style: .body, size: FontSize.BodySize)
       
       //MARK: Translate
       ChooseRoleLabel.text =  CommonStringFile.ChooseYourRole.translated()
       TeacherParentlbl.text =  CommonStringFile.LoginAsPrincipalOrParent.translated()
       ParentButton.setTitle(CommonStringFile.Parent.translated(), for: .normal)
       teacherButton.setTitle(CommonStringFile.Principal.translated(), for: .normal)
    }
    
    @IBAction func teacherAct(_ sender: Any) {
        NextButtonView.isHidden = false
        gradientcolours(button: teacherButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        teacherButton.setTitleColor(.white, for:.normal)
        
        
        gradientcolours(button: ParentButton,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        ParentButton.setTitleColor(.black, for:.normal)
        
        passedValue = 1
        UserDefaults.standard.set(passedValue, forKey: "passvalue")
        tableview.reloadData()
    }
    
    
    @IBAction func ParentAct(_ sender: Any) {
        NextButtonView.isHidden = true
        gradientcolours(button: ParentButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        ParentButton.setTitleColor(.white, for:.normal)
        
        //teacherButton.backgroundColor = .clear
        
        
        gradientcolours(button: teacherButton,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        teacherButton.setTitleColor(.black, for:.normal)
        
        
        passedValue = 2
        UserDefaults.standard.set(passedValue, forKey: "passvalue")
        tableview.reloadData()
    }
    
    
    func gradientcolours(button : UIButton,colours : [CGColor]){
        
        
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius
        
        // Insert the gradient layer into the button's layer
        button.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    @IBAction func NextAction(_ sender: Any) {
        let vc = TapBarVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.passedValue = passedValue
        present(vc, animated: true)
    }
    
    
}

@available(iOS 14.0, *)
extension PriorityViewController1: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if passedValue == 1 {
            
            return 5
        }else{
            
            return 10
            
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let colorName = assetColors[indexPath.row % assetColors.count]
        let colour1 = UIColor(named: colorName)
        let gradient = gradientcolour[indexPath.row % gradientcolour.count]
        let colour2 =  UIColor(named: gradient)
        
        let image = UIImage(named: ProfileImage[indexPath.row % ProfileImage.count])
        
        if passedValue  == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.DemoTVCell, for: indexPath) as! DemoTVCell
            
            cell.SchoolInfoView.backgroundColor = colour1
            cell.imgview.image = image
            if indexPath.row == 8{
                cell.imgview.image = ImageName.person_circle
            }
            if let color1 = colour1, let color2 = colour2 {
                cell.setGradientColors([color2.cgColor, color1.cgColor])
            }
            cell.arrowImg.applyRTLFlip(Language == "ar")
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.principalTVCell, for: indexPath) as! principalTVCell
            
            
            if let color1 = colour1, let color2 = colour2 {
                cell.setGradientColors([color2.cgColor, color1.cgColor])
            }
            
    
            
            
            return cell
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if passedValue  == 2 {
            
            let vc = TapBarVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.passedValue = passedValue
            present(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}






