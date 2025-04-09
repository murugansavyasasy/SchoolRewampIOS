//
//  ParentCommunicationVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

class ParentCommunicationVc: UIViewController, reloadDelegate {
    func reload(index: Int) {
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            (tv.cellForRow(at: previousIndexPath) as? HistoryTC)?.updatePlayState(isPlaying: false, url: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Sample-OGG-File.ogg")
        }
        playIndex = (playIndex == index) ? nil : index
        tv.reloadData()
    }
    func deleteDelegate(index: Int) {
        ""
    }
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var clickTextView: UILabel!
    @IBOutlet weak var clickVoiceLbl: UILabel!
    @IBOutlet weak var textBtn: UIButton!
    @IBOutlet weak var voiceClickView: UIView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textClickView: UIView!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    var BtnId = 1
    let backgroundcolor = Colornames.topBackgroundCLr
    let tapColor = Colornames.topBackgroundCLr1
    var playIndex :Int?
    var AudioPlayUrl: String?
    var passValue = 0
    var count = 5
    var shouldShowFooter = true

    override func viewDidLoad() {
        super.viewDidLoad()
        buttons()

        StyleAndTranslate()
        
        if passValue == 1{
            NameLbl.text = ""
            StandardLbl.text = ""
        }
        
        
        backBtn.applyBackButton()
        ButtonStyle()
        // Do any additional setup after loading the view.
      
        RegisterCell()
        
        setupTableFooter()
       
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
        
        
    }

    override func viewDidLayoutSubviews() {
        
        if passValue == 1{
            view.backgroundColor = .topBackgroundCLr
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
           
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }
    }
    
    //MARK: StyleAndTranslate
    func StyleAndTranslate(){
        
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        
        
        clickTextView.text = CommonStringFile.TextMessage.translated()
        backBtn.setTitle(MenuStringFile.Communication.translated(), for: .normal)
        clickVoiceLbl.text = CommonStringFile.VoiceMessage.translated()
    }
    
    //MARK: Cell registration
    func RegisterCell(){
        let nib = UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
        
        let nib2 = UINib(nibName: CellConfingName.HistoryTC, bundle: nil)
        tv.register(nib2, forCellReuseIdentifier: CellConfingName.HistoryTC)
        
        let footerNib = UINib(nibName:CellConfingName.SeeMoreFooterView , bundle: nil)
        tv.register(footerNib, forHeaderFooterViewReuseIdentifier: CellConfingName.SeeMoreFooterView)
    }
    
    func ButtonStyle(){
        textClickView.backgroundColor = .white
        textBtn.backgroundColor = UIColor.white
        clickVoiceLbl.textColor = .black
        clickTextView.textColor = .black
        textBtn.tintColor = .black
        //voiceBtn.backgroundColor = .white
        voiceClickView.layer.cornerRadius = 8
        voiceClickView.layer.cornerRadius = 8
        //voiceClickView.backgroundColor = tapColor
        voiceBtn.layer.cornerRadius = 20
        voiceBtn.layer.shadowColor = UIColor.black.cgColor
        voiceBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        voiceBtn.layer.shadowRadius = 5
        voiceBtn.layer.shadowOpacity = 0.3
        gradientcolours(view: voiceClickView,colours:[
            UIColor(hex: "7ED957").withAlphaComponent(0.5).cgColor,
            UIColor(hex: "0097B2").withAlphaComponent(0.5).cgColor
        ])
        
        gradientcolours(view: textClickView,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
    }
    
    func buttons(){
        //MARK: TEXT BUTTON BACKGROUND
        textBtn.layer.cornerRadius = 20
        textBtn.layer.shadowColor = UIColor.black.cgColor
        textBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        textBtn.layer.shadowRadius = 5
        textBtn.layer.shadowOpacity = 0.3
        textClickView.layer.cornerRadius = 8
        textClickView.backgroundColor = backgroundcolor
        voiceClickView.backgroundColor = .white
        textBtn.backgroundColor = UIColor.white
        clickVoiceLbl.textColor = .black
       
        clickTextView.textColor = .black
//        voiceBtn.tintColor = tapColor
        textBtn.tintColor = .black
        
    }
    
    func textButtonStyle(){
        textClickView.backgroundColor = backgroundcolor
        voiceClickView.backgroundColor = .white
        textBtn.backgroundColor = UIColor.white
        clickVoiceLbl.textColor = .black
       
        clickTextView.textColor = .black
//        voiceBtn.tintColor = tapColor
        textBtn.tintColor = .black
        
        //MARK: TEXT BUTTON BACKGROUND
        textBtn.layer.cornerRadius = 20
        textBtn.layer.shadowColor = UIColor.black.cgColor
        textBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        textBtn.layer.shadowRadius = 5
        textBtn.layer.shadowOpacity = 0.3
        textClickView.layer.cornerRadius = 8
        gradientcolours(view: textClickView,colours: [
            UIColor(hex: "7ED957").withAlphaComponent(0.5).cgColor,
            UIColor(hex: "0097B2").withAlphaComponent(0.5).cgColor
        ])
        gradientcolours(view: voiceClickView,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
    }
    
    func gradientcolours(view: UIView, colours: [CGColor]) {
        // Remove any existing gradient layers to avoid duplication
        view.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = view.layer.cornerRadius
        
        // Insert the gradient layer into the view's layer
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    @IBAction func voiceMessgBtn(_ sender: Any) {
        BtnId = 1
        ButtonStyle()
        shouldShowFooter = true
        setupTableFooter()
        tv.reloadData()
        
    }
    
    @IBAction func TextMessageBtn(_ sender: Any) {
        
        BtnId = 0
        textButtonStyle()
        shouldShowFooter = true
        setupTableFooter()
        tv.reloadData()
    }
}

//MARK: Tableview Functions
extension ParentCommunicationVc : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if BtnId == 0{
//            count =  2//5
//        }else{
//            
//            count =  2//5
//        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if BtnId == 0{
            
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
            cell.sendBtnheight.constant = 0
            cell.sendBtnWidth.constant = 0
            cell.DateLabel.textAlignment = .right
            cell.sendBtn.isHidden = true
            cell.descriptContent.attributedText = descript(for:"Single Section TableView: If your table view has only one section, you don’t need to implement this method because the default number of sections is 1.", expanded: false)
//            cell.delegate = self
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
            cell.descriptContent.tag = indexPath.row // Tag the label with the row index
            cell.descriptContent.isUserInteractionEnabled = true
            cell.descriptContent.addGestureRecognizer(tapGesture)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                
                cell.configureShimmer()
            }
            return cell
        }else{
            
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
            cell.sentBtnHeight.constant = 0
            cell.sendbtn.isHidden = true
            cell.sentBtnWidth.constant = 0
            cell.playBtn.tag = indexPath.row
            cell.datelbl.textAlignment = .right
            let image = playIndex == indexPath.row ? ImageName.pausebutton: ImageName.playbutton
            cell.updatePlayState(isPlaying: playIndex == indexPath.row, url: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Sample-OGG-File.ogg")
            cell.delegate = self
            cell.playBtn.setImage(image, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now()+2.5){
                
                cell.configureShimmer()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Tap Gesture for "See More" / "See Less"
    @objc func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel, let text = label.text else { return }
        
        let seeMoreRange = (text as NSString).range(of: CommonStringFile.seemore.translated())
        let seeLessRange = (text as NSString).range(of: CommonStringFile.seeLess.translated())
        
        if gesture.didTapAttributedTextInLabel(label: label, inRange: seeMoreRange) ||
            gesture.didTapAttributedTextInLabel(label: label, inRange: seeLessRange) {
            handleSeeMoreTap(gesture)
        }
    }
    
    //MARK: EXPANDABLE LABLE
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = "Single Section TableView: If your table view has only one section, you don’t need to implement this method because the default number of sections is 1."
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        tv.beginUpdates()
        tv.endUpdates()
    }
    
    //MARK: TEXT ADD SEE MORE
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        // If expanded, show full text with "See less"
        if expanded {
            let fullString = fullDescription + CommonStringFile.seeLess.translated()
            let attributedText = NSMutableAttributedString(string: fullString)
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
    
    // Method to load the footer from nib and set it as tableFooterView
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                // Adjust the frame based on your needs.
                footer.frame = CGRect(x: 0, y: 0, width: tv.frame.width, height: 60)
                
                // Add a tap gesture recognizer to the button to trigger the hide action.
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                
                // Set the footer view.
                tv.tableFooterView = footer
            }
        } else {
            tv.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        print("Footer button tapped. Hiding the footer.")
        
        // Animate the footer fade-out if desired.
        if let footer = tv.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                // Hide the footer after animation completes.
                tv.tableFooterView = nil
                shouldShowFooter = false
                
                count += 2
                tv.reloadData()
            })
        } else {
            // In case footer is already nil.
            shouldShowFooter = false
        }
    }
}
