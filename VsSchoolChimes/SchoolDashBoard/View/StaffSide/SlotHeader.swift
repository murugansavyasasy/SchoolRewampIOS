//
//  SlotHeader.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 19/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class SlotHeader: UITableViewHeaderFooterView, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   
    
    
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dateLabl: UILabel!
  
  
    @IBOutlet weak var cv: UICollectionView!
    
    
    let cvRowIdentifier = "SlotsCollectionViewCell"
  
//
//    var stdSecDetails: [sectionDetails] = [] {
//           didSet {
//               
//               
//               cv.reloadData()
//           }
//       }
//       
       override func awakeFromNib() {
           super.awakeFromNib()
      
          cv.register(UINib(nibName: cvRowIdentifier, bundle: nil), forCellWithReuseIdentifier: cvRowIdentifier)
           cv.dataSource = self
           cv.delegate = self
       }
      
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cvRowIdentifier, for: indexPath) as! SlotsCollectionViewCell
        print("SlotcellForItemAt")
        
//        let data : sectionDetails = stdSecDetails[indexPath.row]
//        cell.sectionFullView.backgroundColor = UIColor(named: "AppDark")
//        cell.sectionLbl.textColor = .white
//        cell.sectionLbl.text = data.class_name + " - " + data.section_name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: 50) // Adjust item size as needed
        }
    
    func adjustCollectionViewHeight(for itemCount: Int) {
        var height: CGFloat = 55
        if itemCount > 3 {
            let extraRows = (itemCount - 1) / 3
            height += CGFloat(extraRows) * 50
        }
        cvHeight.constant = height
        cv.layoutIfNeeded()
    }
    
   }
