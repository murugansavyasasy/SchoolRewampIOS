//
//  AssignmentViewTotalViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/29/24.
//

import UIKit

class AssignmentViewTotalViewController: UIViewController,UISearchBarDelegate {
   

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tv: UITableView!
    
  let rowID =  "AssignmentViewTotalTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tv.delegate = self
        tv.dataSource = self
        
        tv.register(UINib(nibName: rowID, bundle: nil), forCellReuseIdentifier: rowID)
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGesture)
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }
    
    
//    MARK: Search Action

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
//        let filtered_list : [ViewAllSkillByData] = Mapper<ViewAllSkillByData>().mapArray(JSONString: clone_list.toJSONString()!)!
//        
//        if !searchText.isEmpty{
//            viewSkillDatas = filtered_list.filter { $0.Description.lowercased().contains(searchText.lowercased()) ||
//                $0.Title.lowercased().contains(searchText.lowercased()) ||
//                $0.subject.lowercased().contains(searchText.lowercased()) ||
//                $0.SubmittedOn.lowercased().contains(searchText.lowercased())
//            }
//            
//            
//        }else{
//          
//          
//            viewSkillDatas = filtered_list
//            print("pendingOrder")
//        }
//        
//        if viewSkillDatas.count > 0{
//            
//            nodataView.isHidden = true
//            nodataLbl.isHidden = true
//          
//            print ("seCount",viewSkillDatas.count)
//        }else{
//            
//            nodataView.isHidden = false
//            nodataLbl.isHidden = false
//            nodataLbl.text = "No Data Found"
//            print ("searchListPendigCount",viewSkillDatas.count)
//            
//           
//        }
        
        tv.reloadData()
        //        }
    }
    
    
   

}


extension AssignmentViewTotalViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowID, for: indexPath)as!
        AssignmentViewTotalTableViewCell
        cell.selectionStyle = .none
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
