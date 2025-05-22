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
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var FilterImageview: UIImageView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var EmptyView: UIView!
    @IBOutlet weak var SearchFilterStack: UIStackView!
    
    var images : [UIImage] = []
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    var shouldShowFooter = true
    var childDetails = UserDefaultFileManager.get_child_Details()
    var NoticeboardData: [Notice]?
    var SearchData: [Notice]?
    var FilteredData: [Notice]?
    var Filters = ["All","Text","Image","Document"]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    
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
        
        let FilterTap = UITapGestureRecognizer(target: self, action: #selector(ToggleFilterCV))
        FilterImageview.addGestureRecognizer(FilterTap)
        FilterImageview.isUserInteractionEnabled = true
        
        FilterCV.delegate = self
        FilterCV.dataSource = self
        
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        
    }
    
    //MARK: UI Changes
    func StyleAndTranslate(){
        
        FilterCV.isHidden = true
        NodataImage.isHidden = true
        NoDataLbl.isHidden = true
        EmptyView.isHidden = true
        
        NameLbl.text = childDetails?.name
        StandardLbl.text = (childDetails?.standard_name ?? "") + "-" + (childDetails?.section_name ?? "")
        
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
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
        
        let cvnib = UINib(nibName:CellConfingName.FiltersCvCell , bundle: nil)
        FilterCV.register(cvnib, forCellWithReuseIdentifier: CellConfingName.FiltersCvCell)
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func ToggleFilterCV(){
        
        FilterCV.isHidden.toggle()
    }
    
    //MARK: API Call
    
    func Get_Notice() {
        
        APIService.shared.makeApi(url: ServiceUrl.api_notice_board_get_notice, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[self] (result: Result<NoticeResponse,Error>) in
            
            switch result {
                
            case .success(let SuccessMessage):
                DispatchQueue.main.async { [self] in
                    
                    NoticeboardData = SuccessMessage.data
                    FilteredData = NoticeboardData
                    SearchData = NoticeboardData
                    NoDataLbl.text = SuccessMessage.status == false ? SuccessMessage.message : "No Data Found"
                    SearchFilterStack.isHidden = SearchData?.isEmpty ?? false
                    NodataImage.isHidden = !(SearchData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(SearchData?.isEmpty ?? false)
                    EmptyView.isHidden = !(SearchData?.isEmpty ?? false)
                    tableview.reloadData()
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async { [self] in
                    SearchFilterStack.isHidden = true
                    NodataImage.isHidden = false
                    NoDataLbl.isHidden = false
                    NoDataLbl.text = error.localizedDescription
                    print("Error: \(error.localizedDescription)")
                }
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
        
        let notice =  SearchData?[indexPath.row]
        
        cell.SelectBtn.isHidden = true
    
        cell.TitleLbl.text =  notice?.title
        cell.dicriptContent.setupExpandable(text: notice?.content ?? "")
        cell.dicriptContent.onExpandableTap =
        {
            [weak tableview] in
            
            cell.dicriptContent.isExpanded.toggle()
            tableview?.beginUpdates()
            tableview?.endUpdates()
        }
        cell.datelbl.text =  notice?.created_on
        
        if let urls =  notice?.file_path, urls.count != 0{
            cell.collectionview.isHidden = false
            cell.CollectionViewHeight.constant = 130
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

@available(iOS 14.0, *)
extension ParentNoticeBoardVc: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = FilterCV.dequeueReusableCell(withReuseIdentifier: CellConfingName.FiltersCvCell, for: indexPath) as! FiltersCvCell
        
        cell.FilterLbl.text = Filters[indexPath.item]
        
        cell.CheckboxImg.image = indexPath == selectedIndex ? UIImage(named: "RadioCheck") : UIImage(named: "CheckCircle")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        
        let type = Filters[selectedIndex.item]
        
        switch type {
            
        case "Image":
            
            FilteredData = NoticeboardData?.filter { NoticeboardData in
                NoticeboardData.file_path?.first?.type == "IMAGE"
            }
        case "Document":
            
            FilteredData = NoticeboardData?.filter { NoticeboardData in
                NoticeboardData.file_path?.first?.type != "IMAGE" && NoticeboardData.file_path?.count != 0
            }
            
        case "Text":
            
            FilteredData = NoticeboardData?.filter { NoticeboardData in
                NoticeboardData.file_path?.count == 0
            }
        default:
            FilteredData = NoticeboardData
        }

        SearchData = FilteredData
        
        NodataImage.isHidden = !(SearchData?.isEmpty ?? false)
        NoDataLbl.isHidden = !(SearchData?.isEmpty ?? false)
        EmptyView.isHidden = !(SearchData?.isEmpty ?? false)
        
        FilterCV.reloadData()
        
        tableview.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = Filters[indexPath.item] // Assuming your label text is from a data source
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16) // Use the same font as in Storyboard
        label.text = text
        label.sizeToFit()

        let width = label.frame.width + 60  // Add padding
        return CGSize(width: width, height: 40) // Adjust height accordingly
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
            SearchData = FilteredData
        } else {
            SearchData = FilteredData?.filter { notice in
                (notice.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (notice.content?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (notice.created_on?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }

        NodataImage.isHidden = !(SearchData?.isEmpty ?? false)
        NoDataLbl.isHidden = !(SearchData?.isEmpty ?? false)
        EmptyView.isHidden = !(SearchData?.isEmpty ?? false)
        tableview.reloadData()
    }

}
