//
//  MoreImagesVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MacMini2 on 23/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class MoreImagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var moreImagesTableView: UITableView!
    var moreImagesArray = NSMutableArray()
    
    override func viewDidLoad() {
        self.moreImagesTableView.reloadData()
    }
    
    @IBAction func actionClose() {
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 410
        }else{
            return 375
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreImagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreImagesTVCell", for: indexPath) as! MoreImagesTVCell
        cell.backgroundColor = UIColor.clear
        cell.moreSeletedImage.image = (moreImagesArray[indexPath.row] as! UIImage)
        return cell
    }
    
}
