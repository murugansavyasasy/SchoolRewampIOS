//
//  AttachmentsVC.swift
//  VsSchoolChimes
//
//  Created by admin on 26/03/25.
//

import UIKit
import WebKit
import SDWebImage
class AttachmentsVC: UIViewController {

    @IBOutlet weak var tv: UITableView!
    var items: [MediaItem] = [
            MediaItem(title: "iOS Development", disreptions: "Learn about iOS app development using Swift.", image: ["https://example.com/ios.jpg"], pdf: [""], video: [""], typeId: 1),
            MediaItem(title: "Swift Programming", disreptions: "Explore the fundamentals of Swift programming.", image: [""], pdf: ["https://example.com/swift.pdf"], video: [""], typeId: 2),
            MediaItem(title: "UIKit vs SwiftUI", disreptions: "Comparison between UIKit and SwiftUI for UI development.", image: ["https://example.com/ui.jpg"], pdf: [""], video: [""], typeId: 1),
            MediaItem(title: "Xcode Tips", disreptions: "Enhance your Xcode productivity with these tips.", image: [""], pdf: ["https://example.com/xcode.pdf"], video: [""], typeId: 2),
            MediaItem(title: "Animations in iOS", disreptions: "Implement smooth animations using Swift.", image: ["https://example.com/animation.jpg"], pdf: [""], video: [""], typeId: 1),
            MediaItem(title: "Networking in Swift", disreptions: "Manage network requests effectively in Swift.", image: [""], pdf: ["https://example.com/networking.pdf"], video: [""], typeId: 2)
        ]
       override func viewDidLoad() {
           super.viewDidLoad()
           
           tv
               .register(
                UINib(nibName: CellConfingName.cell1Tv, bundle: nil),
                forCellReuseIdentifier: CellConfingName.cell1Tv
               )
           
           tv
               .register(
                UINib(nibName: CellConfingName.cell2Tv, bundle: nil),
                forCellReuseIdentifier: CellConfingName.cell2Tv
               )
           tv.dataSource = self
           tv.delegate = self
           tv.reloadData()
       }
       
       
   }

extension AttachmentsVC : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        if item.typeId == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.cell1Tv, for: indexPath) as! cell1Tv
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.cell2Tv, for: indexPath) as! cell2Tv
            
            return cell
        }
        
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}


struct ServerResponse: Codable {
    let status: Bool
    let message: String
    let data: [MediaItem]
}

struct MediaItem: Codable {
    let title: String
    let disreptions: String
    let image: [String]?
    let pdf: [String]?
    let video: [String]?
    let typeId : Int?
}
