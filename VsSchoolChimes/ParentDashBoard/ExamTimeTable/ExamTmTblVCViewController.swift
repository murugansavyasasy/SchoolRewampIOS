//
//  ExamTmTblVCViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 23/11/24.
//

import UIKit

class ExamTmTblVCViewController: UIViewController {
    
    @IBOutlet weak var sideTv: UITableView!
    @IBOutlet weak var tv: UITableView!
    var SideItemArry = ["Quaterly Exam","Half yearly exam","Internal Assesment Exam","Modal exam","Class Test"]
    var  TvSide = [""]
    var isCellSelected = false
    var selectedIndex : IndexPath?
    var  count = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName:CellConfingName.SideTvcell, bundle: nil)
        sideTv.register(nib, forCellReuseIdentifier: CellConfingName.SideTvcell)
        
        let nib1 = UINib(nibName:CellConfingName.Tvcell, bundle: nil)
        tv.register(nib1, forCellReuseIdentifier: CellConfingName.Tvcell)
        
        selectedIndex = IndexPath(row: 0, section: 0)
        
        sideTv.delegate = self
        sideTv.dataSource = self
        tv.delegate = self
        tv.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ExamTmTblVCViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == sideTv{
            return SideItemArry.count
        }else{
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == sideTv{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SideTvcell, for: indexPath) as! SideTvcell
            
            cell.ExameLbl.text = SideItemArry[indexPath.row]
            
            if selectedIndex == indexPath {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
            
            return cell
            
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.Tvcell, for: indexPath) as! Tvcell
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == sideTv{
            
            selectedIndex = indexPath
            count = Int.random(in: 1...5)
           // sideTv.reloadData()
            tv.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

