//
//  CertificateRequestViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/19/24.
//

import UIKit
import DropDown

class CertificateRequestViewController: UIViewController,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var requestCertificateView: UIView!
    @IBOutlet weak var reqCertView: UIView!
    
    @IBOutlet weak var statusShowLbl: UILabel!
    @IBOutlet weak var statusShowView: UIView!
    @IBOutlet weak var selectCertificateLbl: UILabel!
    @IBOutlet weak var selecLevelView: UIViewX!
    @IBOutlet weak var selectCertificateView: UIViewX!
    @IBOutlet weak var urgencyLevelLbl: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var requestSelectView: UIView!
    @IBOutlet weak var tvInsideView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var certificatesBtn: UIButton!
    @IBOutlet weak var requestBtn: UIButton!
    
    var urgentItems = ["Urgent", "Not Urgent"]
    var statusItems = ["Complete","Under Review", "Reject"]
    var certificateListItems = ["Conduct Certificate","Study Certificate","Bonafide Certificate","Transfer Certificate","Attendace Certificate","Promotion Certificate","Fee Certificate","Practical Certificate"]
    
    var dropDown  = DropDown()
    
    var filteredTimetable: [certificateItem] = []


     var timetable : [certificateItem] = [
        certificateItem.init(subName: "Conduct Certificate", subDuration: "12-10-2024", techer: "Viji",status: "Complete"),
        certificateItem.init(subName: "Study Certificate", subDuration: "19-11-2024", techer: "Banumathi",status: "Under Review"),
        certificateItem.init(subName: "Bonafide Certificate", subDuration: "30-12-2024", techer: "Priya",status: "Reject"),
        certificateItem.init(subName: "Transfer Certificate", subDuration: "31-10-2024", techer: "Keerthana",status: "Complete"),
        certificateItem.init(subName: "Promotion Certificate", subDuration: "26-12-2024", techer: "Seetha",status: "Reject"),
        certificateItem.init(subName: "Attendace Certificate", subDuration: "20-10-2024", techer: "Padma",status: "Complete"),
        certificateItem.init(subName: "Fee Certificate", subDuration: "15-111-2024", techer: "Thangam",status: "Reject"),
        certificateItem.init(subName: "Practical Certificate", subDuration: "12-11-2024", techer: "Suchithra",status: "Under Review")
        ]
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        

        filteredTimetable = timetable
        requestBtn.layer.cornerRadius = 20
        reqCertView.layer.cornerRadius = 20
        certificatesBtn.layer.cornerRadius = 20
        gradientcolours(button: requestBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        certificatesBtn.setTitleColor(.black, for:.normal)
        tvInsideView.isHidden = true
        reasonTextView.delegate = self
        tv.dataSource = self
        tv.delegate = self
        tv.register(UINib(nibName: CellConfingName.CertificateTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.CertificateTableViewCell)
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        viewBack.addGestureRecognizer(backGesture)
        let certificateGesture = UITapGestureRecognizer(target: self, action: #selector(selectCertificateClick))
        selectCertificateView.addGestureRecognizer(certificateGesture)
        let levelGesture = UITapGestureRecognizer(target: self, action: #selector(selectLevelClick))
        selecLevelView.addGestureRecognizer(levelGesture)
        let statusGesture = UITapGestureRecognizer(target: self, action: #selector(selectStatusClick))
        statusShowView.addGestureRecognizer(statusGesture)
      
        reasonTextView.isScrollEnabled = false
        reasonTextView.textContainer.lineBreakMode = .byWordWrapping
           }
           
           func textViewDidChange(_ textView: UITextView) {
               // Update the height of the text view dynamically
               let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
               textView.constraints.forEach { constraint in
                   if constraint.firstAttribute == .height {
                       constraint.constant = size.height
                   }
               }
           }
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }
    
    @IBAction func requestBtnAct(_ sender: Any) {
        

        requestSelectView.isHidden = false
        tvInsideView.isHidden = true
        certificatesBtn.setTitleColor(.white, for:.normal)

        gradientcolours(button: certificatesBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])

        gradientcolours(button: requestBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        requestBtn.setTitleColor(.black, for:.normal)

    }
    

    @IBAction func certificatesBtnAct(_ sender: UIButton) {
    
        gradientcolours(button: requestBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        requestSelectView.isHidden = true
        tvInsideView.isHidden = false

    requestBtn.setTitleColor(.white, for:.normal)

    certificatesBtn.backgroundColor = .clear


        gradientcolours(button: certificatesBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])

    certificatesBtn.setTitleColor(.black, for:.normal)

    
}

func gradientcolours(button : UIButton,colours : [CGColor]){
    
    button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = colours
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
    gradientLayer.frame = button.bounds
    gradientLayer.cornerRadius = button.layer.cornerRadius
    button.layer.insertSublayer(gradientLayer, at: 0)
    
    }
    
    @IBAction func selectCertificateClick(){
        
        let myArray = certificateListItems
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = selectCertificateView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            
            selectCertificateLbl.text = item
            
            
            
        }
        
    }
    @IBAction func selectLevelClick(){
        
        let myArray = urgentItems
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView =  selecLevelView//5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            
            urgencyLevelLbl.text = item
            
            
            
        }
        
    }
    
    @IBAction func selectStatusClick(){
        
        filteredTimetable = timetable
        let myArray = statusItems
        
        dropDown.dataSource = myArray
        dropDown.anchorView =  statusShowView
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                   guard let self = self else { return }
                   self.filterTimetable(by: item)
            statusShowLbl.text = item
               }
           }
    
    
    @objc func labelTapped() {
        if let url = URL(string: "https://www.apple.com/in/shop/buy-mac") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

           @IBAction func showDropDown(_ sender: UIButton) {
               dropDown.show()
           }

           func filterTimetable(by status: String) {
               let filteredTimetable1 = timetable.filter { $0.status == status }
//               print("Filtered Items: \(filteredTimetable)")
              
               filteredTimetable = filteredTimetable1
               tv.dataSource =  self
               print("filteredTimetable: \(filteredTimetable)")
               tv.delegate = self
               tv.reloadData()
           }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if reasonTextView.text == TexviewStringFile.certificateReason{
            reasonTextView.text = ""
            reasonTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if reasonTextView.text.isEmpty{
            reasonTextView.text = TexviewStringFile.certificateReason
            reasonTextView.textColor = .lightGray
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredTimetable.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.CertificateTableViewCell, for: indexPath)as! CertificateTableViewCell
        
        cell.dateLbl.text = filteredTimetable[indexPath.row].subDuration
        cell.cetificateNameLbl.text = filteredTimetable[indexPath.row].subName
        cell.resonLbl.text = filteredTimetable[indexPath.row].techer
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        cell.linkUrlLbl.isUserInteractionEnabled = true
        cell.linkUrlLbl.text = "https://www.apple.com/in/shop/buy-mac"
        cell.linkUrlLbl.addGestureRecognizer(tapGes)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    }

struct certificateItem {
    let subName: String!
    var subDuration: String!
    var techer: String!
    var status: String!
}
