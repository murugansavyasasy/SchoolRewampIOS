//
//  ReportBugVcViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 28/10/24.
//

import UIKit
import PhotosUI
import DropDown

@available(iOS 14.0, *)
class ReportBugVcViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var selectModuleLbl: UILabel!
    @IBOutlet weak var ModuleDropDown: DropDown!
    @IBOutlet weak var textViewStack: UIStackView!
    
   
    @IBOutlet weak var BugsTextview: UITextView!
    
    @IBOutlet weak var uploadView: RectangularDashedView!
    @IBOutlet weak var collectionView: UICollectionView!
        var selectedImages: [UIImage] = []
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        ModuleDropDown.layer.cornerRadius = 10
        ModuleDropDown.layer.borderWidth = 0.5
        ModuleDropDown.layer.borderColor = UIColor.lightGray.cgColor
        
        BugsTextview.delegate = self
        BugsTextview.text = "Enter bugs"
        BugsTextview.textColor = UIColor.lightGray
        
        textViewStack.layer.cornerRadius = 10
        textViewStack.layer.borderWidth = 0.5
        textViewStack.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        collectionView.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(uploadImage) )
        uploadView.addGestureRecognizer(tap)
        
        let dropDown = UITapGestureRecognizer(target: self, action:#selector(ModuleDrop) )
        ModuleDropDown.addGestureRecognizer(dropDown)
        
      
    }

    
    
    @IBAction func ModuleDrop(){
       
     
        var stringArray  = ["Text"
    ,"image","Video"]
        let myArray = stringArray
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = ModuleDropDown //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            selectModuleLbl.text = item
            
        }
            
        
    }
    @IBAction func uploadImage(){
       
        selectImages()
        
    }
    
    

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        BugsTextview.text = nil
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if BugsTextview.text.isEmpty{
            
            BugsTextview.text = "Enter bugs"
            BugsTextview.textColor = UIColor.lightGray
        }
    }
    
}

@available(iOS 14.0, *)
extension ReportBugVcViewController : UICollectionViewDelegate,UICollectionViewDataSource,PHPickerViewControllerDelegate{
    
    
    
    func selectImages() {
           var config = PHPickerConfiguration()
           config.selectionLimit = 5  // Limit selection to 5 images
           config.filter = .images    // Only allow images
           
           let picker = PHPickerViewController(configuration: config)
           picker.delegate = self
           present(picker, animated: true, completion: nil)
       }
       
       // MARK: - PHPickerViewControllerDelegate
       func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           picker.dismiss(animated: true, completion: nil)
           
           for result in results {
               if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                   result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                       guard let self = self, let image = image as? UIImage, error == nil else { return }
                       DispatchQueue.main.async {
                           self.selectedImages.append(image)
                           self.collectionView.reloadData()
                       }
                   }
               }
           }
       }
       
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
       
       @IBAction func addImagesButtonTapped(_ sender: UIButton) {
           selectImages()
       }
    
    
}
@available(iOS 14.0, *)
extension ReportBugVcViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
        return CGSize(width: width, height: width)
    }
    
    
  
}



