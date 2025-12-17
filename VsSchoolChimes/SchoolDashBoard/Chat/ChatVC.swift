//
//  ChatVC.swift
//  VsSchoolChimes
//
//  Created by admin on 16/12/24.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate,UITableViewDataSource, ChatTableViewCellDelegate,UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var noRecordlbl: UILabel!
    @IBOutlet weak var replayStackView: UIStackView!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var teacherLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var TextViewFullView: UIView!
    @IBOutlet weak var MessgeTextview: UITextView!
    @IBOutlet weak var ReplyTextFild: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blockedBtn: UIButton!
    @IBOutlet weak var blockedLbl: UILabel!
    @IBOutlet weak var blockedView: UIView!
    var getValue = 1
    var staffMembersData = StaffMember()
    var childDetails = UserDefaultFileManager.get_child_Details()
    var chatDataDetails : [ChatMessage]?
    let Askedby  = "Asked by ~ "
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        teacherLbl.text = staffMembersData.name
        subjectLbl.text = staffMembersData.subject_name
        blockedView.isHidden = true
        teacherLbl.setFont(style: .title, size: 15)
        subjectLbl.setFont(style: .title, size: 11)
        if staffMembersData.is_blocked == true {
            blockedView.isHidden = false
            TextViewFullView.isHidden = true
        }else{
            blockedView.isHidden = true
            TextViewFullView.isHidden = false
        }
        blockedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        blockedLbl.setFont(style: .body, size: FontSize.BodySize)
        MessgeTextview.addDoneButton()
        let nib = UINib(nibName: CellConfingName.ChatTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellConfingName.ChatTVCell)
        ReplyTextFild.layer.cornerRadius = Colornames.CORadius5
        ReplyTextFild.layer.masksToBounds = true
        ReplyTextFild.layer.borderColor = UIColor.lightGray.cgColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        TextViewFullView.layer.cornerRadius = Colornames.CORadius5
        TextViewFullView.layer.masksToBounds = true
        TextViewFullView.layer.borderColor = UIColor.lightGray.cgColor
        TextViewFullView.layer.borderWidth = 0.5
        ReplyTextFild.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
        MessgeTextview.textColor = .lightGray
        MessgeTextview.delegate = self
        getStaff()
    }
    
    func scrollToBottom() {
        let lastSection = tableView.numberOfSections - 1
        guard lastSection >= 0 else { return }
        let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
        guard lastRow >= 0 else { return }
        let indexPath = IndexPath(row: lastRow, section: lastSection)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                print("keyboardSize.height",keyboardSize.height)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        ReplyTextFild.isUserInteractionEnabled = false
        ReplyTextFild.text = ""
        replayStackView.isHidden = true
        return true
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func addAttachmenAction(_ sender: Any) {
        if #available(iOS 14.0, *) {
            MediaPickerManager.shared.pickedMedia = []
        }
        if #available(iOS 14.0, *) {
            MediaPickerManager.shared.onMediaPicked = { picked in
                if let firstMedia = picked.first {
                    CustomAlert.showMediaAlert(for: firstMedia, in: self) {
                    }
                }
            }
        }
        if #available(iOS 14.0, *) {
            MediaPickerManager.shared.showPicker(from: self)
        }
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        let text = MessgeTextview.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty, text != TexviewStringFile.Enter_Chat_Description else {
            return
        }
        sendChat()
        
    }
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatDataDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ChatTVCell, for: indexPath) as! ChatTVCell
        let message = chatDataDetails?[indexPath.row]
        if message?.my_question == false{
            cell.myQuestionView.isHidden = true
            cell.othersQuestionView.isHidden = false
            cell.studentNameLbl.isHidden = false
            cell.othersQuestionLbl.text = message?.question
            cell.studentNameLbl.text = Askedby + "\(message?.student_name ?? "")"
        }else{
            cell.myQuestionView.isHidden = false
            cell.othersQuestionView.isHidden = true
            cell.studentNameLbl.isHidden = true
            cell.messageLabel.text = message?.question
            cell.timeStampLbl.text = formattedDateStatus(from: message?.asked_on ?? "", isTimeNeeded: true)
        }
        if message?.answered_on?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            cell.answerView.isHidden = true
        }else{
            cell.answerLbl.text = message?.answer
            cell.anseredOnLbl.text = formattedDateStatus(from: message?.answered_on ?? "", isTimeNeeded: true)
        }
        cell.delegate = self
        return cell
    }
    
    // MARK: - ChatTableViewCellDelegate
    func didSlideToReply(for message: String,studentName: String) {
        replayStackView.isHidden = false
        ReplyTextFild.text = message
        
    }
    private func showDeleteAction(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: AlertstringFile.MessageOptions,
            message: AlertstringFile.Choose_an_action_for_this_message,
            preferredStyle: .actionSheet
        )
        // Delete action
        alert.addAction(UIAlertAction(title: AlertstringFile.delete, style: .destructive, handler: { _ in
            // Remove the message from the data source and refresh the table view
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        // Block action
        alert.addAction(UIAlertAction(title: AlertstringFile.Block, style: .default, handler: { _ in
            let blockAlert = UIAlertController(title: AlertstringFile.Block, message: AlertstringFile.You_have_blocked_this_user, preferredStyle: .alert)
            blockAlert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default, handler: nil))
            self.present(blockAlert, animated: true, completion: nil)
        }))
        // Cancel action
        alert.addAction(UIAlertAction(title: AlertstringFile.Cancel, style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if MessgeTextview.text == TexviewStringFile.Enter_Chat_Description {
            MessgeTextview.text = ""
            MessgeTextview.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
            MessgeTextview.textColor = .lightGray
        }
    }
    func getStaff(){
        APIService.shared
            .makeApi(url: ServiceUrl.interaction_get_staff_answers , parameters: [ChatAPIKeys.staffId : staffMembersData.id ?? "",ChatAPIKeys.subjectId:staffMembersData.subject_id ?? "",ChatAPIKeys.offset:0,ChatAPIKeys.isClassTeacher:staffMembersData.is_class_teacher ?? false], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? ""){ [self] (
                result:Result <ChatMessageSuc,Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            noRecordlbl.isHidden = true
                            chatDataDetails = successMessage.data?
                                .reversed() ?? []
                            tableView.reloadData()
                            DispatchQueue.main.async {
                                self.scrollToBottom()
                            }
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            noRecordlbl.isHidden = false
                            noRecordlbl.text = successMessage.message ?? ""
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func sendChat(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let parameters: [String: Any] = [
                ChatAPIKeys.staffId: self.staffMembersData.id ?? "",
                ChatAPIKeys.subjectId: self.staffMembersData.subject_id  ?? "",
                ChatAPIKeys.question: self.MessgeTextview.text?.removingExtraSpaces() ?? "",
                ChatAPIKeys.isClassTeacher: self.staffMembersData.is_class_teacher ?? false,
                ChatAPIKeys.filePath: []
            ]
            APIService.shared.makeApi(
                url: ServiceUrl.interaction_student_ask_question,
                parameters: parameters,
                type: ApitTypeSringFile.POST,
                token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
            ) { [weak self] (result: Result<MessageSuc, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        self.MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
                        self.MessgeTextview.textColor = .lightGray
                        self.resetTextView()
                        self.getStaff()
                    }
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                    // Optionally show error alert here
                }
            }
        }
        
    }
    func resetTextView() {
        MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
        MessgeTextview.textColor = .lightGray
        MessgeTextview.resignFirstResponder()
    }
}

extension String {
    func removingExtraSpaces() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
