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
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var selectModuleLbl: UILabel!
    @IBOutlet weak var ModuleDropDown: DropDown!
    @IBOutlet weak var textViewStack: UIStackView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var BugsTextview: UITextView!
    @IBOutlet weak var uploadView: RectangularDashedView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var AttachmentView: ImageSelection!
    
    var selectedImages: [UIImage] = []
    var attachments: [AttachmentItem] = []
    let dropDown = DropDown()
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.setTitle(MenuTapbar.shared.Report_a_bug, for: .normal)
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
        sendBtn.setTitleFont(style: .body, size:FontSize.TitleSize)
        
        sendBtn.layer.cornerRadius = 10
        sendBtn.semanticContentAttribute = .forceRightToLeft
        
        selectModuleLbl.setFont(style: .body, size: 14)
        ModuleDropDown.layer.cornerRadius = Colornames.CORadius10
        ModuleDropDown.layer.borderWidth = 0.5
        ModuleDropDown.layer.borderColor = UIColor.lightGray.cgColor
        
        BugsTextview.delegate = self
        BugsTextview.text = "Type content"//CommonStringFile.Enterbugs.translated()
        BugsTextview.textColor = UIColor.lightGray
        BugsTextview.addDoneButton()
        BugsTextview.layer.cornerRadius = Colornames.CORadius10
        BugsTextview.layer.borderWidth = 0.5
        BugsTextview.layer.borderColor = UIColor.lightGray.cgColor
        
        imageSelection()
        
        AttachmentView.imageCollectionview.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        AttachmentView.imageCollectionview.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        
        AttachmentView.imageCollectionview.delegate = self
        AttachmentView.imageCollectionview.dataSource = self
        
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

        let stringArray  = ["Text"
                            ,"image","Video"]
        let myArray = stringArray
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = ModuleDropDown //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            selectModuleLbl.text = item
            
        }
    }
    
    // MARK: - Picker Setup
    func imageSelection() {
        
        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            self.attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            AttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            self.attachments.append(contentsOf: imageItems)
            AttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [weak self] data in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.pdf
            self.attachments.append(
                AttachmentItem(image: nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf)
            )
            AttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onVideoPicked = { [weak self] data in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.VIDEO
            self.attachments.append(
                AttachmentItem(image: nil, imageURL: nil, fileType: CommonStringFile.VIDEO, VideoURl: data)
            )
            AttachmentView.imageCollectionview.reloadData()
        }
    }
    
    @IBAction func uploadImage(){
        selectImages()
    }
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func SendBtnAct(_ sender: Any) {
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if BugsTextview.text == "Type content"/*CommonStringFile.Enterbugs.translated()*/ {
            BugsTextview.text = nil
            BugsTextview.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if BugsTextview.text.isEmpty{
            
            BugsTextview.text = "Type content"//CommonStringFile.Enterbugs.translated()
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
        return selectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
        cell.imageViews.image = selectedImages[indexPath.item - 1]
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0{
            
            
            
        }else {
            
            let attchment = selectedImages[indexPath.item - 1]
            let vc = ImageShowVc(nibName: nil, bundle: nil)
          //  vc.attachment = selectedImages
            vc.scrollIndex = indexPath
            vc.index = indexPath.item - 1
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
//        // Delete the selected image
//        selectedImages.remove(at: indexPath.item)
//        collectionView.deleteItems(at: [indexPath])
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



