//
//  SettingsViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class SettingsViewController: UIViewController, BaktoHome {
    
    func backtohome(type: String) {
        delegate?.backtohome(type: "")
        tableview.reloadData()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var SettingspageHeading: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var topView: UIView!
    
    // MARK: - Properties
    var menuname = SettingStringFile()
    var section: [Section]?
    var imagesArray: [UIImage] = []
    var delegate: BaktoHome?
    var passVale = 1
    var Language: String?
    
    // MARK: - Section Data
    lazy var sections: [Section] = [
        Section(
            title: "Account & Security",
            items: [
                "Change Password",
                menuname.faceID,
                menuname.logout
            ]
        ),
        Section(
            title: "Preference",
            items: [
                menuname.notifications,
                menuname.changeAppLanguage
            ]
        ),
        Section(
            title: "Support & Information",
            items: [
                menuname.faq,
                menuname.contactUs,
                menuname.termsAndConditions,
                "Privacy Policy",
                "About the App",
                "How to Use?",
                "Version",
                "What's new"
            ]
        ),
        Section(
            title: "Feedback",
            items: [
                menuname.reportABug,
                menuname.feedback
            ]
        )
    ]
    
    // MARK: - Image Data
    let Images: [Image] = [
        Image(title: "Account & Security", Imageitems: [
            "lock.rotation",       // Change Password
            "faceid",              // Face ID
            "iphone.and.arrow.forward" // Logout
        ]),
        Image(title: "Preference", Imageitems: [
            "bell",                // Notifications
            "character.bubble.ja"  // Language
        ]),
        Image(title: "Support & Information", Imageitems: [
            "person.crop.circle.badge.questionmark.fill", // FAQ
            "phone.arrow.up.right.circle.fill",           // Contact Us
            "chart.line.uptrend.xyaxis",                  // Terms
            "shield.lefthalf.filled",                     // Privacy
            "info.circle.fill",                           // About App
            "questionmark.circle",                        // How to Use
            "number.square.fill",                         // Version
            "WhatNews"
        ]),
        Image(title: "Feedback", Imageitems: [
            "questionmark.diamond.fill", // Report a Bug
            "paperplane.fill"            // Feedback
        ])
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        section = sections
        SettingspageHeading.text = MenuTapbar.shared.Settings
        SettingspageHeading.setFont(style: .body, size: 20)
        
        for imageCategory in Images {
            for uiImage in imageCategory.uiImages {
                if let image = uiImage {
                    imagesArray.append(image)
                } else {
                    print("⚠️ Failed to load UIImage for one of the symbols in \(imageCategory.title)")
                }
            }
        }
        
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = Colornames.bottomClr
        
        tableview.register(UINib(nibName: CellConfingName.SettingsTableViewCell, bundle: nil),
                           forCellReuseIdentifier: CellConfingName.SettingsTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.SettingHeaderView, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        section = sections
    }
}

// MARK: - TableView Delegate & DataSource
@available(iOS 14.0, *)
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.SettingHeaderView) as! SettingHeaderView
        header.headerLabel.text = sections[section].title.translated()
        header.headerLabel.setFont(style: .title, size: FontSize.TitleSize)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SettingsTableViewCell, for: indexPath) as! SettingsTableViewCell
        
        let item = sections[indexPath.section].items[indexPath.row]
        let image = Images[indexPath.section].uiImages[indexPath.row]
        
        cell.nameLbl.text = item.translated()
        cell.nameLbl.textColor = item == menuname.logout ? .red : .black
        cell.faceIdSwitch.isHidden = item != menuname.faceID
        cell.arrowImg.isHidden = item == menuname.faceID
        cell.imgView.image = image
        
        if item == "What's new" {
            cell.imgView.image = UIImage(named: "WhatNews")
        }
        
        if image == UIImage(systemName: "iphone.and.arrow.forward") {
            cell.imgView.tintColor = .red
        } else {
            cell.imgView.tintColor = .black
        }
        
        if item == "Version" {
            cell.versionLbl.isHidden = false
            cell.versionLbl.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            cell.arrowImg.isHidden = true
            cell.faceIdSwitch.isHidden = true
        } else {
            cell.versionLbl.isHidden = true
        }
        
        cell.arrowImg.applyRTLFlip(Language == "ar")
        cell.imgView.applyRTLFlip(Language == "ar")
        cell.selectionStyle = .none
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section].items[indexPath.row]
        
        switch selectedItem {
        case menuname.contactUs:
            let vc = ContactUsVc()
            vc.passValue = passVale
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        case menuname.notifications:
            let vc = NotificationViewController()
            vc.token = passVale == 1 ? UserDefaultFileManager.get_staff_Details()?.access_token ?? "" :
                                       UserDefaultFileManager.get_child_Details()?.access_token ?? ""
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        case menuname.reportABug:
            let vc = ReportBugVcViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.passValue = passVale
            present(vc, animated: true)
            
        case menuname.feedback:
            if let url = URL(string: "https://apps.apple.com/app/id700513732?action=write-review") {
                UIApplication.shared.open(url)
            }
            
        case menuname.logout:
            UserDefaults.standard.set(true, forKey: "Logout")
            let vc = LogoutViewController()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false)
            
        case menuname.faq:
            let vc = FAQViewController()
            vc.passValue = passVale
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        case menuname.changeAppLanguage:
            let vc = LanguageVc()
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            present(vc, animated: true)
            
        case menuname.termsAndConditions:
            let vc = TermsAndCondVC()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        case "What's new":
            let vc = WhatsNewVc()
            vc.isStaff = passVale == 1
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        case "Change Password":
            let vc = CreatePasswordVc()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Section Models
struct Section {
    let title: String
    let items: [String]
}

struct Image {
    let title: String
    let uiImages: [UIImage?]
    
    init(title: String, Imageitems: [String]) {
        self.title = title
        self.uiImages = Imageitems.map { UIImage(systemName: $0) ?? UIImage(named: $0) }
    }
}
