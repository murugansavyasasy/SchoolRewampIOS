//
//  ContactUsVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class ContactUsVc: UIViewController {

    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    var content = ["Our 24*7 Customer Service.","Write us at."]
    var contact = [UserDefaultFileManager.get_globalSelection()?.support_contact,UserDefaultFileManager.get_globalSelection()?.support_email]
    var icon: [UIImage] = [.phone, .mail]
    var passValue = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        BackBtn.setTitle(MenuTapbar.shared.Contact_Us, for: .normal)
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
        
        tv.dataSource = self
        tv.delegate = self
        let nib = UINib(nibName: CellConfingName.ContactUsTVCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.ContactUsTVCell)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UpdateTableviewHeight()
    }
    
    func UpdateTableviewHeight(){
        tv.layoutIfNeeded()
        tableviewHeight.constant = tv.contentSize.height
    }

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
  
}

extension ContactUsVc : UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ContactUsTVCell, for: indexPath) as! ContactUsTVCell
        
        cell.contentLabel.text = content[indexPath.row]
        cell.mailOrPhoneLabel.text = contact[indexPath.row]
        cell.iconImg.image = icon[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)

        guard let value = contact[indexPath.row] else { return }

        switch indexPath.row {

        case 0:
            // Phone call
            let phoneNumber = value.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: "tel://\(phoneNumber)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }

        case 1:
            // Gmail app → browser fallback (To only)
            let gmailAppURL = URL(string: "googlegmail://co?to=\(value)")
            let gmailWebURL = URL(string: "https://mail.google.com/mail/?view=cm&to=\(value)")

            if let appURL = gmailAppURL,
               UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL)
            } else if let webURL = gmailWebURL {
                UIApplication.shared.open(webURL)
            }

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            self.UpdateTableviewHeight()
        }
    }
    
}
