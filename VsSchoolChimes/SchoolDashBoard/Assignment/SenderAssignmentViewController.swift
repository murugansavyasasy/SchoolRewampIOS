//
//  SenderAssignmentViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/18/24.
//

import UIKit

@available(iOS 14.0, *)
class SenderAssignmentViewController: UIViewController {
    
    @IBOutlet weak var plusView: UIViewX!
    @IBOutlet weak var assignmentCreateView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var textBtn: UIButton!
    @IBOutlet weak var pdfBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var viewLBl: UILabel!
    @IBOutlet weak var ViewSeg: UIView!
    @IBOutlet weak var headingLBl: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var assTitlLbl: UILabel!
    
    var rowID = "AssignmentViewTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGesture)
        
    
        let createGesture = UITapGestureRecognizer(target: self, action: #selector(createSelecteAct))
        plusView.addGestureRecognizer(createGesture)
        
//        let listShowGesture = UITapGestureRecognizer(target: self, action: #selector(viewSelecteAct))
//        ViewSeg.addGestureRecognizer(listShowGesture)
        tv.isHidden = true
        assTitlLbl.text = "Assignment".translated()
//        viewLBl.text = "VIEW".translated()
        headingLBl.text = "Select the type in which you want to create the assignment".translated()
//        createLbl.text = "CREATE".translated()
        
        listView.isHidden = false
        tv.isHidden = false
       
//        ViewSeg.backgroundColor = UIColor(named: "ButtonColor")
//        createView.backgroundColor = .lightGray
        assignmentCreateView.isHidden = true
        
        tv.dataSource = self
        tv.delegate = self
        tv.register(UINib(nibName: rowID, bundle: nil), forCellReuseIdentifier: rowID)
        
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        assignmentCreateView.isHidden = true
    }
    @IBAction func viewSelecteAct() {
        print("ViewSelect")
        listView.isHidden = false
        tv.isHidden = false
       
        ViewSeg.backgroundColor = Colornames.ButtonColor
        createView.backgroundColor = .lightGray
        assignmentCreateView.isHidden = true
    }
    
    @IBAction func createSelecteAct() {
//        createView.backgroundColor = UIColor(named: "ButtonColor")
//        listView.isHidden = true
//        ViewSeg.backgroundColor = .lightGray
        assignmentCreateView.isHidden = false
//        tv.isHidden = true
    }
    
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }

    @IBAction func textBtnAction(_ sender: UIButton) {
        let vc = SenderAssignmentTextViewController(nibName: nil, bundle: nil)
        vc.selectedShow = "Text"
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    

    @IBAction func imageBtnAction(_ sender: UIButton) {
        let vc = SenderAssignmentTextViewController(nibName: nil, bundle: nil)
        vc.selectedShow = "Image"
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func pdfBtnAction(_ sender: UIButton) {
        let vc = SenderAssignmentTextViewController(nibName: nil, bundle: nil)
        vc.selectedShow = "Pdf"
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
}


@available(iOS 14.0, *)
extension SenderAssignmentViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowID, for: indexPath) as! AssignmentViewTableViewCell
        
        let totalGesture = UITapGestureRecognizer(target: self, action: #selector(totalVc))
        cell.totalView.addGestureRecognizer(totalGesture)
        
        
        cell.deleteLbl.text = "Delete".translated()
        cell.forwardLbl.text = "Forward".translated()
        cell.submissionLbl.text = "Submission".translated()
        
        cell.totalLbl.text = "Total".translated()
        cell.viewLbl.text = "View".translated()
      
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @IBAction func totalVc() {
        let vc = AssignmentViewTotalViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
