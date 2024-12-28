//
//  ExameMarVC.swift
//  VsSchoolChimes
//
//  Created by admin on 09/12/24.
//

import UIKit

class ExameMarVC: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backBtn.setTitle(ReceiverMenuItems.ExamMarks.translated(), for: .normal)
        tv.register(UINib(nibName: CellConfingName.SettingHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)
      
        let nib1 = UINib(nibName:"MarkTvCell", bundle: nil)
        tv.register(nib1, forCellReuseIdentifier: "MarkTvCell")
        
        tv.dataSource = self
        tv.delegate = self
    }


 
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

extension ExameMarVC : UITableViewDataSource,UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
  
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier:CellConfingName.SettingHeaderView) as! SettingHeaderView
//        cell.headerLabel.text = sections[section].title.translated()
//        cell.headerLabel.setFont(style: .title, size: FontSize.TitleSize)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let  cell  = tableView.dequeueReusableCell(withIdentifier: "MarkTvCell" , for: indexPath) as! MarkTvCell
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    
    
}
