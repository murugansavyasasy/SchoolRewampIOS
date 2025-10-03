//
//  SenderQuizVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 18/08/25.
//

import UIKit

class SenderQuizVc: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var numberOfQuestionText: UITextField!
    @IBOutlet weak var discriptionsTextFild: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkBox: UIView!
    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    var initialHeight : CGFloat = 60
    var maxHeight : CGFloat = 300
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var selectNotice: SelectNotice?
    var IsChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullView.layer.cornerRadius = 10
        titleText.delegate = self
        discriptionsTextFild.delegate = self
        
        backBtn
            .configureAsBackButton(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: staffDetails?.school_name ?? ""
            )
        titleText.addDoneButton()
        discriptionsTextFild.addDoneButton()
        numberOfQuestionText.addDoneButton()
        
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        nextBtn.layer.cornerRadius = 10
        discriptionsTextFild.layer.cornerRadius = 10
        
        checkBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkboxAct)))
        checkBox.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func checkboxAct(){
        
        IsChecked.toggle()
        if IsChecked {
            checkBoxImage.image = UIImage(systemName: "checkmark.circle.fill")
        }else{
            checkBoxImage.image = UIImage(systemName: "circle")
        }
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
            "no_of_question" : Int(numberOfQuestionText.text ?? "0") ?? 0,
            "level": 1,
            "level_flag" : false
        ]
        
//        let vc = QuizSubmissionVc(nibName: nil, bundle: nil)
        let vc = RecipientVc(nibName: nil, bundle: nil)
        vc.ScreenType = Menu_id.quiz
        vc.Common_request_params = params
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)

        
    }
   

}
