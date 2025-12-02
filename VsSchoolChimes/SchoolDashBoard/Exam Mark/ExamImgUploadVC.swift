//
//  ExamImgUploadVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 25/11/25.
//

import UIKit
import VisionKit

@available(iOS 14.0, *)
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
    
    var attachments: [AttachmentItem] = []
    
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
        
        imageSelection()
        
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
        
        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
        
        // Camera option
        let cameraAction = UIAlertAction(title: CommonStringFile.Camera, style: .default) { [self] _ in
           
            //openCamera()
            openDocumentScanner(from: self)
        }
        alertController.addAction(cameraAction)
        
        // Gallery option
        let galleryAction = UIAlertAction(title: CommonStringFile.Photos, style: .default) { [self] _ in
            selectImages()
            //
        }
        alertController.addAction(galleryAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func selectImages() {
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared
                .presentPicker(
                    ofType: .gallery(selectionLimit: 10 - attachments.count),
                    from: self
                )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
        
    }
    func openCamera(){
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    
    func openDocumentScanner(from viewController: UIViewController) {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        viewController.present(scanner, animated: true)
    }

    
    func imageSelection(){
        
        // handle picked image from camera
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
        }
        
        // handle picked image from gallery
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
        }
        
        // handle picked PDF
        PhotoPickerManager.shared.onFilePicked = { [self] data in
           
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            
            user_inputs.selectedFileType = CommonStringFile.pdf
            
        }
        
        // handle picked video
        PhotoPickerManager.shared.onVideoPicked = { [self] data in
            
            user_inputs.selectedFileType = CommonStringFile.VIDEO
            attachments.append(AttachmentItem(
                image:nil,
                imageURL: nil,
                fileType: CommonStringFile.VIDEO,
                VideoURl: data
            )
            )
        }
    }
    
    
    @IBAction func popupCancelAct(_ sender: Any) {
        
        hidePopup()
        manualView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    @IBAction func ContinueManuallyAct(_ sender: Any) {
        
        let vc = EnterMarkVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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

@available(iOS 14.0, *)
extension ExamImgUploadVC: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        
        var scannedImages: [UIImage] = []
        
        for i in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: i)
            scannedImages.append(image)
        }

        // handle scannedImages here

        controller.dismiss(animated: true)
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFailWithError error: Error) {
        controller.dismiss(animated: true)
        print("Document scan failed: \(error.localizedDescription)")
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
