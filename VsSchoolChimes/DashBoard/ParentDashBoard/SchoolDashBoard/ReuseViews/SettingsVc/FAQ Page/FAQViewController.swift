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
    
  var raj = ""
    var expandedIndexPaths: Set<IndexPath> = []
    var index : Int? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: CellConfingName.FAQTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.FAQTableViewCell)
        
        tableview.dataSource = self
        tableview.delegate = self
       
        tableview.reloadData()
    
    }


    @IBAction func SubmitBtnAction(_ sender: Any) {
        
    }
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}


extension FAQViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.FAQTableViewCell, for: indexPath) as! FAQTableViewCell
        
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

    }
    
}
