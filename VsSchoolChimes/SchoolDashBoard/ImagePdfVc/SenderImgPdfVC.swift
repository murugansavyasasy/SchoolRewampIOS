//
//  SenderImgPdfVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 02/12/24.
//

import UIKit

@available(iOS 14.0, *)
class SenderImgPdfVC: UIViewController, DeleteImge {
    
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
            selectedImages.append(ImageName.pdf!)
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
        
        let alertController = UIAlertController(title: AlertstringFile.Select, message:AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
        //
        // Camera option
        let cameraAction = UIAlertAction(title: AlertstringFile.Camera, style: .default) { [self] _ in
            openCamera()
        }
        alertController.addAction(cameraAction)
        
        // Gallery option
        let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
            selectImages()
        }
        alertController.addAction(galleryAction)
        
        let pdfAction = UIAlertAction(title: AlertstringFile.PDF, style: .default) { [self] _ in
            selectPDF()
        }
        alertController.addAction(pdfAction)
        
        let cancelAction = UIAlertAction(title: AlertstringFile.Cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func selectImages() {
        if selectedImages.count != 5{
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5 - selectedImages.count )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func openCamera(){
        if selectedImages.count != 5{
            photoPickManager.openCamera(from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
        
    }
    func selectPDF() {
        photoPickManager.pickPDF(from: self)
        
    }
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        UploadView.imageCollectionview.reloadData()
    }
    
    @IBAction func SelectBtnAct(_ sender: Any) {
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}

@available(iOS 14.0, *)
extension SenderImgPdfVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = UploadView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = UploadView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
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
            let alertController = UIAlertController(title: AlertstringFile.Select, message: AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: AlertstringFile.Camera, style: .default) { [self] _ in
                openCamera()
            }
            alertController.addAction(cameraAction)
            
            // Gallery option
            let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
                //
                selectImages()
                //
            }
            alertController.addAction(galleryAction)
            
            //             PDF option
            let pdfAction = UIAlertAction(title: AlertstringFile.PDF, style: .default) { [self] _ in
                
                //                selectPDF()
            }
            alertController.addAction(pdfAction)
            
            // Cancel action
            let cancelAction = UIAlertAction(title: AlertstringFile.Cancel, style: .cancel, handler: nil)
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



