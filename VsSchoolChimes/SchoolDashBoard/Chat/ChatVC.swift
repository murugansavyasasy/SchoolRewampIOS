//
//  ChatVC.swift
//  VsSchoolChimes
//
//  Created by admin on 16/12/24.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate,UITableViewDataSource, ChatTableViewCellDelegate,UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var TextViewFullView: UIView!
    @IBOutlet weak var sendImageView: UIImageView!
    @IBOutlet weak var MessgeTextview: UITextView!
    @IBOutlet weak var ReplyTextFild: UITextField!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
       var getValue = 1
       private var messages: [(text: String, isSender: Bool)] = [
           ("Hello!", true),
           ("Hi there! How are you?jksfvnjkjkzbvuibskvbkdbvkbdkvbkdbkjvbjkbjvkzjkbvbjksbcvjkbjkcvbjkabvkjbkjdbvkjadbfkvbkdbvjksbdjkvbakdbvkbzdkjbvkjzdbjkvbkzdbvkdzbkbkzdbvkx", false),
           ("I'm good, thanks! What about you?fjjkbdfbkb", true),
           ("Doing great, thanks for asking.", false)
       ]
       
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
           messageHeight.constant = 0
           TextViewFullView.layer.cornerRadius = Colornames.CORadius5
           TextViewFullView.layer.masksToBounds = true
           TextViewFullView.layer.borderColor = UIColor.lightGray.cgColor
           TextViewFullView.layer.borderWidth = 0.5
           let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
           tableView.addGestureRecognizer(longPressGesture)
           
           ReplyTextFild.delegate = self
           
           
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
               NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
           MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
           MessgeTextview.textColor = .lightGray
           
           MessgeTextview.delegate = self
          
       }
    
    override func viewDidLayoutSubviews() {
        if getValue == 1{
            view.applyGradient(
                colors: [Colornames.stafGradient, Colornames.stafGradient1],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }
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
        ReplyTextFild.isUserInteractionEnabled = true
        
        messageHeight.constant = 0
           return true
       }
    
    @IBAction func backBtn(_ sender: Any) {
        
        
        dismiss(animated: true)
    }
    
       // MARK: - UITableView DataSource
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return messages.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTVCell", for: indexPath) as! ChatTVCell
           let message = messages[indexPath.row]
           cell.configure(with: message.text, isSender: message.isSender)
           cell.delegate = self
           return cell
       }
       
       // MARK: - ChatTableViewCellDelegate
       func didSlideToReply(for message: String) {
           print("Reply to: \(message)")
           
           // Show a reply indicator (e.g., move focus to an input field with the selected message)
           messageHeight.constant = 190
           
//           ReplyTextFild.isUserInteractionEnabled = false
           
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
       @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
           guard gesture.state == .began else { return }
           
           let location = gesture.location(in: tableView)
           if let indexPath = tableView.indexPathForRow(at: location) {
               let message = messages[indexPath.row]
               
               // Only enable delete for receiver-side messages
               if message.isSender {
                   showDeleteAction(for: indexPath)
               }
           }
       }

    private func showDeleteAction(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Message Options",
            message: "Choose an action for this message",
            preferredStyle: .actionSheet
        )
        
        // Delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            // Remove the message from the data source and refresh the table view
            self.messages.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        
        // Block action
        alert.addAction(UIAlertAction(title: "Block", style: .default, handler: { _ in
            // Handle blocking logic here
            print("Block button tapped")
            // Example: Show a confirmation message or block the user
            let blockAlert = UIAlertController(title: "Blocked", message: "You have blocked this user.", preferredStyle: .alert)
            blockAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(blockAlert, animated: true, completion: nil)
        }))
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if MessgeTextview.text == TexviewStringFile.Enter_Chat_Description {
            MessgeTextview.text = ""
            MessgeTextview.textColor = .black
        }
        
    }
//    func textViewDidChange(_ textView: UITextView) {
//        if textView.text == "" {
//            MessgeTextview.text = "Type your message here..."
//            MessgeTextview.textColor = .lightGray
//        }
//    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            MessgeTextview.text = TexviewStringFile.Enter_Chat_Description
            MessgeTextview.textColor = .lightGray
        }
    }

    
   }
