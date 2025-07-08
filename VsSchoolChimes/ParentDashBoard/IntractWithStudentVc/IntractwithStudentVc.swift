//
//  IntractwithStudentVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/07/25.
//

import UIKit

class IntractwithStudentVc: UIViewController {

    @IBOutlet weak var tv: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }


   
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }

}

//extension IntractwithStudentVc:UITableViewDelegate,UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//    }
//}
