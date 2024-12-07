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
    //var identifier = "StudentcardTvCell"
//    var identifier = "studCardTVcell"
    var identifier = "DemoTVCell"
    let assetColors: [String] = ["Priority", "priortitClr1", "PriorityClr2"]
    let gradientcolour : [String] = ["gradient1", "gradient2", "gradient3"]
   
    var passedValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(passedValue, forKey: "passvalue")
        
        NextButtonView.isHidden = true
        NextButtonView.layer.cornerRadius = 18
        
        priorityview.layer.cornerRadius = 20
        teacherButton.layer.cornerRadius = 20
        ParentButton.layer.cornerRadius = 20
        
        TeacherParentlbl.setFont(style: .body, size: FontSize.BodySize)
        ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)

        NextButtonView.setTitleFont(style: .body, size: FontSize.BodySize)

        print("TeacherButton: \(teacherButton)")
            print("ParentButton: \(ParentButton)")

            // Apply font styles
            TeacherParentlbl.setFont(style: .body, size: FontSize.BodySize)
            ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)

            ParentButton.setTitle("Parent", for: .normal)
            teacherButton.setTitle("Principal", for: .normal)
           ParentButton.setTitleColor(.black, for:.normal)

            DispatchQueue.main.async {
                self.teacherButton.setTitleFont(style: .body, size: FontSize.BodySize)
                self.ParentButton.setTitleFont(style: .body, size: FontSize.BodySize)
            }
        
        gradientcolours(button: NextButtonView, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        
        gradientcolours(button: teacherButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        teacherButton.tintColor = .white
        
       
        
        print("tableview.frame1", tableview.contentSize.height)
        let nib = UINib(nibName: identifier, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: identifier)
        
        let nib1 = UINib(nibName: "principalTVCell", bundle: nil)
        tableview.register(nib1, forCellReuseIdentifier: "principalTVCell")
      
        
        print("tableview.frame2", tableview.contentSize.height)
        
//        updateScrollViewContentSize()
       
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    

    @IBAction func teacherAct(_ sender: Any) {
        gradientcolours(button: teacherButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])

        //teacherButton.tintColor = .white
        teacherButton.setTitleColor(.white, for:.normal)
        
//        ParentButton.backgroundColor = .clear
        gradientcolours(button: ParentButton,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        ParentButton.setTitleColor(.black, for:.normal)
      
        
        passedValue = 1
        UserDefaults.standard.set(passedValue, forKey: "passvalue")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
       
    }
    
    
    @IBAction func ParentAct(_ sender: Any) {
        
        gradientcolours(button: ParentButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        
        ParentButton.setTitleColor(.white, for:.normal)
        
        teacherButton.backgroundColor = .clear
        
       // ParentButton.backgroundColor = .clear
        gradientcolours(button: teacherButton,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        
        teacherButton.setTitleColor(.black, for:.normal)
       
        
        passedValue = 2
        UserDefaults.standard.set(passedValue, forKey: "passvalue")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
//    func updateScrollViewContentSize() {
//            // Adjust the height constraint of the container view based on content
//            let tableViewHeight = tableview.contentSize.height
//            containerViewHeightConstraint.constant = tableViewHeight + 400 // Add extra padding if needed
//        }
    
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
        
        if selectedIndexPath != nil{
            
            let vc = TapBarVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.passedValue = passedValue
            present(vc, animated: true)
        }
    }
    
}





@available(iOS 14.0, *)
extension PriorityViewController1: UITableViewDelegate, UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let colorName = assetColors[indexPath.row % assetColors.count]
        let colour1 = UIColor(named: colorName)
        let gradient = gradientcolour[indexPath.row % gradientcolour.count]
        let colour2 =  UIColor(named: gradient)
        
        if ParentButton.tintColor == .white {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DemoTVCell
            
           
            //cell.applyGradient(colors: [colour2!.cgColor,colour1!.cgColor])
            if let color1 = colour1, let color2 = colour2 {
                        cell.setGradientColors([color2.cgColor, color1.cgColor])
                    }
            cell.SchoolInfoView.backgroundColor = colour1
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "principalTVCell", for: indexPath) as! principalTVCell
           
            //cell.applyGradient(colors: [colour2!.cgColor,colour1!.cgColor])
            if let color1 = colour1, let color2 = colour2 {
                        cell.setGradientColors([color2.cgColor, color1.cgColor])
                    }
            //cell.cellview.backgroundColor = UIColor(named: colorName)
            
            cell.checkbox.isUserInteractionEnabled = false
            cell.checkbox.isChecked = (indexPath == selectedIndexPath)
            
           
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickVC(_:)))
//            cell.checkbox.addGestureRecognizer(tapGesture)
          //  cell.checkbox.tag = indexPath.row // Tag to identify cell in selector
            
            
//            let selectedGestures = CheckBoxGesturess(target: self, action: #selector(changeSelection))
//            
//            selectedGestures.checkBoxss = cell.checkbox
//            
//            selectedGestures.pos = indexPath.row
//            cell.checkbox.addGestureRecognizer(selectedGestures)
//            
//
            
            return cell
            
        }
    }
    
    
    
    
    
    
    
//    @IBAction func changeSelection(gesture : CheckBoxGesturess){
//        
//        
//        if priorityRes[gesture.pos].isSelected == true{
//            
//            priorityRes[gesture.pos].isSelected = false
//            
//           
//            
//            gesture.checkBoxss.setImage(UIImage.init(named: "checkbox"), for: .normal)
//            
//        }else{
//            
//            gesture.checkBoxss.setImage(UIImage.init(named: "radio"), for: .normal)
//          
//           
//            priorityRes[gesture.pos].isSelected = true
//           
//            
//        }
//        
//        tableview.reloadData()
//
//        
//    }
//    
    
//    @objc func clickVC(_ sender: UITapGestureRecognizer) {
//        // Get the checkbox's row and update the selected index path
//        if let checkbox = sender.view as? UIImageView, let tableView = checkbox.superview?.superview as? UITableView {
//            
//            let indexPath = IndexPath(row: checkbox.tag, section: 0)
//            updateSelection(for: indexPath, in: tableView)
//            
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NextButtonView.isHidden = false
        // Update the selection when a row is tapped
        updateSelection(for: indexPath, in: tableView)
    }
    
    
    
    private func updateSelection(for indexPath: IndexPath, in tableView: UITableView) {
        // Check if the row was already selected
        if selectedIndexPath == indexPath {
            
            selectedIndexPath = nil // Deselect
            NextButtonView.isHidden = true
            
        } else {
            
            selectedIndexPath = indexPath // Select the new row
        }
        
        // Reload data to update the checkboxes
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Ensure checkbox is deselected if the row is deselected
        if let cell = tableView.cellForRow(at: indexPath) as? principalTVCell {
            
            cell.checkbox.isChecked = false
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//class CheckBoxGesturess : UITapGestureRecognizer {
//
//var pos : Int!
//
//var memberName : String!
//
//var checkBoxss : CheckBox!
//
//
//}





