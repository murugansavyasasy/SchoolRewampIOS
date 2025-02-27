//
//  ReciverAttendanceReportVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 19/12/24.
//

import UIKit

class ReciverAttendanceReportVC: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    let date = 11
    let day = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
    let present = [true,true,false,true,false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslate()
        CellRigister()
        TV.delegate = self
        TV.dataSource = self
        TV.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    //MARK: UI Changes
    func StyleAndTranslate(){
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
    }
    
    //MARK: Cell Registeration
    func CellRigister(){
        let nib = UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

//MARK: Tableview Functions
extension ReciverAttendanceReportVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.ReciverAttendReportTV, for: indexPath) as! ReciverAttendReportTV
        
        cell.DateLbl.text = String (date + indexPath.row)
        cell.dayLbl.text = day[indexPath.row]
        
        cell.statusLbl.textColor = .white
        if present[indexPath.row] == true {
            cell.statusLbl.text = CommonStringFile.Present.translated()
            cell.StatusView.backgroundColor = .systemGreen
        }else{
            cell.statusLbl.text = CommonStringFile.Absent.translated()
            cell.StatusView.backgroundColor = .systemRed
            cell.MonthView.backgroundColor =  UIColor(named: "Red")
            cell.DateView.backgroundColor =  .white
            cell.DateView.layer.borderWidth = 0.5
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
}
