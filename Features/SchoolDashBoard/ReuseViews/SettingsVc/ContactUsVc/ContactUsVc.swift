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
    
    private func splitValues(_ text: String?) -> [String] {
        guard let text = text else { return [] }
        return text
            .split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    private func multilineText(from text: String?) -> String {
        splitValues(text).joined(separator: "\n")
    }
    
}

extension ContactUsVc : UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ContactUsTVCell, for: indexPath) as! ContactUsTVCell
        
        cell.contentLabel.text = content[indexPath.row]
        cell.iconImg.image = icon[indexPath.row]
        cell.mailOrPhoneLabel.text = multilineText(from: contact[indexPath.row])
        cell.mailOrPhoneLabel.numberOfLines = 0
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let values = splitValues(contact[indexPath.row])
        guard !values.isEmpty else { return }
        
        if indexPath.row == 0 {
            showPhoneActionSheet(numbers: values)
        } else {
            showEmailActionSheet(emails: values)
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
    
    private func showPhoneActionSheet(numbers: [String]) {
        
        let alert = UIAlertController(
            title: "Call",
            message: "Choose a phone number",
            preferredStyle: .actionSheet
        )
        
        numbers.forEach { number in
            alert.addAction(UIAlertAction(title: number, style: .default) { _ in
                let phone = number.replacingOccurrences(of: " ", with: "")
                if let url = URL(string: "tel://\(phone)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentActionSheet(alert)
    }
    
    private func showEmailActionSheet(emails: [String]) {
        
        let alert = UIAlertController(
            title: "Email",
            message: "Choose an email address",
            preferredStyle: .actionSheet
        )
        
        emails.forEach { email in
            alert.addAction(UIAlertAction(title: email, style: .default) { _ in
                
                let gmailURL = URL(string: "googlegmail://co?to=\(email)")
                let webURL = URL(string: "https://mail.google.com/mail/?view=cm&to=\(email)")
                
                if let gmailURL, UIApplication.shared.canOpenURL(gmailURL) {
                    UIApplication.shared.open(gmailURL)
                } else if let webURL {
                    UIApplication.shared.open(webURL)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentActionSheet(alert)
    }
    
    private func presentActionSheet(_ alert: UIAlertController) {
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
}
