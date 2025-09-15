//
//  FAQViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQViewController: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var outerView: UIView!
    
    var expandedIndexPaths: Set<IndexPath> = []
    var index : Int? = nil
    var passValue = 1
    var selectedIndexPath: IndexPath?
    
    let qaList: [SchoolQA] = [
        SchoolQA(question: "Does the school have a library?", answer: "Yes, the school has a well-stocked library with various books and study materials."),
        SchoolQA(question: "Are there sports facilities available?", answer: "Yes, the school has a gymnasium, a football field, and a basketball court."),
        SchoolQA(question: "Does the school provide cafeteria services?", answer: "Yes, the cafeteria offers a variety of healthy meal options for students."),
        SchoolQA(question: "Are there computer labs in the school?", answer: "Yes, the school has multiple computer labs with internet access for students."),
        SchoolQA(question: "Does the school have medical facilities?", answer: "Yes, there is a health center with a nurse available during school hours.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        BackBtn.setTitle(MenuTapbar.shared.FAQ, for: .normal)
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
       
        let nib = UINib(nibName: CellConfingName.FAQTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.FAQTableViewCell)
        
        tableview.dataSource = self
        tableview.delegate = self
        
        tableview.reloadData()
        
    }
    override func viewDidLayoutSubviews() {
        if passValue == 1{
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }
    }
    
    @IBAction func SubmitBtnAction(_ sender: Any) {
        
    }
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

extension FAQViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.FAQTableViewCell, for: indexPath) as! FAQTableViewCell
        cell.QuestionLabel.text = qaList[indexPath.row].question
        cell.AnswerLbl.text = qaList[indexPath.row].answer
       // cell.AnswerLbl.isHidden = true
        cell.toggleLabelVisibility(isSelected: selectedIndexPath == indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Toggle selection state
            if selectedIndexPath == indexPath {
                selectedIndexPath = nil  // Deselect if already selected
            } else {
                selectedIndexPath = indexPath
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    
    
    /* func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FAQTableViewCell
        
        cell.AnswerLbl.isHidden = false
        cell.QuestionLabel.isHidden = false
        tableview.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FAQTableViewCell
        cell.AnswerLbl.isHidden = true
        cell.QuestionLabel.isHidden = false
        tableview.reloadData()
        
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


struct SchoolQA {
    var question: String
    var answer: String
}


