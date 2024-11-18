//
//  NoticeBoardVc.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

class NoticeBoardVc: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var UploadView: RectangularDashedView!
    
    @IBOutlet weak var FromDatePicker: UIDatePicker!
    @IBOutlet weak var ToDatePicker: UIDatePicker!
    
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FromDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        FromDatePicker.datePickerMode = .date
        FromDatePicker.minimumDate = Date()
        
        ToDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        ToDatePicker.datePickerMode = .date
        FromDatePicker.minimumDate = Date()
        
       
        SubmitBtn.layer.cornerRadius = 10
        textview.text = "Type content here"
        textview.textColor = .lightGray
        textview.delegate = self
        textfield.delegate = self
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        collectionView.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
       
    }
  
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        if sender == FromDatePicker{
            ToDatePicker.minimumDate = FromDatePicker.date
        }
        self.dismiss(animated: true, completion: nil)
        let selectedDate = sender.date
        print("Selected Date: \(selectedDate)")
      
        }
     
    @IBAction func SubmitAction(_ sender: Any) {
    }
    
    @IBAction func BackClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textfield.text?.isEmpty == false {
            SubmitBtn.backgroundColor = .button
        }
        else{
            SubmitBtn.backgroundColor = .systemGray4
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textview.text.isEmpty == false{
            SubmitBtn.backgroundColor = .button
            textview.textColor = .black
        }
        else{
            SubmitBtn.backgroundColor = .systemGray4
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text = nil
        if textview.text.isEmpty == false{
            SubmitBtn.backgroundColor = .button
            
        }
        else{
            SubmitBtn.backgroundColor = .systemGray4
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
            textview.text = "Type content here"
            textview.textColor = .lightGray
    }
}

extension NoticeBoardVc : UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
        
        return cell
    }
    
    
}
