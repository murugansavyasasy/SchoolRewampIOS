//
//  SenderSideImagePdfViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/13/24.
//

import UIKit
import PhotosUI

import AWSS3
@available(iOS 14.0, *)
class SenderSideImagePdfViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate {
    //, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var stdSecBtn: UIButton!
    
    @IBOutlet weak var groupBtn: UIButton!
    
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var uploadAttacLbl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var staffSideOverAllView: UIView!
    @IBOutlet weak var staffSideView: UIView!
    
    @IBOutlet weak var schoolListTv: UITableView!
    
    @IBOutlet weak var sendingView: UIView!
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imgPdCollectionView: UICollectionView!
    
    @IBOutlet weak var secStudBtn: UIButton!
    
    @IBOutlet weak var imgPdfSelectView: RectangularDashedView!
    
    var selectedImages: [UIImage] = []
    var getType = "Principal"
    var imageStr : [String] = []
    
    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
    var totalImageCount = 0
    var currentImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    let photoPickManager = PhotoPickerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        stdSecBtn.setTitle(CommonStringFile.Standardorsection.translated(), for: .normal)
        secStudBtn.setTitle(CommonStringFile.Sectionorstudent.translated(), for: .normal)
        groupBtn.setTitle(CommonStringFile.Groups.translated(), for: .normal)
        
        
        uploadAttacLbl.text = CommonStringFile.UploadAttachment.translated()
        titleLbl.text = CommonStringFile.UploadImagepdf.translated()
        descTextField.placeholder = CommonStringFile.Description.translated()
        imgPdCollectionView.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        
        
        let selectedAlertGesture = UITapGestureRecognizer(target: self, action: #selector(presentSelectionAlert))
        imgPdfSelectView.addGestureRecognizer(selectedAlertGesture)
        
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backView.addGestureRecognizer(backGesture)
        
        staffSideView.isHidden = true
        schoolListTv.isHidden = true
        staffSideOverAllView.isHidden = true
        sendingView.isHidden = true
        
        if getType == "Principal" || getType == "Group" {
            schoolListTv.isHidden = false
            sendingView.isHidden = false
            staffSideView.isHidden = true
            staffSideOverAllView.isHidden = true
        }else {
            schoolListTv.isHidden = true
            sendingView.isHidden = false
            staffSideOverAllView.isHidden = false
            staffSideView.isHidden = false
            
        }
        imgPdCollectionView.delegate = self
        imgPdCollectionView.dataSource = self

        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            // handle camera image
            selectedImages.append(image)
            imgPdCollectionView.reloadData()
        }

        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            selectedImages.append(contentsOf: images)
            imgPdCollectionView.reloadData()
            // handle gallery images
        }
    }
    
    @IBAction func backAction() {
        dismiss(animated: true)
    }
    
    
    @IBAction func presentSelectionAlert() {
        let alertController = UIAlertController(title:AlertstringFile.Select, message: AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
        
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
        
        // PDF option
        let pdfAction = UIAlertAction(title: AlertstringFile.PDF, style: .default) { [self] _ in
            
            PhotoPickerManager.shared.presentPicker(ofType: .pdf, from: self)
        }
        alertController.addAction(pdfAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: AlertstringFile.Cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    //    MARK: Handle Select Camera,Pdf,Image
    @IBAction func openCamera() {
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
    }
    
    
    // Handle the image once it has been captured
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.selectedImages.append(image)
        } else if let image = info[.originalImage] as? UIImage {
            self.selectedImages.append(image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Handle cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //    MARK: Button Action
    @IBAction func toStaffBtnAction(_ sender: UIButton) {
        
    }
    
    @IBAction func toStdSecBtnAction(_ sender: UIButton) {
    }
    
    
    @IBAction func toSecStudBtnAction(_ sender: UIButton) {
    }
    
}

@available(iOS 14.0, *)
extension SenderSideImagePdfViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func selectImages() {
        PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5), from: self)
    }
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("selectedImagescount",selectedImages.count)
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
        cell.imageViews.image = selectedImages[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Delete the selected image
        selectedImages.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
}

@available(iOS 14.0, *)
extension SenderSideImagePdfViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
        return CGSize(width: width, height: width)
    }
    
}
