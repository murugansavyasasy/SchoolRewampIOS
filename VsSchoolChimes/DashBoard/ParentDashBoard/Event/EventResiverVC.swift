//
//  EventResiverVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

@available(iOS 14.0, *)
class EventResiverVC: UIViewController, SelectNotice{
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var outerView: UIStackView!
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var createEvent: UIButton!
   
    
    @IBOutlet weak var TitleHederLbl: UILabel!
 
    var titleLbl = "Event"
    var button1 = "Event".translated()
    var button2 = "Holiday".translated()
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchbar.placeholder = CommonStringFile.Search.translated()
        searchbar.delegate = self
        
       
        addDoneButton()
      
        uiConficration()
        tabelViewRegister()
//        pages = [page1, page2]
      
    
        gradientcolours(button: createEvent,colours: [UIColor.parentClr.cgColor,UIColor.priority.cgColor])
        createEvent.setTitleColor(.white, for:.normal)
        gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        historyBtn.setTitleColor(.black, for:.normal)
        // Set the initial page
    
        
        
    }
    
    @IBAction func backbtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.reloadData()
    }
    
    func tabelViewRegister() {
        tableview.delegate = self
        tableview.dataSource = self
        
        
        let nib = UINib(nibName:CellConfingName.NoticeBoardTvcellTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell)
    }
    
    func uiConficration(){
        TitleHederLbl.text = titleLbl
        TitleHederLbl.setFont(style: .header, size: FontSize.HeaderSize)
        outerView.layer.cornerRadius = 20
        historyBtn.layer.cornerRadius = 20
        createEvent.layer.cornerRadius = 20
        createEvent.setTitleFont(style: .body, size: FontSize.BodySize)
        historyBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        historyBtn.setTitle(button2, for: .normal)
        createEvent.setTitle(button1, for: .normal)
    }
   
    func gradientcolours(button : UIButton,colours : [CGColor]){
        
        
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
               
               // Create and configure the gradient layer
               let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
               gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
               gradientLayer.frame = button.bounds
               gradientLayer.cornerRadius = button.layer.cornerRadius
               
               // Insert the gradient layer into the button's layer
               button.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func SelectionController(_ sender: UIButton) {
        
        if sender.tag == 0{
            gradientcolours(button: createEvent,colours: [UIColor.parentClr.cgColor,UIColor.priority.cgColor])
            createEvent.setTitleColor(.white, for:.normal)
            gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            historyBtn.setTitleColor(.black, for:.normal)
        }else{
            gradientcolours(button: createEvent,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            createEvent.setTitleColor(.black, for:.normal)
            gradientcolours(button: historyBtn,colours:[UIColor.parentClr.cgColor,UIColor.priority.cgColor])
            historyBtn.setTitleColor(.white, for:.normal)
        }
        
       
    }
    
    
 
}
@available(iOS 14.0, *)
extension EventResiverVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
//        cell.contentView.backgroundColor = .backGroundClr
        cell.SelectBtn.isHidden = true
        cell.Pinview.isHidden = true
        cell.pinImage.isHidden = true
        cell.dicriptContent.attributedText = descript(for: "Annual Day is a special occasion celebrated by schools, colleges, and organizations to mark the completion of another successful year. It is a time for showcasing the talents and achievements of students or members through cultural performances.", expanded: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
        cell.delegate = self
        cell.dicriptContent.tag = indexPath.row // Tag the label with the row index
        cell.dicriptContent.isUserInteractionEnabled = true
        cell.dicriptContent.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        
        // Check for scroll direction
        if contentOffsetY > previousOffset && contentOffsetY > 0 {
        }
        previousOffset = contentOffsetY
    }
    
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = "Annual Day is a special occasion celebrated by schools, colleges, and organizations to mark the completion of another successful year. It is a time for showcasing the talents and achievements of students or members through cultural performances."
        
        // Toggle the label between expanded and collapsed states
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        
        // Update the label text with the appropriate "See more" or "See less" state
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        
        // Animate the cell height change
        tableview.beginUpdates()
        tableview.endUpdates()
    }
    
    //MARK: TEXT ADD SEE MORE
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        // If expanded, show full text with "See less"
        if expanded {
            let fullString = fullDescription + CommonStringFile.seeLess.translated()
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See less" text to blue and underline it
            let seeLessRange = (fullString as NSString).range(of: "See less")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeLessRange)
            
            return attributedText
        } else {
            var fullString = ""
            // Otherwise, truncate and show "See more"
            if fullDescription.count > 120{
                let truncatedDescription = String(fullDescription.prefix(100))
                fullString = truncatedDescription + CommonStringFile.seemore.translated()
            }else{
                fullString = fullDescription
            }
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See more" text to blue and underline it
            let seeMoreRange = (fullString as NSString).range(of: "See more")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeMoreRange)
            return attributedText
        }
    }
    
    func didTapButton(title: String, content: String, items: [String]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
        
    }
    //scrol
}



@available(iOS 14.0, *)
extension EventResiverVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }
    
    func addDoneButton(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: AlertstringFile.Done, style: .done, target: self, action: #selector(DoneBtnAct))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        searchbar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        searchbar.resignFirstResponder()
    }
    
}
