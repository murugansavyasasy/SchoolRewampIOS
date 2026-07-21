import UIKit
import MessageUI

@available(iOS 14.0, *)
class ReportBugVcViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var remarkDefaultLbl: UILabel!
    @IBOutlet weak var selectDefaultLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var BugsTextview: UITextView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var ModuleDropDown: UIView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var selectModuleLbl: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var textViewStack: UIStackView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    let dropDown = DropDown()
    var Supportmail = UserDefaultFileManager.get_globalSelection()?.support_email
    var passValue = 1
    var placeholderLabel: UILabel!
    var isMenuSelected = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ModuleDropDown.setShadow()
        noteView.layer.cornerRadius = 10
        sendBtn.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    func setupUI() {
        BugsTextview.delegate = self
        BugsTextview.layer.cornerRadius = 8
        BugsTextview.layer.borderWidth = 0.5
        BugsTextview.layer.borderColor = UIColor.lightGray.cgColor
        BugsTextview.addDoneButton()
        scrollView.keyboardDismissMode = .interactive
        remarkDefaultLbl.setRequiredText("Remarks".translated())
        selectDefaultLbl.setRequiredText("Select Module".translated())
        selectModuleLbl.text = "Select the menu".translated()
        sendBtn.setTitle("Send Mail".translated(), for: .normal)
        hideKeyboardWhenSwipedDown()
        setupPlaceholder()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(categoryDropdown))
        ModuleDropDown.addGestureRecognizer(gesture)
    }
    
    func hideKeyboardWhenSwipedDown() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        swipeDown.delegate = self
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Type content".translated()
        placeholderLabel.font = BugsTextview.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.positionAsPlaceholder(in: BugsTextview)
        BugsTextview.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !BugsTextview.text.isEmpty // Hide if text exists
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedwidth = textView.frame.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedwidth, height: .greatestFiniteMagnitude))
        
        let minHeight:CGFloat = 120
        let maxHeight:CGFloat = 300
        
        let changedHeight = max(minHeight,newSize.height)
        let finalHeight = min(maxHeight, changedHeight)
        
        if textViewHeight.constant != finalHeight {
            
            textViewHeight.constant = finalHeight
            UIView.animate(withDuration: 0.15){
                self.view.layoutIfNeeded()
            }
        }
        
        textView.isScrollEnabled = newSize.height > maxHeight
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // MARK: - Dropdown
    @objc func categoryDropdown() {
        dropDown.dataSource = user_inputs.menuList
        dropDown.anchorView = ModuleDropDown
        dropDown.bottomOffset = CGPoint(x: 0, y: ModuleDropDown.frame.height)
        dropDown.direction = .bottom
        dropDown.selectionAction = { [weak self] index, item in
            self?.selectModuleLbl.text = item
            self?.isMenuSelected = true
        }
        dropDown.show()
    }
    
    // MARK: - Send Button
    @IBAction func SendBtnAct(_ sender: Any) {
      
        let details = BugsTextview.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isDetailsEmpty = details.isEmpty
        
        if !isMenuSelected && isDetailsEmpty {
            showAlert(title: "Missing Information".translated(),
                      message: "Please select a module and enter bug details.".translated())
            return
        }
        if !isMenuSelected {
            showAlert(title: "Missing Module".translated(),
                      message: "Please select a module.".translated())
            return
        }
        if isDetailsEmpty {
            showAlert(title: "Missing Details".translated(),
                      message: "Please enter bug details.".translated())
            return
        }
        
        // Case 4: All good
        openPreferredMail()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".translated(), style: .default))
        present(alert, animated: true)
    }
    
    func showMailOptions() {
        
        let alert = UIAlertController(
            title: "Send Email".translated(),
            message: "Choose mail app".translated(),
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Apple Mail".translated(), style: .default) { _ in
            self.sendViaAppleMail()
        })
        
        alert.addAction(UIAlertAction(title: "Gmail".translated(), style: .default) { _ in
            self.sendViaGmail()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: view.bounds.midX,
                                        y: view.bounds.midY,
                                        width: 0,
                                        height: 0)
        }
        
        present(alert, animated: true)
    }
    
    func openPreferredMail() {
        
        if MFMailComposeViewController.canSendMail() {
            showMailOptions()        // Apple Mail + Gmail
        } else {
            sendViaGmail()           // Direct redirect
        }
    }
    
    func sendViaAppleMail() {
        
        let toEmail = getToEmail()
        let content = getMailContent()
        
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(
                title: "Apple Mail Not Available".translated(),
                message: "Please configure Apple Mail or choose Gmail.".translated()
            )
            return
        }
        
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        mailVC.setToRecipients([toEmail])
        mailVC.setCcRecipients([
            "murugan@savyasasy.com",
            "swathi@savyasasy.com"
        ])
        mailVC.setSubject(content.subject)
        mailVC.setMessageBody(content.body, isHTML: false)
        
        present(mailVC, animated: true)
    }
    
    func sendViaGmail() {
        
        let toEmail = getToEmail()
        let content = getMailContent()
        
        let ccEmails = [
            "murugan@savyasasy.com",
            "swathi@savyasasy.com"
        ].joined(separator: ",")
        
        let gmailURLString =
        "googlegmail://co?to=\(toEmail)&cc=\(ccEmails)&subject=\(content.subject)&body=\(content.body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let gmailURL = URL(string: gmailURLString),
           UIApplication.shared.canOpenURL(gmailURL) {
            
            UIApplication.shared.open(gmailURL)
        } else {
            openGmailWeb(to: toEmail, subject: content.subject, body: content.body)
        }
    }
    
    func openGmailWeb(to: String, subject: String, body: String) {
        
        let ccEmails = "murugan@savyasasy.com,swathi@savyasasy.com"
        
        let webURLString =
        "https://mail.google.com/mail/u/0/?view=cm&to=\(to)&cc=\(ccEmails)&su=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: webURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func getToEmail() -> String {
        return Supportmail?
            .components(separatedBy: "/")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "support@savyasasy.com"
    }
    
    func getMailContent() -> (subject: String, body: String) {
        
        var name = ""
        let mobilenumber = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        var schoolName = ""
        var schoolId = ""
        
        if passValue == 1 {
            name = UserDefaultFileManager.get_staff_Details()?.name ?? ""
            schoolName = UserDefaultFileManager.get_staff_Details()?.school_name ?? ""
            schoolId = UserDefaultFileManager.get_staff_Details()?.school_id ?? ""
        } else {
            name = UserDefaultFileManager.get_child_Details()?.name ?? ""
            schoolName = UserDefaultFileManager.get_child_Details()?.school_name ?? ""
            schoolId = UserDefaultFileManager.get_child_Details()?.school_id ?? ""
        }
        
        
        let body = """
        Dear Team,
        
        School Name : \(schoolName)
        School ID : \(schoolId)
        
        Name : \(name)
        Mobile number : \(mobilenumber ?? "")
        
        Query : \(BugsTextview.text ?? "")
        """
        
        let subject = "Bug Report - \(selectModuleLbl.text ?? "")"
        return (subject, body)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Swipe Down Gesture Delegate
@available(iOS 14.0, *)
extension ReportBugVcViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}


extension ReportBugVcViewController {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let keyboardHeight = keyboardFrame.height + 50
        
        let bottomInset = keyboardHeight - view.safeAreaInsets.bottom
        
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        
        UIView.animate(withDuration: duration){
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else {return}
        
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
