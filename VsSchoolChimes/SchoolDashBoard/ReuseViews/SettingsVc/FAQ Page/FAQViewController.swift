//
//  FAQViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQViewController: UIViewController {
    
    @IBOutlet weak var FaqPageHeading: UILabel!
    
    @IBOutlet weak var submitbutton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var outerView: UIView!
    
    
    var expandedIndexPaths: Set<IndexPath> = []
    var index : Int? = nil
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        if passValue == 1{
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//            outerView.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//            outerView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }
        FaqPageHeading.text = MenuTapbar.FAQ.translated()
        FaqPageHeading.setFont(style: .header, size: 20)
        
        submitbutton.layer.cornerRadius = Colornames.CORadius10
        submitbutton.setTitleFont(style: .body, size: 14)
        
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.FAQTableViewCell, for: indexPath) as! FAQTableViewCell
        cell.textview.isHidden = true
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FAQTableViewCell
        
        cell.textview.isHidden = false
        
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
