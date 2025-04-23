//
//  SettingsViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class SettingsViewController: UIViewController, BaktoHome {
    func backtohome() {
        delegate?.backtohome()
        tableview.reloadData()
    }
    
    @IBOutlet weak var SettingspageHeading: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var topView: UIView!
    var menuname = SettingStringFile()
    lazy var sections: [Section] = [
        Section(
            title: menuname.general,
            items: [
                menuname.notifications,
                menuname.faq,
                menuname.contactUs,
                menuname.termsAndConditions,
                menuname.changeAppLanguage,menuname.faceID
            ]
        ),
        Section(title: menuname.feedback, items: [menuname.reportABug, menuname.feedback, menuname.logout])
    ]
    var section:[Section]?
    let Images: [Image] = [
        Image(title: "GENERAL", Imageitems: ["bell.fill", "person.crop.circle.badge.questionmark.fill", "phone.arrow.up.right.circle.fill", "chart.line.uptrend.xyaxis","character.bubble.ja","faceid"]),
        Image(title: "FEEDBACK", Imageitems: ["questionmark.diamond.fill", "paperplane.fill", "iphone.and.arrow.forward"])
    ]
    
    var imagesArray: [UIImage] = []
    var delegate:BaktoHome?
    var passVale = 1
    var Language:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        section = sections
        SettingspageHeading.text = MenuTapbar.Settings.translated()
        SettingspageHeading.setFont(style: .header, size: 20)
        // Do any additional setup after loading the view.
        
        for imageCategory in Images {
            
            for uiImage in imageCategory.uiImages {
                if let image = uiImage {
                    print("Loaded UIImage: \(image)")
                    imagesArray.append(image)
                } else {
                    print("Failed to load UIImage for one of the symbols.")
                }
            }
        }
        tableview.dataSource = self
        tableview.delegate = self
        view.backgroundColor = Colornames.topBackgroundCLr
        tableview.backgroundColor = Colornames.bottomClr
        
        
        let nib = UINib(nibName: CellConfingName.SettingsTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.SettingsTableViewCell)
        
        
        tableview.register(UINib(nibName:CellConfingName.SettingHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)
        
        
    }
    override func viewDidLayoutSubviews() {
        if passVale == 2{
            topView.applyGradient(
                colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }else{
            topView.applyGradient(
                colors: [Colornames.stafGradient, Colornames.stafGradient1],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        section = sections
        
    }
}

@available(iOS 14.0, *)
extension SettingsViewController : UITableViewDelegate , UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier:CellConfingName.SettingHeaderView) as! SettingHeaderView
        cell.headerLabel.text = sections[section].title.translated()
        cell.headerLabel.setFont(style: .title, size: FontSize.TitleSize)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SettingsTableViewCell, for: indexPath) as! SettingsTableViewCell
        cell.nameLbl.text = sections[indexPath.section].items[indexPath.row].translated()
        cell.nameLbl.textColor = sections[indexPath.section].items[indexPath.row].translated() == menuname.logout ? .red : .black
        cell.faceIdSwitch.isHidden = sections[indexPath.section].items[indexPath.row].translated() != menuname.faceID ? true:false
        cell.arrowImg.isHidden = sections[indexPath.section].items[indexPath.row].translated() != menuname.faceID ? false:true
        cell.imgView.image = Images[indexPath.section].uiImages[indexPath.row]
        cell.imgView.tintColor =  Images[indexPath.section].uiImages[indexPath.row] == UIImage(systemName: "iphone.and.arrow.forward") ? .red : .black
        
        cell.arrowImg.applyRTLFlip(Language == "ar")
        cell.imgView.applyRTLFlip(Language == "ar")
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  sections[indexPath.section].items[indexPath.row] == menuname.contactUs{
            let vc = ContactUsVc(nibName: nil, bundle: nil)
            vc.passValue = passVale
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }else if  sections[indexPath.section].items[indexPath.row] == menuname.notifications{
            
            let vc = NotificationViewController(nibName: nil, bundle: nil)
            vc.passValue = passVale
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        }
        else if  sections[indexPath.section].items[indexPath.row] == menuname.reportABug{
            
            let vc = ReportBugVcViewController(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            vc.passValue = passVale
            present(vc, animated: true)
            
        }else if  sections[indexPath.section].items[indexPath.row] == menuname.feedback{
            
            let vc = RateUsViewController(nibName: nil, bundle: nil)
            vc.passValue = passVale
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        }
        
        
        else if  sections[indexPath.section].items[indexPath.row] == menuname.logout{
    
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: "Logout")
            
            let vc = LogoutViewController(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false)
            
        }
        
        else if  sections[indexPath.section].items[indexPath.row] == menuname.faq{
            
            let vc = FAQViewController(nibName: nil, bundle: nil)
            vc.passValue = passVale
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
        
        
        else if  sections[indexPath.section].items[indexPath.row] == menuname.changeAppLanguage{
            
            let vc = LanguageVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            present(vc, animated: true)
        }else if sections[indexPath.section].items[indexPath.row] == menuname.termsAndConditions{
            
            let vc = TermsAndCondVC(nibName: nil, bundle: nil)
            vc.passValue = passVale
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
struct Section {
    let title: String
    let items: [String]
}

struct Image {
    let title: String
    let uiImages: [UIImage?]
    
    // Custom initializer that takes an array of system image names (strings)
    init(title: String, Imageitems: [String]) {
        self.title = title
        // Convert each string in Imageitems to a UIImage
        self.uiImages = Imageitems.map { UIImage(systemName: $0) }
    }
}

let Images: [Image] = [
    Image(title: "GENERAL", Imageitems: ["bell.fill", "person.crop.circle.badge.questionmark.fill", "phone.arrow.up.right.circle.fill", "chart.line.uptrend.xyaxis","character.bubble.ja"]),
    Image(title: "FEEDBACK", Imageitems: ["questionmark.diamond.fill", "paperplane.fill", "iphone.and.arrow.forward"])
]
