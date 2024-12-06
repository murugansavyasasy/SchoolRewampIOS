//
//  NoticeBoardVc.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

@available(iOS 14.0, *)
class NoticeBoardVc: UIViewController, SelectNotice {
    
    
    
    
    @IBOutlet weak var HeadingLabel: UILabel!
    
    @IBOutlet weak var plusImgview: UIImageView!
    
    @IBOutlet weak var tableview: UITableView!
    
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    var images : [UIImage] = []
    
    var previousOffset: CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.placeholder = "Search".translated()
        searchbar.delegate = self
        addDoneButton()
        
        HeadingLabel.text = "NoticeBoard".translated()
        HeadingLabel.setFont(style: .header, size: FontSize.HeaderSize)
        tableview.delegate = self
        tableview.dataSource = self
        plusImgview.isHidden = true
        
        let nib = UINib(nibName:"NoticeBoardTvcellTableViewCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "NoticeBoardTvcellTableViewCell")
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(Plusclick))
//        plusImgview.addGestureRecognizer(tap)
        plusImgview.isUserInteractionEnabled = false
        plusImgview.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        ApiCallFunc
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.reloadData()
    }
    
    @IBAction func Plusclick(_ sender : Any){
//        let vc = SenderNoticeBoardVC(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
    
    
    
    @IBAction func BackBtnAct(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

@available(iOS 14.0, *)
extension NoticeBoardVc : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardTvcellTableViewCell", for: indexPath) as! NoticeBoardTvcellTableViewCell
        
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
            // Scrolling Down
            print("Scrolling Down")
//            plusImgview.isHidden = true
        } else if contentOffsetY < previousOffset {
            // Scrolling Up
            print("Scrolling Up")
//            plusImgview.isHidden = false
        }
        
        // Update the previous offset for the next scroll event
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
            let fullString = fullDescription + " See less"
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
                fullString = truncatedDescription + " See more"
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
        
        let vc = SenderNoticeBoardVC(nibName: nil, bundle: nil)
        vc.desc = content
        vc.title1 = title
        vc.items = items
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    //scrol
}



@available(iOS 14.0, *)
extension NoticeBoardVc: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }
    
    func addDoneButton(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
            
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(DoneBtnAct))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)


        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        searchbar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        searchbar.resignFirstResponder()
    }

}


