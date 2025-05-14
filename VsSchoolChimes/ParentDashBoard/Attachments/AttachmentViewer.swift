//
//  AttachmentViewer.swift
//  School Chimes
//
//  Created by Chandhru on 13/05/25.
//

import UIKit
import Kingfisher
class AttachmentViewer: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{

    

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!

    @IBOutlet weak var imageCollectionView: UICollectionView!
    var imges = ["https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//2A451347-56EB-49B1-84E7-DBD25BBDF39B.jpg","https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//2A451347-56EB-49B1-84E7-DBD25BBDF39B.jpg","https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//2A451347-56EB-49B1-84E7-DBD25BBDF39B.jpg"]
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: "AttachmentViewCell", bundle: nil), forCellWithReuseIdentifier: "AttachmentViewCell")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentViewCell", for: indexPath) as! AttachmentViewCell
        let image = imges[indexPath.item]
                if let url = URL(string: image) {
                    cell.imageView.kf.setImage(with: url)
                }
        cell.imageHeight.constant = imageCollectionView.frame.height
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCollectionView.frame.width, height: imageCollectionView.frame.height)
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

