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
    var imges : Attachment?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: "AttachmentViewCell", bundle: nil), forCellWithReuseIdentifier: "AttachmentViewCell")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imges?.file_path?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentViewCell", for: indexPath) as! AttachmentViewCell

        guard let imageItem = imges?.file_path?[indexPath.item],
              let urlString = imageItem.url,
              let url = URL(string: urlString) else {
            return cell
        }

        switch imageItem.type {
        case "DOCUMENT":
            let request = URLRequest(url: url)
            cell.configureAttachment(type: .web(request))

        case "IMAGE":
            // Download image using Kingfisher then pass to configureAttachment
            cell.imageView.kf.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(let value):
                    cell.configureAttachment(type: .image(value.image))
                case .failure:
                    break // Handle failure if needed
                }
            })

        case "VIDEO":
            cell.configureAttachment(type: .video(url))

        default:
            // Fallback to image if type is unknown
            cell.imageView.kf.setImage(with: url, completionHandler: { result in
                switch result {
                case .success(let value):
                    cell.configureAttachment(type: .image(value.image))
                case .failure:
                    break
                }
            })
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

