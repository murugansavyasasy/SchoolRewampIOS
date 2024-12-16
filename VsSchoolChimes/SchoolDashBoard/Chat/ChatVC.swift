//
//  ChatVC.swift
//  VsSchoolChimes
//
//  Created by admin on 16/12/24.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate,UITableViewDataSource, ChatTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
       
       private var messages: [(text: String, isSender: Bool)] = [
           ("Hello!", true),
           ("Hi there! How are you?jksfvnjkjkzbvuibskvbkdbvkbdkvbkdbkjvbjkbjvkzjkbvbjksbcvjkbjkcvbjkabvkjbkjdbvkjadbfkvbkdbvjksbdjkvbakdbvkbzdkjbvkjzdbjkvbkzdbvkdzbkbkzdbvkx", false),
           ("I'm good, thanks! What about you?fjjkbdfbkb", true),
           ("Doing great, thanks for asking.", false)
       ]
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           let nib = UINib(nibName: "ChatTVCell", bundle: nil)
           tableView.register(nib, forCellReuseIdentifier: "ChatTVCell")
        
           tableView.dataSource = self
           tableView.delegate = self
           tableView.separatorStyle = .none
           tableView.rowHeight = UITableView.automaticDimension
           tableView.estimatedRowHeight = 44
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
           let alert = UIAlertController(title: "Reply", message: "Replying to: \(message)", preferredStyle: .alert)
           alert.addTextField { textField in
               textField.placeholder = "Write your reply..."
           }
           alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
               // Handle sending the reply here
           }))
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           present(alert, animated: true, completion: nil)
       }
   }
