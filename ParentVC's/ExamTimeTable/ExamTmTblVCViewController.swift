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
    
    var SideItemArry = [""]
    var  TvSide = [""]
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


  
}
extension ExamTmTblVCViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == sideTv{
            
            
            return 10
        }else{
            return 10
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == sideTv{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SideTvcell, for: indexPath) as! SideTvcell
            
            return cell
        }else{
           
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.Tvcell, for: indexPath) as! Tvcell
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == sideTv{
            
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
