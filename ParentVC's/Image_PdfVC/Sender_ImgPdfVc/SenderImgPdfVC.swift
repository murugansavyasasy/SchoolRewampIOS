//
//  SenderImgPdfVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 02/12/24.
//

import UIKit

class SenderImgPdfVC: UIViewController {
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var UploadView: RectangularDashedView!
    @IBOutlet weak var SelectButton: UIButton!
    
    var selectedImages:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImgPdf))
        UploadView.addGestureRecognizer(tap)
        UploadView.isUserInteractionEnabled = true

        collectionview.delegate = self
        collectionview.dataSource = self
        
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        collectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
    }
    
    @IBAction func uploadImgPdf(){
        
        
    }


    @IBAction func SelectBtnAct(_ sender: Any) {
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}

extension SenderImgPdfVC : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selectedImages.count != 0 && selectedImages.count <= 3{
            
            collectionHeight.constant = 120
        }
        
        if selectedImages.count > 3{
            collectionHeight.constant = 240
        }
        if selectedImages.count == 0{
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

               collectionView.deleteItems(at: [indexPath])

           }

           

           

        

    }



