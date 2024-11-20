//
//  SenderAssignmentViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/18/24.
//

import UIKit

@available(iOS 14.0, *)
class SenderAssignmentViewController: UIViewController {
    
    
    @IBOutlet weak var textBtn: UIButton!
    
    
    @IBOutlet weak var pdfBtn: UIButton!
    
    @IBOutlet weak var imageBtn: UIButton!
    
    @IBOutlet weak var viewLBl: UILabel!
    @IBOutlet weak var ViewSeg: UIView!
    @IBOutlet weak var headingLBl: UILabel!
    
    @IBOutlet weak var createLbl: UILabel!
    
    @IBOutlet weak var createView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    @IBAction func textBtnAction(_ sender: UIButton) {
        let vc = SenderAssignmentTextViewController(nibName: nil, bundle: nil)
        vc.selectedShow = "Text"
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    

    @IBAction func imageBtnAction(_ sender: UIButton) {
        let vc = SenderAssignmentTextViewController(nibName: nil, bundle: nil)
        vc.selectedShow = "Image"
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func pdfBtnAction(_ sender: UIButton) {
        let vc = SenderAssignmentTextViewController(nibName: nil, bundle: nil)
        vc.selectedShow = "Pdf"
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}
