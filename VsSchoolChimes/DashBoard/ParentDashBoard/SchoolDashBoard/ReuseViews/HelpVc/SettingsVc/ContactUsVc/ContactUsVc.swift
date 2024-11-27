//
//  ContactUsVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class ContactUsVc: UIViewController {

   
    @IBOutlet weak var ContactusHeader: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    var content = ["Our 24*7 Customer Service.","Write us at."]
    var contact = ["9786543210","support@savyasasy.com"]
    var icon  = [UIImage(named: "Phone"),UIImage(named: "Phone")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ContactusHeader.text = "Contact Us".translated()
        tv.dataSource = self
        tv.delegate = self
        
//        tv.rowHeight = UITableView.automaticDimension
//        tv.estimatedRowHeight = 60
        
        let nib = UINib(nibName: CellConfingName.ContactUsTVCell, bundle: nil)
        
        tv.register(nib, forCellReuseIdentifier: CellConfingName.ContactUsTVCell)

        
        
    }

    

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

}

extension ContactUsVc : UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ContactUsTVCell, for: indexPath) as! ContactUsTVCell
        
        cell.contentLabel.text = content[indexPath.row]
        cell.mailOrPhoneLabel.text = contact[indexPath.row]
        cell.iconImg.image = icon[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 100
        
    }
    
}
