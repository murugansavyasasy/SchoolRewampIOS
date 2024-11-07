//
//  RateUs_ViewController.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit
protocol RatingDelegate{
    func rating(_ ratingcount:Int)
    func Submit(_ category:Set<String>,suggessions:String)
}
class RateUsViewController: UIViewController{

    @IBOutlet weak var tableview: UITableView!
    var isSelected:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UiUpdate()
        
    }
    func UiUpdate(){
        tableview.register(UINib(nibName: "BanerTableViewCell", bundle: nil), forCellReuseIdentifier: "BanerTableViewCell")
        tableview.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingTableViewCell")
        tableview.register(UINib(nibName: "RatingTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingTypeTableViewCell")
    }
   
}

extension RateUsViewController:UITableViewDelegate,UITableViewDataSource, RatingDelegate {
    func Submit(_ category:Set<String>,suggessions:String) {
        print(category)
        let vc = SubmitRatingViewController(nibName: "SubmitRatingViewController", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func rating(_ ratingcount: Int) {
        print(ratingcount)
        isSelected = ratingcount != 0 ? true : false

            tableview.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableview.dequeueReusableCell(withIdentifier: "BanerTableViewCell", for: indexPath) as! BanerTableViewCell
            return cell
        }else if indexPath.section == 1{
            let cell = tableview.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
            cell.RatingDelegate = self
            return cell
        }else{
            let cell = tableview.dequeueReusableCell(withIdentifier: "RatingTypeTableViewCell", for: indexPath) as! RatingTypeTableViewCell
            cell.ratingDelegate = self
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return isSelected == false ? 200 : 0
        }else if indexPath.section == 1{
            return UITableView.automaticDimension
        }else{
            return isSelected == true ? UITableView.automaticDimension : 0
        }
        
    }
    
    
}
