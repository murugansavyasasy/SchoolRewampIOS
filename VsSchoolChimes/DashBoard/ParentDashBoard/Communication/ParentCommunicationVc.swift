//
//  ParentCommunicationVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

class ParentCommunicationVc: UIViewController, reloadDelegate {
    func reload(index: Int,playToggle:Bool) {
        // Stop playback in the currently playing cell (if any)
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = tv.cellForRow(at: previousIndexPath) as? HistoryTC {
                previousCell.updatePlayState(isPlaying: false, url: previousCell.AudioPlayUrl)
            }
        }
        
        // Update the currently playing index and reload the table view
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons()

        StyleAndTranslate()
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        backBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        backBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        backBtn.imageView?.applyRTLFlip(Language == "ar")
        ButtonStyle()
        // Do any additional setup after loading the view.
      
        RegisterCell()
       
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }

    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
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
        
        tv.reloadData()
        
    }
    
    
    
    @IBAction func TextMessageBtn(_ sender: Any) {
        
        BtnId = 0
        textButtonStyle()
        
        tv.reloadData()
        
    }
    
}

//MARK: Tableview Functions
extension ParentCommunicationVc : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if BtnId == 0{
            return 5
        }else{
            
            return 5
        }
       
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
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
            cell.descriptContent.tag = indexPath.row // Tag the label with the row index
            cell.descriptContent.isUserInteractionEnabled = true
            cell.descriptContent.addGestureRecognizer(tapGesture)
            
            return cell
        }else{
            
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
            cell.sentBtnHeight.constant = 0
            cell.sendbtn.isHidden = true
            cell.sentBtnWidth.constant = 0
            cell.playBtn.tag = indexPath.row
            cell.datelbl.textAlignment = .right
            let image = playIndex == indexPath.row ? ImageName.pausebutton: ImageName.playbutton
            // Update play state
            let isPlaying = (playIndex == indexPath.row)
            //        var urls = URL(string: AudioPlayUrl)
            cell.updatePlayState(isPlaying: isPlaying, url: "http://vs5.voicesnapforschools.com/nodejs/voice/VS_1718181818812.wav")
            cell.delegate = self
            cell.playBtn.setImage(image, for: .normal)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK: EXPANDABLE LABLE
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = "Single Section TableView: If your table view has only one section, you don’t need to implement this method because the default number of sections is 1."
        
        // Toggle the label between expanded and collapsed states
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        
        // Update the label text with the appropriate "See more" or "See less" state
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        
        // Animate the cell height change
        tv.beginUpdates()
        tv.endUpdates()
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
    
    
}
