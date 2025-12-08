//
//  chatWithStudentVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/07/25.
//

import UIKit

class chatWithStudentVc: UIViewController,UITextViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var replyFullview: UIView!
    @IBOutlet weak var replyBtnStck: UIStackView!
    @IBOutlet weak var noRecordlbl: UILabel!
    @IBOutlet weak var studetnNameLbl: UILabel!
    @IBOutlet weak var MessgeTextview: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var replyAllBtn: UIButton!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var PopupContainerview: UIView!
    @IBOutlet weak var PopupView: UIView!
    @IBOutlet weak var BlockBtn: UIButton!
    @IBOutlet weak var reasonTextfield: PaddedTextField!
    @IBOutlet weak var Popuptopview: UIView!
    @IBOutlet weak var BlockStudentDefLbl: UILabel!
    @IBOutlet weak var reasonDefLbl: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    
    
    var staffMembersData = StaffMember()
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var chatDataDetails : [StaffChatMessage]?
    var selectedMessage: StaffChatMessage?
    var Privatereply = "Private reply"
    var Publicreply = "Public reply"
    override func viewDidLoad() {
        super.viewDidLoad()
        let subject = staffMembersData.subject_name ?? ""
        let class_name = "\(staffMembersData.name ?? "") (\(staffMembersData.section_name ?? ""))"
        classNameLbl.configureAsBackTitle(firstLine: class_name, secondLine: subject)
        replyFullview.layer.cornerRadius = 10
        MessgeTextview.layer.cornerRadius = 10
        replyFullview.isHidden = true
        MessgeTextview.isHidden = true
        MessgeTextview.addDoneButton()
        questionLbl.setFont(style: .body, size: FontSize.BodySize)
        noRecordlbl.isHidden = true
        noDataImage.isHidden = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        let nib = UINib(nibName: CellConfingName.ChatTVCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellConfingName.ChatTVCell)
        tableView.register(UINib(nibName: CellConfingName.StaffChatTV, bundle: nil), forCellReuseIdentifier: CellConfingName.StaffChatTV)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        PopupContainerview.isHidden = true
        PopupContainerview.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        reasonTextfield.addDoneButton()
        BlockStudentDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        reasonDefLbl.setFont(style: .body, size: FontSize.TitleSize)
        BlockBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        BlockBtn.layer.cornerRadius = 8
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
        MessgeTextview.delegate = self
        getChat()
    }
    
    
    override func viewDidLayoutSubviews() {
        PopupView.layer.cornerRadius = 10
        Popuptopview.layer.cornerRadius = 10
        Popuptopview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        Popuptopview.clipsToBounds = true
    }
    
    //MARK: Api Call functions
    func getChat(){
        APIService.shared
            .makeApi(url: ServiceUrl.interaction_staff_get_questions , parameters: [ChatAPIKeys.section_id : staffMembersData.section_id ?? "",ChatAPIKeys.subjectId:staffMembersData.subject_id ?? "",ChatAPIKeys.offset:0,ChatAPIKeys.isClassTeacher:staffMembersData.is_class_teacher ?? false], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? ""){ [self] (
                result:Result <StaffChatResponse,Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            noRecordlbl.isHidden = true
                            noDataImage.isHidden = true
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
                            noDataImage.isHidden = false
                            noRecordlbl.text = successMessage.message ?? ""
                        }
                    }
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                    noRecordlbl.isHidden = false
                    noDataImage.isHidden = false
                    noRecordlbl.text = error.localizedDescription
                }
            }
    }
    
    func Send_Answer_Api(replyType:String){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let parameters: [String: Any] = [
                ChatAPIKeys.question_id : selectedMessage?.id ?? "",
                ChatAPIKeys.answer: MessgeTextview.text ?? "",
                ChatAPIKeys.reply_type : replyType,
                ChatAPIKeys.is_change_answer : !(selectedMessage?.answer_on == ""),
                ChatAPIKeys.filePath : []
            ]
            APIService.shared.makeApi(
                url: ServiceUrl.comm_api_interaction_staff_ans_question,
                parameters: parameters,
                type: ApitTypeSringFile.POST,
                token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
            ) { [weak self] (result: Result<StaffAnswerResponse, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        if response.status == true{
                            self.getChat()
                            self.replyFullview.isHidden = true
                            self.MessgeTextview.isHidden = true
                            self.MessgeTextview.text = ""
                            self.MessgeTextview.resignFirstResponder()
                            self.view.endEditing(true)
                        }else{
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: response.message ?? "", on: self) {}
                        }
                    }
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message:error.localizedDescription, on: self) {}
                }
            }
        }
    }
    
    func Block_Api(){
        let param: [String:Any] = [
            ChatAPIKeys.student_id : selectedMessage?.student_id ?? "",
            ChatAPIKeys.is_block : !(selectedMessage?.is_blocked ?? false),
            ChatAPIKeys.reason : reasonTextfield.text ?? ""
        ]
        APIService.shared.makeApi(url: ServiceUrl.comm_api_interaction_block_student, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") { [weak self]
            (result: Result<CommonApiSuc,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                            self.getChat()
                            self.hidePopup()}
                    }else{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) {}
                    }
                case .failure(let failure):
                    print("Error",failure.localizedDescription)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {}
                }
            }
        }
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
            if MessgeTextview.isFirstResponder && self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
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
                    }}}
        }
        if #available(iOS 14.0, *) {
            MediaPickerManager.shared.showPicker(from: self)
        }
    }
    
    @IBAction func closeBtnAct(_ sender: Any) {
        replyFullview.isHidden = true
        MessgeTextview.isHidden = true
        MessgeTextview.text = ""
        MessgeTextview.resignFirstResponder()
        view.endEditing(true)
    }
    
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        if sender == replyBtn {
            Send_Answer_Api(replyType: "2")
        }else{
            Send_Answer_Api(replyType: "1")
        }
    }
    
    @IBAction func ClosePopupAct(_ sender: UIButton) {
        hidePopup()
    }
    
    @IBAction func BlockStudentAct(_ sender: UIButton) {
        if reasonTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true{
            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Missing_Information, message: AlertstringFile.Please_enter_reson_for_blocking, on: self)
        }else {
            Block_Api()
        }
    }
    
    func showPopup() {
        PopupContainerview.alpha = 0
        PopupContainerview.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.PopupContainerview.alpha = 1
        }
    }
    
    func hidePopup() {
        reasonTextfield.text = ""
        UIView.animate(withDuration: 0.3, animations: {
            self.PopupContainerview.alpha = 0
        }) { _ in
            self.PopupContainerview.isHidden = true
        }
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
    
    
    func resetTextView() {
        MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
        MessgeTextview.textColor = .lightGray
        MessgeTextview.resignFirstResponder()
    }
}


extension chatWithStudentVc: UITableViewDelegate,UITableViewDataSource,ChatTableViewCellDelegate,SelectedId{
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatDataDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.StaffChatTV, for: indexPath) as! StaffChatTV
        
        let message = chatDataDetails?[indexPath.row]
        cell.QuestionLbl.text = message?.question
        cell.studentNameLbl.text = message?.student_name
        cell.questionDateLbl.text = formattedDateStatus(from: message?.created_on ?? "", isTimeNeeded: true)
        cell.replyTypeLbl.text = message?.reply_type == "2" ? Privatereply : Publicreply
        cell.answerLbl.text = message?.answer
        cell.answerDateLbl.text = formattedDateStatus(from: message?.answer_on ?? "", isTimeNeeded: true)
        let isAnswered = !(message?.answer_on == "")
        cell.edit(edit: true, delete: true, selectedId: message?.id ?? "", isChangeAnswer: isAnswered, isBlock: message?.is_blocked ?? false)
        cell.answerView.isHidden = !isAnswered
        cell.replyTypeLbl.isHidden = !isAnswered
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - ChatTableViewCellDelegate
    func didSlideToReply(for message: String,studentName: String) {
        print("Reply to: \(message)")
        replyFullview.isHidden = false
        studetnNameLbl.text = "Reply to: \(studentName)"
        
    }
    
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            replyFullview.isHidden = false
            MessgeTextview.isHidden = false
            if let message = chatDataDetails?.first(where: { $0.id == id }) {
                selectedMessage = message
                studetnNameLbl.text = CommonStringFile.ReplyingTo + (message.student_name ?? "")
                questionLbl.text = message.question
            }
            MessgeTextview.becomeFirstResponder()
            
        }else {
            if let message = chatDataDetails?.first(where: { $0.id == id }) {
                selectedMessage = message
            }
            if selectedMessage?.is_blocked == true{
                self.Block_Api()
            }else{
                showPopup()
            }
            
        }
    }
}
