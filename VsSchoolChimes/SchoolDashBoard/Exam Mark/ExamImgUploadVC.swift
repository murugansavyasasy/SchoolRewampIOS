//
//  ExamImgUploadVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 25/11/25.
//

import UIKit

class ExamImgUploadVC: UIViewController {
    
    
    @IBOutlet weak var AIview: UIView!
    @IBOutlet weak var manualView: UIView!
    @IBOutlet weak var AiInstructionView: UIView!
    @IBOutlet weak var uploadView: DashedView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var popupBaseVIew: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var ContinueManuallyBtn: UIButton!
    @IBOutlet weak var ContinuewithUploadBtn: UIButton!
    @IBOutlet weak var uploadIconImage: UIImageView!
    @IBOutlet weak var documentIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AIview.layer.cornerRadius = 10
        manualView.layer.cornerRadius = 10
        AiInstructionView.layer.cornerRadius = 10
        uploadView.layer.cornerRadius = 10
        ContinuewithUploadBtn.layer.cornerRadius = 10
        
        AIview.layer.borderWidth = 2
        manualView.layer.borderWidth = 2
        AiInstructionView.layer.borderWidth = 0.5
        
        AIview.layer.borderColor = UIColor.systemGray5.cgColor
        manualView.layer.borderColor = UIColor.systemGray5.cgColor
        AiInstructionView.layer.borderColor = UIColor.staffExamColour.withAlphaComponent(0.7).cgColor
        
        AiInstructionView.backgroundColor = .staffExamColour.withAlphaComponent(0.05)
        documentIcon.tintColor = .systemGray4
        
        AiInstructionView.isHidden = true
        uploadView.isHidden = true
        separatorView.isHidden = true
        ContinuewithUploadBtn.isHidden = true
        
        AIview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AiTap)))
        manualView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ManualTap)))
        uploadView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UploadTap)))
        
        popupBaseVIew.backgroundColor = .black.withAlphaComponent(0.5)
        popupBaseVIew.isHidden = true
        popupView.layer.cornerRadius = 10
        
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.staffExamColour.cgColor
        ContinueManuallyBtn.layer.cornerRadius = 10
        
    }
   
    @IBAction func AiTap(){
        
        AIview.layer.borderColor = UIColor.staffExamColour.cgColor
        manualView.layer.borderColor = UIColor.systemGray5.cgColor
        
        AiInstructionView.isHidden = false
        uploadView.isHidden = false
        separatorView.isHidden = false
        ContinuewithUploadBtn.isHidden = false
        documentIcon.tintColor = .staffExamColour
    }
    
    @IBAction func ManualTap(){
        
        manualView.layer.borderColor = UIColor.staffExamColour.cgColor
        AIview.layer.borderColor = UIColor.systemGray5.cgColor
        
        AiInstructionView.isHidden = true
        uploadView.isHidden = true
        separatorView.isHidden = true
        ContinuewithUploadBtn.isHidden = true
        documentIcon.tintColor = .systemGray4
        
        showPopup()
        
    }
    
    @IBAction func UploadTap(){
        
    }
    
    
    @IBAction func popupCancelAct(_ sender: Any) {
        
        hidePopup()
        manualView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    @IBAction func ContinueManuallyAct(_ sender: Any) {
    }
    
    
    @IBAction func continueWithUploadAct(_ sender: Any) {
        
        let vc = ExamActivitySelectionVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func showPopup() {
        popupBaseVIew.alpha = 0
        popupBaseVIew.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.popupBaseVIew.alpha = 1
        }
    }

    func hidePopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupBaseVIew.alpha = 0
        }) { _ in
            self.popupBaseVIew.isHidden = true
        }
    }
    
}


class DashedView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        addDashBorder()
    }

    private func addDashBorder() {
        layer.sublayers?
            .filter { $0.name == "dashedBorder" }
            .forEach { $0.removeFromSuperlayer() }

        let dash = CAShapeLayer()
        dash.name = "dashedBorder"
        dash.strokeColor = UIColor.gray.cgColor
        dash.lineDashPattern = [4, 2]
        dash.frame = bounds
        dash.fillColor = nil
        dash.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.addSublayer(dash)
    }
}
