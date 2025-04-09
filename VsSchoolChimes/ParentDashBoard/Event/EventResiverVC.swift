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
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var TitleHederLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
 
    var titleLbl = "Event"
    var button1 = "Event".translated()
    var button2 = "Holiday".translated()
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    let day = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
    var section = 0
    var shouldShowFooter = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.setTitle(button1.translated(), for: .normal)
        backBtn.applyBackButton()
        searchbar.placeholder = CommonStringFile.Search.translated()
        searchbar.applyRightTxt()
        searchbar.delegate = self
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        searchbar.addDoneButton()
        uiConficration()
        tabelViewRegister()
        configureButton(
            createEvent,
            title: button1,
            imageName: nil,
            gradientColors:[UIColor.green,UIColor.blue],
            opacity: 0.8, // 70% opacity
            lightenFactor: 0.6// 40% lighter
        )
        
        createEvent.setTitleColor(.black, for:.normal)
        gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        historyBtn.setTitleColor(.gray, for:.normal)
        // Set the initial page
        setupTableFooter()
        tableview.reloadData()
    }
    
    @IBAction func backbtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        bgView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        
    }
    
    //MARK: Cell Registration
    func tabelViewRegister() {
        tableview.delegate = self
        tableview.dataSource = self
        
        let nib = UINib(nibName:CellConfingName.NoticeBoardTvcellTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell)
        let nib2 = UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
    }
    
    func uiConficration(){
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
        section = sender.tag
        if sender.tag == 0{
            configureButton(
                createEvent,
                title: button1,
                imageName: nil,
                gradientColors:[UIColor.green,UIColor.blue],
                opacity: 0.8, // 70% opacity
                lightenFactor: 0.6// 40% lighter
            )
            createEvent.setTitleColor(.black, for:.normal)
            gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            historyBtn.setTitleColor(.gray, for:.normal)
        }else{
            gradientcolours(button: createEvent,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            createEvent.setTitleColor(.gray, for:.normal)
            configureButton(
                historyBtn,
                title: button2,
                imageName: nil,
                gradientColors:[UIColor.green,UIColor.blue],
                opacity: 0.8, // 70% opacity
                lightenFactor: 0.6// 40% lighter
            )
            historyBtn.setTitleColor(.black, for:.normal)
        }
        
        tableview.reloadData()
    }
    // Helper function to configure the button
    func configureButton(
        _ button: UIButton,
        title: String,
        imageName: UIImage?,
        gradientColors: [UIColor],
        cornerRadius: CGFloat = 20,
        imageSize: CGSize = CGSize(width: 40, height: 40),
        spacing: CGFloat = 8.0,
        opacity: CGFloat = 0.5, // Opacity for the gradient
        lightenFactor: CGFloat = 0.3 // Factor to lighten colors (0 = no change, 1 = full white)
    ) {
        // Set corner radius
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        
        // Adjust colors for lightening and opacity
        let adjustedColors = gradientColors.map { color in
            color.blendedWithWhite(factor: lightenFactor).withAlphaComponent(opacity)
        }
        
        // Apply gradient
        button.applyGradient(
            colors: adjustedColors,
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        button.setTitleFont(style: .body, size: FontSize.BodySize)
        
        // Set title and image
        button.setTitle(title, for: .normal)
        if let image = imageName {
            let resizedImage = UIGraphicsImageRenderer(size: imageSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: imageSize))
            }
            button.setImage(resizedImage, for: .normal)
        }
        
        // Align image and title
        button.contentHorizontalAlignment = .center  // Ensure horizontal alignment
        if let imageSize = button.imageView?.frame.size,
           let titleSize = button.titleLabel?.intrinsicContentSize {
            let totalHeight = imageSize.height + titleSize.height + spacing
            
            button.imageEdgeInsets = UIEdgeInsets(
                top: -(totalHeight - imageSize.height),  // Move image to the top
                left: 0,
                bottom: 0,
                right: -titleSize.width // Center align horizontally
            )
            
            button.titleEdgeInsets = UIEdgeInsets(
                top: 0,  // No padding at the top
                left: -imageSize.width,  // Center align horizontally
                bottom: -(totalHeight - titleSize.height),  // Move title below the image
                right: 0
            )
            
            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: spacing,
                right: 0
            )
        }
    }

    
 
}

//MARK: Tableview Functions
@available(iOS 14.0, *)
extension EventResiverVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
            cell.cellview.changeHeightAndAnimate(40, 110, 31, 80, top: 5)
            cell.ishomework = true
            cell.dicriptContent.attributedText = descript(for: "Annual Day is a special occasion celebrated by schools, colleges, and organizations to mark the completion of another successful year. It is a time for showcasing the talents and achievements of students or members through cultural performances.", expanded: false)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
            cell.delegate = self
            cell.dicriptContent.tag = indexPath.row // Tag the label with the row index
            cell.dicriptContent.isUserInteractionEnabled = true
            cell.dicriptContent.addGestureRecognizer(tapGesture)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ReciverAttendReportTV, for: indexPath) as! ReciverAttendReportTV
            cell.TakenLbl.text = "Tamilar Thirunaal"
            cell.MonthView.backgroundColor =  UIColor(named: "Red")
            cell.DateView.backgroundColor =  .white
            cell.DateView.layer.borderWidth = 0.5
            cell.monthLbl.text = "JAN"
            cell.DateLbl.text = "14"
            cell.StatusView.isHidden = true
            return cell
        }
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
    
    // Method to load the footer from nib and set it as tableFooterView
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                // Adjust the frame based on your needs.
                footer.frame = CGRect(x: 0, y: 0, width: tableview.frame.width, height: 60)
                
                // Add a tap gesture recognizer to the button to trigger the hide action.
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                
                // Set the footer view.
                tableview.tableFooterView = footer
            }
        } else {
            tableview.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        print("Footer button tapped. Hiding the footer.")
        
        // Animate the footer fade-out if desired.
        if let footer = tableview.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                // Hide the footer after animation completes.
                tableview.tableFooterView = nil
                shouldShowFooter = false
                
                tableview.reloadData()
            })
        } else {
            // In case footer is already nil.
            shouldShowFooter = false
        }
    }
    
}


//MARK: Searchbar Delegate
@available(iOS 14.0, *)
extension EventResiverVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }

    
}
