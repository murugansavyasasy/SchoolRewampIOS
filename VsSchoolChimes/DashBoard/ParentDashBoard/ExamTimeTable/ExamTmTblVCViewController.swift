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
    
    var SideItemArry = ["QuatalyExamQuatalyExam","SSlC ExamQuatalyExam","Hsc ExamQuatalyExam","HalfYearExamQuatalyExam"]
    var  TvSide = [""]
    var isCellSelected = false
    var selectedIdex : Int!
    var  count = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let nib = UINib(nibName:CellConfingName.SideTvcell, bundle: nil)
        sideTv.register(nib, forCellReuseIdentifier: CellConfingName.SideTvcell)
        
        let nib1 = UINib(nibName:CellConfingName.Tvcell, bundle: nil)
        tv.register(nib1, forCellReuseIdentifier: CellConfingName.Tvcell)
        
        sideTv.delegate = self
        sideTv.dataSource = self
        tv.delegate = self
        tv.dataSource = self
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
            
            if selectedIdex == indexPath.row{
                
                cell.layer.cornerRadius = 10
                                 cell.clipsToBounds = true
                cell.backgroundColor = .parentClr
                
                count = indexPath.row+1
                tv.reloadData()
                
            }else{
                
                
                cell.backgroundColor = .white // Default background color
                       cell.layer.cornerRadius = 0  // Reset corner radius for reuse
                       cell.clipsToBounds = true    // Ensures corner radius is applied
            }
           
            
            
            cell.ExameLbl.text = SideItemArry[indexPath.row]
            return cell
        }else{
           
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.Tvcell, for: indexPath) as! Tvcell
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == sideTv{
            
//            if isCellSelected { return }
//              isCellSelected = true
//
//              if let cell = tableView.cellForRow(at: indexPath) {
//                  // Example: Change cell appearance
//                  cell.layer.cornerRadius = 10
//                  cell.clipsToBounds = true
//                  cell.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
//              }
//
//              // Simulate a delay for the action and reset the flag
//              DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                  self.isCellSelected = false
//                  tableView.deselectRow(at: indexPath, animated: true)
//              }
            
            
            selectedIdex = indexPath.row
            
            sideTv.reloadData()
            
            
        }
        
        else{
     
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if tableView == sideTv{
            
            
            return UITableView.automaticDimension
        }else{
            return 150
            
        }
    }
}
