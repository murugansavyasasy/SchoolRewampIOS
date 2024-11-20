//
//  ImagePdfVC.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

class ImagePdfVC: UIViewController {

    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    
    var data = [
        Video(name: "Introduction to Swift4rt4jkrtrbktuerbtttbgkejbtgetbgkebkgbetbgketbgbestgkbetskgkje", url: "https://www.w3schools.com/tags/mov_bbb.mp4", description: "A beginner's guide to Swift programming language. A beginner's guide to Swift programming language. A beginner's guide to Swift programming language.A beginner's guide to Swift programming language.A beginner's guide to Swift programming languagejfknevjfnjkvknernfvnrjaekfnjkafkjnjkafjkjkafnakfkjsfnjnksfkjlglsfnjklsfnkjksfnnsfnjksfjnkvsjkfnvjklnsfnvfndjknfjlkglnsfklgnsfnkjkjfnkjnfjkglnksfjkjlsfnkjnsfkjnksnfknkfsnkjlsfnjkasnfkjnafsnkjfsankjafsnkjnfkjsnnfsnsfnnfasnnlaf", readed: false, hasAnimated: true, img: nil),
        Video(name: "Advanced iOS Animations", url: "https://videos.pexels.com/video-files/3205789/3205789-hd_1080_1920_25fps.mp4", description: "Learn how to implement complex animations in iOS.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Swift UI Basics", url: "https://videos.pexels.com/video-files/5512609/5512609-hd_1080_1920_25fps.mp4", description: "Introduction to building user interfaces with Swift UI.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Networking in iOS", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", description: "Explore how to make network requests in iOS apps.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Data Persistence", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", description: "Techniques for saving data locally in an iOS app.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Debugging in Xcode", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", description: "Tips and tricks for efficient debugging in Xcode.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Publishing to App Store", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", description: "Step-by-step guide to publishing an app on the App Store.", readed: false,hasAnimated: true, img: nil)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        CellRegistre()
    }


    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func CellRegistre(){
        tv.register(UINib(nibName: CellConfingName.ImagePdfTv, bundle: nil), forCellReuseIdentifier: CellConfingName.ImagePdfTv) //
        tv.dataSource = self
        tv.delegate = self
    }
   

}

extension ImagePdfVC : UITableViewDelegate,UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ImagePdfTv, for: indexPath) as! ImagePdfTv
        
       
        cell.DescriptionLbl.text = data[indexPath.row].description
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  UITableView.automaticDimension
        
        
    }
    
    
    
    
}
