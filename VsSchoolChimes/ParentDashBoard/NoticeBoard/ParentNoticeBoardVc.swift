//
//  ParentNoticeBoardVc.swift
//  VsSchoolChimes
//
//  Created by admin on 20/12/24.
//

import UIKit

@available(iOS 14.0, *)
class ParentNoticeBoardVc: UIViewController, SelectNotice {
    
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var HeadingLabel: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var bgView: UIView!
    var images : [UIImage] = []
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    var shouldShowFooter = true
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    var NoticeboardData: [Notice]?
    var SearchData: [Notice]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backBtn.applyBackButton()
        searchbar.applyRightTxt()
        StyleAndTranslate()
        searchbar.delegate = self
        searchbar.addDoneButton()
        CellRegister()
        Get_Notice()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        
    }
    
    //MARK: UI Changes
    func StyleAndTranslate(){
        
        HeadingLabel.setFont(style: .header, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        searchbar.placeholder = CommonStringFile.Search.translated()
        backBtn.setTitle(MenuStringFile.NoticeBoard.translated(), for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
    }
    
    func CellRegister() {
        let nib = UINib(nibName:CellConfingName.NoticeBoardTvcellTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell)
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    //MARK: API Call
    
    func Get_Notice() {
        
        APIService.shared.makeApi(url: ServiceUrl.api_notice_board_get_notice, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[self] (result: Result<NoticeResponse,Error>) in
            
            switch result {
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        NoticeboardData = SuccessMessage.data
                        SearchData = NoticeboardData
                        tableview.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        NoticeboardData = SuccessMessage.data
                        SearchData = NoticeboardData
                        tableview.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

//MARK: Tableview Functions
@available(iOS 14.0, *)
extension ParentNoticeBoardVc : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
        
        cell.SelectBtn.isHidden = true
       
        //cell.dicriptContent.attributedText = descript(for: SearchData?.description ?? "", expanded: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
       
        cell.dicriptContent.text = SearchData?[indexPath.row].content
        cell.TitleLbl.text = SearchData?[indexPath.row].title
        cell.datelbl.text = SearchData?[indexPath.row].created_on
        
        if let urls = SearchData?[indexPath.row].file_path, urls.count != 0{
            cell.collectionview.isHidden = false
            cell.CollectionViewHeight.constant = 120
            cell.loadImage(urls: urls)
        }else {
            cell.CollectionViewHeight.constant = 0
            cell.collectionview.isHidden = true
            cell.pagecontroller.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = label.text ?? ""
        
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
    
    func didTapButton(title: String, content: String, items: [FilePath]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
        
    }
}


//MARK: Searchbar Delegate
@available(iOS 14.0, *)
extension ParentNoticeBoardVc: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            SearchData = NoticeboardData
        } else {
            SearchData = NoticeboardData?.filter { notice in
                (notice.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (notice.content?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (notice.created_on?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }

        tableview.reloadData()
    }

}
