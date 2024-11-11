//
//  LanguageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 08/11/24.
//

import UIKit

class LanguageVc: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    
    var Items = ["English" , "Tamil","Hindi" , "Thai"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
        tv.dataSource = self
        tv.delegate = self
        tv.reloadData()
        
        let nib = UINib(nibName: CellConfingName.LangTvCellTableViewCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:  CellConfingName.LangTvCellTableViewCell)
    }


    @IBAction func backClick(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

}

@available(iOS 14.0, *)
extension LanguageVc : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LangTvCellTableViewCell , for: indexPath) as! LangTvCellTableViewCell
        
       
        cell.LangLbl.text = Items[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LangTvCellTableViewCell , for: indexPath) as! LangTvCellTableViewCell
        
       
       
        if  Items[indexPath.row] == "Tamil"{
            
            
//            DefaultsKeys.Language = ""
            
        }
        else if   Items[indexPath.row] == "Thai"{
            
            
        }
        
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  60
    }
    
    
}
