//
//  SenderImgPdfVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 02/12/24.
//

import UIKit

@available(iOS 14.0, *)
class SenderImgPdfVC: UIViewController {
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var UploadView: RectangularDashedView!
    @IBOutlet weak var SelectButton: UIButton!
    
    var selectedImages:[UIImage] = []
    let photoPickManager = PhotoPickerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SelectButton.layer.cornerRadius = 10
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImgPdf))
        UploadView.addGestureRecognizer(tap)
        UploadView.isUserInteractionEnabled = true
        
        
        collectionHeight.constant = 0
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        collectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            
            selectedImages.append(contentsOf: images)
            collectionview.delegate = self
            collectionview.dataSource = self
            collectionview.reloadData()
            
//            for image in images {
//                print("Selected image: \(image)")
//                photoPickManager.uploadAWS(image: image)
//            }
        }
        
    }
    
    @IBAction func uploadImgPdf(){
        
        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
        //
        // Camera option
        let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
//
//                openCamera()
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

           //selectPDF()
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


    @IBAction func SelectBtnAct(_ sender: Any) {
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}

@available(iOS 14.0, *)
extension SenderImgPdfVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selectedImages.count != 0 && selectedImages.count <= 3{
            
            collectionHeight.constant = 120
        }
        
       else if selectedImages.count > 3{
            collectionHeight.constant = 240
        }
       else if selectedImages.count == 0{
            collectionHeight.constant = 0
        }
       
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

               collectionview.deleteItems(at: [indexPath])

           }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want

        return CGSize(width: width, height: width)

    }
           

}



