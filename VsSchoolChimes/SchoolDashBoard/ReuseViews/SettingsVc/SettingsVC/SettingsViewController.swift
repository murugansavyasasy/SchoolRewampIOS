//
//  SettingsViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class SettingsViewController: UIViewController, BaktoHome, ViewAttachments {
    func viewAttachment(sender: UIButton) {
        updatePopoverHeight()
    }
    
    func dismiss(_: Bool) {
        removePopoverOverlay()
    }
    
    
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
    private var popoverOverlayView: UIView?
    // MARK: - Section Data
    lazy var sections: [Section] = [
        Section(
            title: menuname.accountSecurity,
            items: [
                menuname.changePassword,
                menuname.faceID
            ]
        ),
        Section(
            title: menuname.preference,
            items: [
                menuname.notifications,
                menuname.changeAppLanguage
            ]
        ),
        Section(
            title: menuname.supportInfo,
            items: [
                menuname.faq,
                menuname.contactUs,
                menuname.termsAndConditions,
                menuname.privacyPolicy,
                menuname.aboutApp,
                menuname.howToUse,
                menuname.whatsNew
            ]
        ),
        Section(
            title: menuname.feedbackSection,
            items: [
                menuname.reportABug,
                menuname.feedback,
                menuname.appVersion,
                menuname.logout
            ]
        )
    ]

    
    // MARK: - Image Data
    let Images: [Image] = [
        Image(title: "Account & Security", Imageitems: [
            "lock.rotation",
            "faceid"
        ]),
        Image(title: "Preference", Imageitems: [
            "bell",
            "character.bubble.ja"
        ]),
        Image(title: "Support & Information", Imageitems: [
            "person.crop.circle.badge.questionmark.fill",
            "phone.arrow.up.right.circle.fill",
            "chart.line.uptrend.xyaxis",
            "shield.lefthalf.filled",
            "info.circle.fill",
            "questionmark.circle",
            "WhatNews"
        ]),
        Image(title: "Feedback", Imageitems: [
            "questionmark.diamond.fill",
            "paperplane.fill",
            "number.square.fill",
            "iphone.and.arrow.forward"
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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.SettingsTableViewCell,
            for: indexPath
        ) as! SettingsTableViewCell
        
        let item = sections[indexPath.section].items[indexPath.row]
        let image = Images[indexPath.section].uiImages[indexPath.row]
        
        cell.nameLbl.localizationKey = item
        cell.nameLbl.textColor = item == menuname.logout ? .red : .black
        cell.faceIdSwitch.isHidden = item != menuname.faceID
        cell.arrowImg.isHidden = item == menuname.faceID
        if item == menuname.whatsNew {
            cell.imgView.image = UIImage(named: "WhatNews")
        } else {
            cell.imgView.image = image
        }

        if image == UIImage(systemName: "iphone.and.arrow.forward") {
            cell.imgView.tintColor = .red
        } else {
            cell.imgView.tintColor = .black
        }

        // ✅ App Version case
        if item == menuname.appVersion {
            cell.versionLbl.isHidden = false
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                cell.versionLbl.text = "\(version) (\(build))"
            }
            cell.arrowImg.isHidden = true
            cell.faceIdSwitch.isHidden = true
        } else {
            cell.versionLbl.isHidden = true
        }

        // ✅ RTL Support
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
            
        case "Privacy Policy":
            let vc = TermsAndCondVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.tittleString = "Privacy Policy"
            vc.url = UserDefaultFileManager.get_globalSelection()?.privacy_policy
            present(vc, animated: true)
        case "About the App":
            let vc = TermsAndCondVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.tittleString = "About the App"
            vc.url = UserDefaultFileManager.get_globalSelection()?.about_the_app
            present(vc, animated: true)
        case "How to Use?":
            let vc = TermsAndCondVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.tittleString = "How to Use?"
            vc.url = UserDefaultFileManager.get_globalSelection()?.how_to_use
            present(vc, animated: true)
        case menuname.notifications:
            let vc = NotificationViewController()
            vc.token = passVale == 1 ? UserDefaultFileManager.get_staff_Details()?.access_token ?? "" :
                                       UserDefaultFileManager.get_child_Details()?.access_token ?? ""
            vc.isParent = passVale == 2
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        case menuname.reportABug:
            let vc = ReportBugVcViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.passValue = passVale
            present(vc, animated: true)
            
        case menuname.feedback:
            presentPopover()
            
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
            vc.tittleString = "Terms & Conditions"
            vc.url = "https://schoolchimes.com/vs_web/terms_conditions/"
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
@available(iOS 14.0, *)
extension SettingsViewController {
    private func presentPopover() {
        let popoverVC = RateUsViewController()
        popoverVC.modalPresentationStyle = .popover
        popoverVC.delegate = self
        popoverVC.loadViewIfNeeded()
        popoverVC.view.layoutIfNeeded()
        
        let scrollContentHeight = popoverVC.tableview.contentSize.height
        let paddingX: CGFloat = 20
        let width = view.frame.width - (paddingX * 2)
        let height = min(scrollContentHeight, view.frame.height)
        
        popoverVC.preferredContentSize = CGSize(width: width, height: height)
        
        let originX = (view.frame.width - width) / 2
        let originY = (view.frame.height - height) / 2
        let sourceRect = CGRect(x: originX, y: originY, width: width, height: height)
        
        addPopoverOverlay()
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.backgroundColor = .white
            popover.sourceRect = sourceRect
            popover.permittedArrowDirections = []
            popover.delegate = self
        }
        
        present(popoverVC, animated: true)
    }
    private func addPopoverOverlay() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.alpha = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopoverOverlay))
        overlay.addGestureRecognizer(tapGesture)

        window.addSubview(overlay)
        popoverOverlayView = overlay

        UIView.animate(withDuration: 0.2) {
            overlay.alpha = 1
        }
    }
    func updatePopoverHeight() {
        guard let presentedVC = presentedViewController as? RateUsViewController else { return }

        presentedVC.loadViewIfNeeded()
        presentedVC.view.layoutIfNeeded()

        let scrollContentHeight = presentedVC.tableview.contentSize.height
        let paddingX: CGFloat = 20
        let width = view.frame.width - (paddingX * 2)
        let height = min(scrollContentHeight, view.frame.height * 0.85)

        presentedVC.preferredContentSize = CGSize(width: width, height: height)

        if let popover = presentedVC.popoverPresentationController {
            popover.sourceRect = CGRect(
                x: (view.frame.width - width) / 2,
                y: (view.frame.height - height) / 2,
                width: width,
                height: height
            )
        }
    }
    @objc private func dismissPopoverOverlay() {
        guard let popoverVC = presentedViewController else { return }
           popoverVC.dismiss(animated: true)
           removePopoverOverlay()
    }

    private func removePopoverOverlay() {
        guard let overlay = popoverOverlayView else { return }

        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
            self.popoverOverlayView = nil
        })
    }
}

@available(iOS 14.0, *)
extension SettingsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        removePopoverOverlay()
    }
}
