//
//  FAQViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQViewController: UIViewController {
   

    @IBOutlet weak var submitbutton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    let identifier = "FAQTableViewCell"
    var expandedIndexPaths: Set<IndexPath> = []
    var index : Int? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: identifier, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: identifier)
        
        tableview.dataSource = self
        tableview.delegate = self
       
        tableview.reloadData()
    
    }


    @IBAction func SubmitBtnAction(_ sender: Any) {
        
    }

}


extension FAQViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FAQTableViewCell
        
        cell.textview.isHidden = true
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FAQTableViewCell
        
        cell.textview.isHidden = false
        //cell.stackview.isHidden = false
        
        index = indexPath.row
        tableView.rowHeight = UITableView.automaticDimension
        tableView.beginUpdates()
        tableView.endUpdates()
        
       // tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FAQTableViewCell
        cell.textview.isHidden = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if index == indexPath.row{
            return UITableView.automaticDimension
        }
        
        return 100
//        return expandedIndexPaths.contains(indexPath) ? UITableView.automaticDimension : 100
    }
    
}
