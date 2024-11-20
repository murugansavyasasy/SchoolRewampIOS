//
//  SenderAssignmentTextViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/19/24.
//

import UIKit

@available(iOS 14.0, *)
class SenderAssignmentTextViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var chooseImgBtn: UIButton!
    
    @IBOutlet weak var imageSelectView: RectangularDashedView!
    
    @IBOutlet weak var categoryDropDownLbl: UILabel!
    @IBOutlet weak var assignTitleTxtFld: UITextField!
    
    @IBOutlet weak var chooseRecipientsBtn: UIButton!
    @IBOutlet weak var categoryLbl: UILabel!
    
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var subDateLbl: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    var selectedShow = ""
    var selectedImages: [UIImage] = []
    var getType = "Principal"
    var imageStr : [String] = []
    var currentImageCount = 0
    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
    var totalImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    var pdfData : Data? = nil
//    let imagePickerHelper = CameraUtility()
    let photoPickManager = PhotoPickerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if selectedShow == "Text" {
            
        }else if selectedShow == "Image" {
            
        }else if selectedShow == "Pdf" {
            
        }
        
        // Do any additional setup after loading the view.
    }


    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
    }
    
    
    
    @IBAction func chooseImgBtnAction(_ sender: UIButton) {
        presentSelectionAlert()
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
        
      
       
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
   
    func selectImages() {
        photoPickManager.presentPhotoPicker(from: self, selectionLimit: 3)


       }
       
    
    @IBAction func openCamera() {
        // Check if the camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true // Allows editing of the captured image
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Camera is not available, show an alert
            let alert = UIAlertController(title: "Camera Not Available".translated(), message: "This device has no camera.".translated(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".translated(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

      
    

}


@available(iOS 14.0, *)
extension SenderAssignmentTextViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    
    

 
    
    
    
       
       // MARK: - UICollectionView DataSource
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
extension SenderAssignmentTextViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
        return CGSize(width: width, height: width)
    }
    
    
    
    
}
    
    
//@available(iOS 14.0, *)

// MARK: School List Tv Cell
//extension SenderSideImagePdfViewController: UITableViewDelegate,UITableViewDataSource {
//
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            schoolListArr.count
//        }
//
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
//            return cell
//        }
//
//}



