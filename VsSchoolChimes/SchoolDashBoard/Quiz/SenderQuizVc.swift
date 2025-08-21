//
//  SenderQuizVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 18/08/25.
//

import UIKit

class SenderQuizVc: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var numberOfQuestionText: UITextField!
    @IBOutlet weak var discriptionsTextFild: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    var initialHeight : CGFloat = 60
    var maxHeight : CGFloat = 300
    override func viewDidLoad() {
        super.viewDidLoad()
        fullView.layer.cornerRadius = 10
        titleText.delegate = self
        discriptionsTextFild.delegate = self
        
        titleText.addDoneButton()
        discriptionsTextFild.addDoneButton()
        numberOfQuestionText.addDoneButton()
        // Do any additional setup after loading the view.
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel.isHidden = !textView.text.isEmpty // Toggle visibility
        
        let size = textView.contentSize
        
        // Check if the content exceeds the initial height
        if size.height > initialHeight {
            // Update the height constraint based on content size
            let newHeight = min(size.height, maxHeight) // Cap the height to maxTextViewHeight
            textViewHeightConstraint.constant = newHeight
        }
        
        // Animate the change for smoother UI
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll to make the UITextView visible
//        scrollToView(textView)
    }

    @IBAction func createQuizBtnAct(_ sender: UIButton) {
        
        let params: [String: Any] = [
            "title": titleText.text ?? "",
            "description": discriptionsTextFild.text ?? "",
            "no_of_question" : 1,
            "level": 1,
            "level_flag" : false
        ]
        
        
//        let vc = RecipientVc(nibName: nil, bundle: nil)
//        vc.ScreenType = Menu_id.event
//        vc.Common_request_params = params
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        
        let vc = CreateQuizQutionVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
   

}
