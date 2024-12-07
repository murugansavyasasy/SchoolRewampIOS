//
//  SenderImgPdfVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 02/12/24.
//

import UIKit

@available(iOS 14.0, *)
class SenderImgPdfVC: UIViewController, DeleteImge {
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        UploadView.imageCollectionview.reloadData()
    }
    
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var UploadView: ImageSelection!
    @IBOutlet weak var SelectButton: UIButton!
    
    var selectedImages:[UIImage] = []
    let photoPickManager = PhotoPickerManager.shared
    var url : URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SelectButton.layer.cornerRadius = 10
        imageSelection()
        UploadView.imageCollectionview.delegate = self
        UploadView.imageCollectionview.dataSource = self
        
    }

    func imageSelection(){
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(contentsOf: images)
            UploadView.imageCollectionview.reloadData()
        }
        photoPickManager.pdfUrl = { [weak self] pdfurl in
            guard let self = self else { return }
            selectedImages.removeAll()
            url = pdfurl.absoluteURL
            selectedImages.append(UIImage(named: "pdf")!)
//            url = URL(string:pdfurl)
//            photoPickManager.uploadPDFFileToAWS(pdfData: pdfData ?? Data())
            UploadView.imageCollectionview.reloadData()
        }
        photoPickManager.onCameraImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(images)
            UploadView.imageCollectionview.reloadData()
        }
    }
    @IBAction func uploadImgPdf(){
        
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

           selectPDF()
        }
        alertController.addAction(pdfAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func selectImages() {
        
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5)


           }
    func openCamera(){
        photoPickManager.openCamera(from: self)


       }
    func selectPDF() {
        photoPickManager.pickPDF(from: self)
        
    }

    @IBAction func SelectBtnAct(_ sender: Any) {
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}

@available(iOS 14.0, *)
extension SenderImgPdfVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        if selectedImages.count != 0 && selectedImages.count <= 3{
//            
//            collectionHeight.constant = 120
//        }
//        
//       else if selectedImages.count > 3{
//            collectionHeight.constant = 240
//        }
//       else if selectedImages.count == 0{
//            collectionHeight.constant = 0
//        }
//       
//               return selectedImages.count
//               
//
//           }
//
//           
//
//           func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
//
//               cell.imageViews.image = selectedImages[indexPath.item]
//
//               return cell
//
//           }
//
//           
//
//           // MARK: - UICollectionView Delegate
//
//           func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//               // Delete the selected image
//
//               selectedImages.remove(at: indexPath.item)
//
//               collectionview.deleteItems(at: [indexPath])
//
//           }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
//
//        return CGSize(width: width, height: width)
//
//    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = UploadView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "AttachmentCVCell", for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = UploadView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "ImageCvCell", for: indexPath) as! ImageCvCell
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            if selectedImages.count > indexPath.item - 1 {
                // Assign the image starting from the second image in the selectedImages array
                cell.imageViews.image = selectedImages[indexPath.item - 1]
            } else {
                cell.imageViews.image = nil
            }
            if selectedImages.count <= 2{
                collectionHeight.constant = 120
            }else{
                collectionHeight.constant = 220
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (UploadView.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0{
            let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
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
                
//                selectPDF()
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
    }

}



