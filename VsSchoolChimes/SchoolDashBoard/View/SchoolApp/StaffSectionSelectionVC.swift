//
//  StaffSectionSelectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll_IMac on 08/08/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffSectionSelectionVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        
         dismiss(animated: false, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        

        return 10
        
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
      
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaffSectionCell", for: indexPath) as! StaffSectionCell
            cell.backgroundColor = UIColor.clear
        
            return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
