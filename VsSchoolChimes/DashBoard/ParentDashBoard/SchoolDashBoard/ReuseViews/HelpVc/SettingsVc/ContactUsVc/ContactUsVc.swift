//
//  ContactUsVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class ContactUsVc: UIViewController {

   
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 100
        
    }
    
}
