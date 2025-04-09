//
//  submitVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/12/24.
//

import UIKit

@available(iOS 14.0, *)

class submitVC: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge  {

    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var DescriptionTextview: UITextView!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var AddphotosLbl: UILabel!
    @IBOutlet weak var letterscountLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    
    var url : URL?
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslater()
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        //selectImgPdfview.imageCollectionview.reloadData()
        selectImgPdfview.imageCollectionview.isUserInteractionEnabled = true
        imageSelection()
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    // Action for tap gesture
      @objc func viewTapped(_ sender: UITapGestureRecognizer) {
          if sender.view != outerView {
//              dismiss(animated: true)
          }
      }

    
    
    
    func  StyleAndTranslater(){
        
        DescriptionTextview.layer.cornerRadius = 10
        DescriptionTextview.layer.borderWidth = 1
        DescriptionTextview.layer.borderColor = UIColor.gray.cgColor
        submitBtn.layer.cornerRadius = 10
        //MARK: Button Font Style
        //chooseImgBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        submitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        //MARK: Label Font Style
        AddphotosLbl.setFont(style: .title, size: FontSize.TitleSize)
    
        letterscountLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        HeaderLbl.setFont(style: .header, size: FontSize.HeaderSize)
    }
    
    @IBAction func chooseImgBtnAction(_ sender: UIButton) {
        presentSelectionAlert()
    }

    @IBAction func CancelBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func imageSelection(){
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            // handle camera image
            selectedImages.append(image)
            selectImgPdfview.imageCollectionview.reloadData()
        }

        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            selectedImages.append(contentsOf: images)
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectImgPdfview.imageCollectionview.reloadData()
            // handle gallery images
        }

        PhotoPickerManager.shared.onPdfPicked = { [self] data in
            // handle picked PDF
            selectedImages.removeAll()
            url = data.absoluteURL
            selectedImages.append(ImageName.pdf!)
            selectImgPdfview.imageCollectionview.reloadData()
        }

    }
    
    @IBAction func presentSelectionAlert() {
        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
       
        // Camera option
        let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
            openCamera()
        }
        alertController.addAction(cameraAction)
        
        // Gallery option
        let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
            selectImages()
                   }
        alertController.addAction(galleryAction)
        
        let pdfAction = UIAlertAction(title: "Pdf".translated(), style: .default) { [self] _ in
            selectPdf()
                   }
        alertController.addAction(pdfAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }


    func selectImages() {
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5), from: self)
       }

    func selectPdf() {
        PhotoPickerManager.shared.presentPicker(ofType: .pdf, from: self)
       }
       
 
    //    MARK: Handle Select Camera,Pdf,Image
    @IBAction func openCamera() {
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        
    }


    // Handle the image once it has been captured
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            // Use the captured image
            // For example, display it in an image view or save it
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        } else if let image = info[.originalImage] as? UIImage {
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        }
        dismiss(animated: true, completion: nil)
    }

    // Handle cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

  

}

@available(iOS 14.0, *)
extension  submitVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = selectImgPdfview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = selectImgPdfview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            if selectedImages.count > indexPath.item - 1 {
                // Assign the image starting from the second image in the selectedImages array
                cell.imageViews.image = selectedImages[indexPath.item - 1]
            } else {
                cell.imageViews.image = nil
            }
//            if selectedImages.count <= 2{
//                collectionViewHeight.constant = 120
//            }else{
//                collectionViewHeight.constant = 220
//            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (selectImgPdfview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("entered did select")
        if indexPath.row == 0{
            let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
                //
                openCamera()
            }
            alertController.addAction(cameraAction)
            
            // Gallery option
            let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
                //
                selectImages()
                //
            }
            alertController.addAction(galleryAction)
            
            //             PDF option
            let pdfAction = UIAlertAction(title: "PDF".translated(), style: .default) { [self] _ in
                
                selectPdf()
            }
            alertController.addAction(pdfAction)
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }else{
            if selectedImages.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.selectedFileURL = url
                // Safe unwrapping of imgView before assigning
                vc.img = selectedImages[indexPath.item - 1]
                //
                present(vc, animated: true)
            }
            
        }
        
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            
            controller.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
}
