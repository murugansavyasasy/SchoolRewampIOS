//
//  chatWithStudentVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/07/25.
//

import UIKit

class chatWithStudentVc: UIViewController, ChatTableViewCellDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate {
    @IBOutlet weak var noRecordlbl: UILabel!
    @IBOutlet weak var replayStackView: UIStackView!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var teacherLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var TextViewFullView: UIView!
    
    @IBOutlet weak var MessgeTextview: UITextView!
    @IBOutlet weak var ReplyTextFild: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var staffMembersData = StaffMember()
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var chatDataDetails : [ChatMessage]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        tableView.addGestureRecognizer(longPressGesture)
        
        ReplyTextFild.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
        MessgeTextview.textColor = .lightGray
        
        MessgeTextview.delegate = self
       
        getChat()
    }
 
 override func viewDidLayoutSubviews() {
         view.applyGradient(
             colors: [Colornames.stafGradient, Colornames.stafGradient1],
             startPoint: CGPoint(x: 1, y: 0.5),
             endPoint: CGPoint(x: 0, y: 0.5)
         )
     
 }
 
 override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     
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
        print("Clear button tapped!")
//        textField.resignFirstResponder() // Hides the keyboard for the specific textField
//           view.endEditing(true)
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
     } else {
         // Fallback on earlier versions
     } // reset if needed
     if #available(iOS 14.0, *) {
         MediaPickerManager.shared.onMediaPicked = { picked in
             
             if let firstMedia = picked.first {
                 CustomAlert.showMediaAlert(for: firstMedia, in: self) {
                     print("Send action tapped")
                     // Proceed with upload/send here
                 }
             }
         }
     } else {
         // Fallback on earlier versions
     }
     if #available(iOS 14.0, *) {
         MediaPickerManager.shared.showPicker(from: self)
     } else {
         // Fallback on earlier versions
     }
 }
 
 
 @IBAction func sendBtnAction(_ sender: Any) {
     sendChat()
 }
 // MARK: - UITableView DataSource
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return chatDataDetails?.count ?? 0
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTVCell", for: indexPath) as! ChatTVCell
     let message = chatDataDetails?[indexPath.row]
     
     
     
     if message?.ans_file_path?.count == 0 {
         if message?.answer != "Not answered yet"{
             
             cell
                 .configure(
                     with: message?.answer ?? "", timeStamp: message?.answered_on ?? "",
                     isSender: false
                 )
         }
     }else{
         
         cell.messageLabel.isHidden = true
         cell.timeStampLbl.isHidden = true
         cell.imageStack.isHidden = false
         cell.imageConficure(with:message?.ans_file_path?.first?.url )
         
        

     }
     
     if message?.ques_file_path?.count == 0 {
         if message?.question != ""{
             cell.imageStack.isHidden = true
             cell.messageLabel.isHidden = false
             cell.timeStampLbl.isHidden = false
             cell
                 .configure(
                     with: message?.question ?? "", timeStamp: message?.asked_on ?? "",
                     isSender: message?.my_question ?? false
                 )
         }
         
         if message?.answer != "Not answered yet"{
             
             cell
                 .configure(
                     with: message?.answer ?? "", timeStamp: message?.answered_on ?? "",
                     isSender: false
                 )
         }
     }else{
         
         cell.messageLabel.isHidden = true
         cell.timeStampLbl.isHidden = true
         cell.imageStack.isHidden = false
         cell.imageConficure(with:message?.ques_file_path?.first?.url )
     }
     cell.delegate = self
     return cell
 }
 
 // MARK: - ChatTableViewCellDelegate
 func didSlideToReply(for message: String) {
     print("Reply to: \(message)")
     
     // Show a reply indicator (e.g., move focus to an input field with the selected message)
     //           messageHeight.constant = 190
     
     //           ReplyTextFild.isUserInteractionEnabled = false
     replayStackView.isHidden = false
     ReplyTextFild.text = message
     
     //
     //           let alert = UIAlertController(title: "Reply", message: "Replying to: \(message)", preferredStyle: .alert)
     //           alert.addTextField { textField in
     //               textField.placeholder = "Write your reply..."
     //           }
     //           alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
     //               // Handle sending the reply here
     //           }))
     //           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
     //           present(alert, animated: true, completion: nil)
 }
 
 
 
 
 // MARK: - Long Press Gesture Handler
//    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        guard gesture.state == .began else { return }
//        
//        let location = gesture.location(in: tableView)
//        if let indexPath = tableView.indexPathForRow(at: location) {
//            let message = messages[indexPath.row]
//            
//            // Only enable delete for receiver-side messages
//            if message.isSender {
//                showDeleteAction(for: indexPath)
//            }
//        }
//    }
//
// private func showDeleteAction(for indexPath: IndexPath) {
//     let alert = UIAlertController(
//         title: "Message Options",
//         message: "Choose an action for this message",
//         preferredStyle: .actionSheet
//     )
//     
//     // Delete action
//     alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//         // Remove the message from the data source and refresh the table view
//         self.messages.remove(at: indexPath.row)
//         self.tableView.deleteRows(at: [indexPath], with: .automatic)
//     }))
//     
//     // Block action
//     alert.addAction(UIAlertAction(title: "Block", style: .default, handler: { _ in
//         // Handle blocking logic here
//         print("Block button tapped")
//         // Example: Show a confirmation message or block the user
//         let blockAlert = UIAlertController(title: "Blocked", message: "You have blocked this user.", preferredStyle: .alert)
//         blockAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//         self.present(blockAlert, animated: true, completion: nil)
//     }))
//     
//     // Cancel action
//     alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//     
//     // Present the alert
//     present(alert, animated: true, completion: nil)
// }
 
 
 
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

 
 func getChat(){
     APIService.shared
         .makeApi(url: ServiceUrl.interaction_staff_get_questions , parameters: ["section_id" : staffMembersData.id ?? "","subject_id":staffMembersData.subject_id ?? "","offset":0,"is_class_teacher":staffMembersData.is_class_teacher ?? false], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? ""){ [self] (
             result:Result <ChatMessageSuc,
             Error>
         ) in
             switch result {
             case .success(let successMessage):
                 if successMessage.status == true{
                     DispatchQueue.main.async { [self] in
                         noRecordlbl.isHidden = true
                         chatDataDetails = successMessage.data?
                             .reversed() ?? []
                         tableView.reloadData()
                     }
                 }else{
                     DispatchQueue.main.async { [self] in
                         noRecordlbl.isHidden = false
                         noRecordlbl.text = successMessage.message ?? ""
                         //                            TextViewFullView.isHidden = true
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
             "staff_id": self.staffMembersData.id ?? "",
             "subject_id": self.staffMembersData.subject_id  ?? "",
             "question": self.MessgeTextview.text?.removingExtraSpaces() ?? "",
             "is_class_teacher": self.staffMembersData.is_class_teacher ?? false,
             "file_path": [],
             "question_id" : "",
             "reply_type" : "1",
             "is_change_answer" : false
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
                     self.getChat()
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


