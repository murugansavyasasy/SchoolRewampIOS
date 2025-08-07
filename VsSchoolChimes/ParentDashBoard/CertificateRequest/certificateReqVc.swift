//
//  certificateReqVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit

class certificateReqVc: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "certificateReqTVCell") as? certificateReqTVCell else{
                return UITableViewCell()
            }
            
            
            return cell
          } else {
              
              guard let cell = tableView.dequeueReusableCell(withIdentifier: "certificateHstryCell") as? certificateHstryCell else{
                  return UITableViewCell()
              }
              
              cell.configure()
              
              
              return cell
          }
        
        
        
    }
    
  
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "certificateHstryCell") as? certificateHstryCell else {
                return 100
            }
            cell.configure()
            return cell.collectionContentHeight() + 60
        }
        
    }


    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tv
            .register(
                UINib(nibName: "certificateReqTVCell", bundle: nil),
                forCellReuseIdentifier: "certificateReqTVCell"
            )
        tv
            .register(
                UINib(nibName: "certificateHstryCell", bundle: nil),
                forCellReuseIdentifier: "certificateHstryCell"
            )
        
        tv.dataSource = self
        tv.delegate = self
    }


    @IBAction func backbtn(_ sender: Any) {
        dismiss(animated: true)
    }
  
}
