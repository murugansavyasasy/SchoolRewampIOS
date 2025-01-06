//
//  ReciverHomeworkVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 20/12/24.
//

import UIKit

@available(iOS 14.0, *)
class ReciverHomeworkVC: UIViewController, SelectNotice {
    func didTapButton(title: String, content: String, items: [String]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var HeaderLbl: UILabel!
    var expandedSections: Set<Int> = [] // Tracks expanded sections
    let sections = ["11 Dec 2024","12 Dec 2024","13 Dec 2024","14 Dec 2024"]
    var delegate : HistorySelectDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        backBtn.setTitle(MenuStringFile.Homework.translated(), for: .normal)
        let nib = UINib(nibName: CellConfingName.NoticeBoardTvcellTableViewCell, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell)
        
        let nib1 = UINib(nibName: CellConfingName.HomeworkreportTV, bundle: nil)
        TV.register(nib1, forCellReuseIdentifier: CellConfingName.HomeworkreportTV)
        
        let head = UINib(nibName: CellConfingName.ReciverHomeworkHeader, bundle: nil)
        TV.register(head, forHeaderFooterViewReuseIdentifier: CellConfingName.ReciverHomeworkHeader)
        
        TV.delegate = self
        TV.dataSource = self
    }


    
    @IBAction func BackBtnAct(_ sender: Any) {
        dismiss(animated: true)
    }
}


@available(iOS 14.0, *)
extension ReciverHomeworkVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.ReciverHomeworkHeader) as! ReciverHomeworkHeader
        cell.HeaderLbl.text = sections[section]
        cell.HeaderLbl.setFont(style: .header, size: FontSize.HeaderSize)
        cell.HeaderView.layer.cornerRadius = 10
        cell.HeaderView.layer.borderWidth = 1
        cell.HeaderView.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.HeaderView.layer.shadowColor = UIColor.black.cgColor
        cell.HeaderView.layer.shadowOpacity = 0.2 // Adjust the opacity of the shadow
        cell.HeaderView.layer.shadowOffset = CGSize(width: 0, height: 5) // Position of the shadow
        cell.HeaderView.layer.shadowRadius = 5 // Blur effect of the shadow
        
        // Add tap gesture to header
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
        cell.tag = section
        cell.addGestureRecognizer(tapGesture)
        
        
        if expandedSections.contains(section){
            cell.ArrowImgview.image = UIImage(named: "arrow_up")
            
        }else{
            cell.ArrowImgview.image = UIImage(named: "arrow_down")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return rows only for expanded sections
        return expandedSections.contains(section) ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
            
            cell.cellview.changeHeightAndAnimate(40, 110, 31, 80, top: 5)
            cell.ishomework = true
            cell.CVHeight.constant = 120
            cell.pagecontrollerheight.constant = 26
            cell.pagecontroller.isHidden = false
            cell.SelectBtn.isHidden = true
            cell.HomeworkTitleLbl.text = "Write Assignment"
            cell.TitleLbl.text = "Tamil"
            cell.dicriptContent.attributedText = descript(for: "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality.", expanded: false)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
            cell.delegate = self
            cell.dicriptContent.tag = indexPath.row
            cell.dicriptContent.isUserInteractionEnabled = true
            cell.dicriptContent.addGestureRecognizer(tapGesture)
            
            return cell
        } else if indexPath.row == 1 {
            let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.HomeworkreportTV, for: indexPath) as! HomeworkreportTV
            
            cell.HomeworkTitleLbl.text = "Write Assignment"
            cell.DescriptionLbl.text = "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality."
            cell.SubjectLbl.text = "Tamil"
            return cell
        } else {
            let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
            
            cell.cellview.changeHeightAndAnimate(40, 0, 31, 80, top: 5)
            cell.ishomework = true
            cell.pagecontrollerheight.constant = 0
            cell.pagecontroller.isHidden = true
            
            cell.datelbl.isHidden = true
            cell.pinImage.isHidden = true
            cell.Pinview.isHidden = true
            cell.SelectBtn.isHidden = true
            cell.CVHeight.constant = 0
            cell.HomeworkTitleLbl.text = "Write Assignment"
            cell.TitleLbl.text = "Tamil"
            cell.dicriptContent.attributedText = descript(for: "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality.", expanded: false)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
            cell.delegate = self
            cell.dicriptContent.tag = indexPath.row
            cell.dicriptContent.isUserInteractionEnabled = true
            cell.dicriptContent.addGestureRecognizer(tapGesture)
            
            return cell
        }
    }
    
//    @objc func toggleSection(_ sender: UITapGestureRecognizer) {
//        guard let headerView = sender.view else { return }
//        let section = headerView.tag
//        
//        if expandedSections.contains(section){
//            expandedSections.remove(section)
//            TV.reloadSections(IndexSet(integer: section), with: .automatic)
//        }
//        else if expandedSections.isEmpty == false {
//            expandedSections.removeFirst()
//            TV.reloadSections(IndexSet(integer: 0), with: .automatic)
//        }
//        else{
//            expandedSections.insert(section)
//            TV.reloadSections(IndexSet(integer: section), with: .automatic)
//        }
//    }
    @objc func toggleSection(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view else { return }
        let section = headerView.tag
        
        if expandedSections.contains(section) {
            expandedSections.remove(section)
            TV.reloadSections(IndexSet(integer: section), with: .automatic)
        } else {
        //MARK: if let only works when the expandedSections.first is not nil
            if let previousSection = expandedSections.first {
                expandedSections.remove(previousSection)
                TV.reloadSections(IndexSet(integer: previousSection), with: .automatic)
            }
            
            expandedSections.insert(section)
            TV.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }

    
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let fullDescription = "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality. Begin by thoroughly understanding the topic and conducting comprehensive research using reliable sources. Create a detailed outline to structure your thoughts and arguments logically. Write a clear and concise introduction that sets the tone and context for your assignment."
        
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        
        TV.beginUpdates()
        TV.endUpdates()
    }
    
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        if expanded {
            let fullString = fullDescription + CommonStringFile.seeLess.translated()
            let attributedText = NSMutableAttributedString(string: fullString)
            let seeLessRange = (fullString as NSString).range(of: "See less")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeLessRange)
            return attributedText
        } else {
            let truncatedDescription = String(fullDescription.prefix(100)) + CommonStringFile.seemore.translated()
            let attributedText = NSMutableAttributedString(string: truncatedDescription)
            let seeMoreRange = (truncatedDescription as NSString).range(of: "See more")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeMoreRange)
            return attributedText
        }
    }
}
