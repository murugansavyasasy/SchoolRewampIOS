//
//  LessonPlanVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit

class LessonPlanVC: UIViewController {

    @IBOutlet weak var FilterImgview: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet var ButtonStackview: UIStackView!
    @IBOutlet weak var tableview: UITableView!
    
    let complete :[Double] = [75,60,83,47,90,32]
    let pending :[Double] = [25,40,17,53,10,68]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ButtonStackview.layer.cornerRadius = 20
        createBtn.layer.cornerRadius = 20
        viewBtn.layer.cornerRadius = 20
        
        gradientcolours(button: createBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createBtn.setTitleColor(UIColor.white, for: .normal)
//        
        let nib = UINib(nibName: CellConfingName.LessonPlanTvCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.LessonPlanTvCell)
        
        
//        let nib = UINib(nibName: CellConfingName.LessonDetailsTVcell, bundle: nil)
//        tableview.register(nib, forCellReuseIdentifier: CellConfingName.LessonDetailsTVcell)
//        tableview.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableview.delegate = self
        tableview.dataSource = self
        
        

       
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
    
    @IBAction func createBtnAct(_ sender: Any) {
        gradientcolours(button: createBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: viewBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        viewBtn.setTitleColor(UIColor.black, for: .normal)
        
       
    }
    
    @IBAction func viewBtnAct(_ sender: Any) {
        
        gradientcolours(button: viewBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        viewBtn.setTitleColor(UIColor.white, for: .normal)
        
        gradientcolours(button: createBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        createBtn.setTitleColor(UIColor.black, for: .normal)
       
       
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
   
}


extension LessonPlanVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonDetailsTVcell, for: indexPath) as! LessonDetailsTVcell
//        //cell.startProgressAnimation(duration: 9.0)
//        cell.startProgressAnimation()
      
//        MARK: Lesson plan tvcell
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonPlanTvCell, for: indexPath) as! LessonPlanTvCell
        cell.getvalue(a: Int(complete[indexPath.row]), b: Int(pending[indexPath.row]))
        cell.val1 = complete[indexPath.row]
        cell.val2 = pending[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LessonPlanTvCell
        
        cell.animatePopUpEffect()
    }

    
    
}
