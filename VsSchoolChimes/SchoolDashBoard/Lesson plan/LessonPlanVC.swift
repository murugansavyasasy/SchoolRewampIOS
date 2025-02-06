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
    let cellcolour = [Colornames.lesson1,Colornames.lesson2,Colornames.lesson3]
    var id  = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.backgroundImage = UIImage()
        searchBar.layer.borderWidth = 0
        searchBar.layer.borderColor = UIColor.clear.cgColor

        ButtonStackview.layer.cornerRadius = 20
        createBtn.layer.cornerRadius = 20
        viewBtn.layer.cornerRadius = 20
        gradientcolours(button: createBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createBtn.setTitleColor(UIColor.white, for: .normal)
        addDoneButton()
        let nib1 = UINib(nibName: CellConfingName.LessonPlanTvCell, bundle: nil)
        tableview.register(nib1, forCellReuseIdentifier: CellConfingName.LessonPlanTvCell)
        let nib = UINib(nibName: CellConfingName.LessonDetailsTVcell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.LessonDetailsTVcell)
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
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
        if id == 1{
            id = 0
            tableview.reloadData()
        }else{
            dismiss(animated: true)
        }
    }
}


extension LessonPlanVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  id == 0{
            return  6
        }else{
            return  4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  id == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonPlanTvCell, for: indexPath) as! LessonPlanTvCell
            cell.getvalue(a: Int(complete[indexPath.row]), b: Int(pending[indexPath.row]))
            cell.val1 = complete[indexPath.row]
            cell.val2 = pending[indexPath.row]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewbtnAct))
            cell.navigateview.addGestureRecognizer(tap)
            cell.navigateview.isUserInteractionEnabled = true
            return cell
            
        }else{
            let colour = cellcolour[indexPath.row % cellcolour.count]
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonDetailsTVcell, for: indexPath) as! LessonDetailsTVcell
            //cell.startProgressAnimation(duration: 9.0)
            cell.Cellview.backgroundColor = colour
            cell.startProgressAnimation()
            return cell
        }
    }
    
    @IBAction func ViewbtnAct() {
        id = 1
        tableview.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if id == 0{
            let cell = tableView.cellForRow(at: indexPath) as! LessonPlanTvCell
            
            cell.animatePopUpEffect()
        }
    }
}

extension LessonPlanVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    func addDoneButton(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
            
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(DoneBtnAct))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)


        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        searchBar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        searchBar.resignFirstResponder()
    }

}
