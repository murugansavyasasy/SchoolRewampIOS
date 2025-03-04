//
//  LessonPlanVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit

class LessonPlanVC: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet var ButtonStackview: UIStackView!
    @IBOutlet weak var tableview: UITableView!
    
    let complete :[Double] = [75,60,83,47,90,32]
    let pending :[Double] = [25,40,17,53,10,68]
    let cellcolour = [Colornames.lesson1,Colornames.lesson2,Colornames.lesson3]
    let colours1 = ["AttendenceColor","Clr","Color","lesson1","lesson3"]
    var id  = 2//0
    
    let lessonPlans: [LessonPlan] = [
        LessonPlan(subject: "Principles of Management", className: "XI - A", staffName: "Lakshmanan S", progress: 30),
        LessonPlan(subject: "Business Studies", className: "XI - B", staffName: "Anita R", progress: 50),
        LessonPlan(subject: "Economics", className: "XI - C", staffName: "Vikram K", progress: 75),
        LessonPlan(subject: "Accountancy", className: "XI - D", staffName: "Meera J", progress: 16),
        LessonPlan(subject: "Marketing", className: "XI - E", staffName: "Suresh P", progress: 60),
        LessonPlan(subject: "Financial Management", className: "XI - F", staffName: "Divya M", progress: 80),
        LessonPlan(subject: "Entrepreneurship", className: "XI - G", staffName: "Ramesh T", progress: 35),
        LessonPlan(subject: "Human Resource Management", className: "XI - H", staffName: "Priya N", progress: 90)
    ]
    
    let colours = ["gradient1","gradient2","gradient3","gradientBlue1","gradientgreen1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIupdate()
        BackBtn.applyBackButton()
        gradientcolours(button: createBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createBtn.setTitleColor(UIColor.white, for: .normal)
        
        addDoneButton()
        
        let nib1 = UINib(nibName: CellConfingName.LessonPlanTvCell, bundle: nil)
        tableview.register(nib1, forCellReuseIdentifier: CellConfingName.LessonPlanTvCell)
        let nib = UINib(nibName: CellConfingName.LessonProgressCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.LessonProgressCell)
        
        let nib2 = UINib(nibName: CellConfingName.LessonDashboardTv, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.LessonDashboardTv)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func UIupdate(){
        searchBar.backgroundImage = UIImage()
        searchBar.layer.borderWidth = 0
        searchBar.layer.borderColor = UIColor.clear.cgColor

        ButtonStackview.layer.cornerRadius = 20
        createBtn.layer.cornerRadius = 20
        viewBtn.layer.cornerRadius = 20
        
        createBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        viewBtn.setTitleFont(style: .body, size: FontSize.BodySize)
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
            // Randomly select either 0 or 2
            let randomValue = Int.random(in: 0...2) == 0 ? 0 : 2
            id = randomValue//0
            tableview.reloadData()
        }else{
            dismiss(animated: true)
        }
    }
}


@available(iOS 15.0, *)
extension LessonPlanVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  id == 0{
            return  6
        }else if id == 2{
            return lessonPlans.count
        }else{
            return  10
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
            
        }else if id == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonDashboardTv, for: indexPath) as! LessonDashboardTv
            cell.SubjectLbl.text = lessonPlans[indexPath.row].subject
            cell.StandardLbl.text = lessonPlans[indexPath.row].className
            cell.setProgress(to: lessonPlans[indexPath.row].progress)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewbtnAct))
            cell.ViewBtn.addGestureRecognizer(tap)
            return cell
        }
        else{
            let colour = cellcolour[indexPath.row % cellcolour.count]
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonProgressCell, for: indexPath) as! LessonProgressCell
    
            // Set the default state before configuring the cell
            cell.progressView.backgroundColor = .systemGreen  // Default color
           // cell.ProgressHeight.constant = 85  // Default height
            
            if indexPath.row == 0{
                cell.TopProgressView.isHidden = true
            }
            
            let colour1 = indexPath.row % colours1.count
            cell.Baseview.backgroundColor = UIColor(named: colours1[colour1])
            
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            
            if indexPath.row > 5 {
                cell.checkImageView.image = UIImage(named: "CheckCircle")
                cell.progressView.backgroundColor = .lightGray
                cell.TopProgressView.backgroundColor = .lightGray
            } else {
                cell.checkImageView.image = UIImage(named: "round")
                cell.progressView.backgroundColor = .systemGreen
            }
            
            if indexPath.row == totalRows - 1 {
                //cell.ProgressHeight.constant = 0
                cell.progressView.isHidden = true
            } else {
                // Calculate dynamic height if needed
                //    let distance = distanceBetweenImageViews(in: tableView, at: indexPath)
                //    cell.ProgressHeight.constant = distance ?? 85
            }
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
           
        }
    }
    
    func distanceBetweenImageViews(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat? {
        // Ensure there's a next row
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        guard indexPath.row + 1 < tableView.numberOfRows(inSection: indexPath.section) else {
                    return nil
                }
        guard let currentCell = tableView.cellForRow(at: indexPath) as? LessonProgressCell,
              let nextCell = tableView.cellForRow(at: nextIndexPath) as? LessonProgressCell else {
            return nil // Return nil if the next cell is not visible
        }

        // Get image view centers
        let currentImageCenter = currentCell.checkImageView.center
        let nextImageCenter = nextCell.checkImageView.center

        // Calculate Euclidean distance
        let distance = sqrt(pow(nextImageCenter.x - currentImageCenter.x, 2) +
                            pow(nextImageCenter.y - currentImageCenter.y, 2))
        print("distance between images",distance)

        return distance
    }

//    func distanceBetweenImageViews(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat? {
//        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
//        // Add this check at the beginning of your function
//        guard indexPath.row + 1 < tableView.numberOfRows(inSection: indexPath.section) else {
//            return nil
//        }
//        // Use dequeueReusableCell instead of cellForRow
//        guard let currentCell = tableView.dequeueReusableCell(withIdentifier: "LessonProgressCell") as? LessonProgressCell,
//              let nextCell = tableView.dequeueReusableCell(withIdentifier: "LessonProgressCell") as? LessonProgressCell else {
//            return nil
//        }
//        
//        // Configure cells if needed
//        // currentCell.configure(with: yourDataSource[indexPath.row])
//        // nextCell.configure(with: yourDataSource[nextIndexPath.row])
//        
//        // Force layout if needed
//        currentCell.layoutIfNeeded()
//        nextCell.layoutIfNeeded()
//        
//        // Convert image view center to table view coordinates
//        let currentImageCenter = currentCell.checkImageView.convert(currentCell.checkImageView.center, to: tableView)
//        let nextImageCenter = nextCell.checkImageView.convert(nextCell.checkImageView.center, to: tableView)
//        
//        // Calculate Euclidean distance
//        let distance = sqrt(pow(nextImageCenter.x - currentImageCenter.x, 2) +
//                           pow(nextImageCenter.y - currentImageCenter.y, 2))
//        
//        return distance
//    }
    
  
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


struct LessonPlan {
    let subject: String
    let className: String
    let staffName: String
    let progress: Double
}
