//
//  ImageTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 22/11/24.
//

import UIKit
import WebKit

class ImageTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var pdfView: WKWebView!
    @IBOutlet weak var imageCollecctView: UICollectionView!
    var type = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        imageCollecctView.delegate = self
        imageCollecctView.dataSource = self
        register()
        txtView.isHidden = true
        imageCollecctView.isHidden = true
        cvHeight.constant = 700
        if let pdfURL = URL(string: "https://icseindia.org/document/sample.pdf") {
              let request = URLRequest(url: pdfURL)
            pdfView.load(request)
            
          } else {
              print("Invalid URL")
          }
    }

    func register(){

        let nib = UINib(nibName: "ImageCViewCell", bundle: nil)
        imageCollecctView.register(nib, forCellWithReuseIdentifier: "ImageCViewCell")

    }

    //MARK: Collectionview Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollecctView.dequeueReusableCell(withReuseIdentifier: "ImageCViewCell", for: indexPath) as! ImageCViewCell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

