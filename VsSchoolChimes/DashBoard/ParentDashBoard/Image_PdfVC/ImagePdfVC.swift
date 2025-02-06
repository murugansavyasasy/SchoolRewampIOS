//
//  ImagePdfVC.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

class ImagePdfVC: UIViewController {

    
    @IBOutlet weak var headinglabel: UILabel!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    var data = [
        Video(id: "0", name: "Introduction to Swift4rt4jkrtrbktuerbtttbgkejbtgetbgkebkgbetbgketbgbestgkbetskgkje", url: "https://www.w3schools.com/tags/mov_bbb.mp4", description: "A beginner's guide to Swift programming language. A beginner's guide to Swift programming language. A beginner's guide to Swift programming language.A beginner's guide to Swift programming language.A beginner's guide to Swift programming languagejfknevjfnjkvknernfvnrjaekfnjkafkjnjkafjkjkafnakfkjsfnjnksfkjlglsfnjklsfnkjksfnnsfnjksfjnkvsjkfnvjklnsfnvfndjknfjlkglnsfklgnsfnkjkjfnkjnfjkglnksfjkjlsfnkjnsfkjnksnfknkfsnkjlsfnjkasnfkjnafsnkjfsankjafsnkjnfkjsnnfsnsfnnfasnnlaf", readed: false, hasAnimated: true, img: nil),
        Video(id: "1", name: "Advanced iOS Animations", url: "https://videos.pexels.com/video-files/3205789/3205789-hd_1080_1920_25fps.mp4", description: "Learn how to implement complex animations in iOS.", readed: false,hasAnimated: true, img: nil),
        Video(id: "2", name: "Swift UI Basics", url: "https://videos.pexels.com/video-files/5512609/5512609-hd_1080_1920_25fps.mp4", description: "Introduction to building user interfaces with Swift UI.", readed: false,hasAnimated: true, img: nil),
        Video(id: "3", name: "Networking in iOS", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", description: "Explore how to make network requests in iOS apps.", readed: false,hasAnimated: true, img: nil),
        Video(id: "4", name: "Data Persistence", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", description: "Techniques for saving data locally in an iOS app.", readed: false,hasAnimated: true, img: nil),
        Video(id: "5", name: "Debugging in Xcode", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", description: "Tips and tricks for efficient debugging in Xcode.", readed: false,hasAnimated: true, img: nil),
        Video(id: "6", name: "Publishing to App Store", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", description: "Step-by-step guide to publishing an app on the App Store.", readed: false,hasAnimated: true, img: nil)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        search.placeholder = "Search".translated()
        search.delegate = self
        addDoneButton()
        
        backBtn.setTitle(ReceiverMenuItems.ImagePdf.translated(), for: .normal)
//        headinglabel.text = "Image/Pdf".translated()
        headinglabel.setFont(style: .header, size: FontSize.HeaderSize)
        // Do any additional setup after loading the view.
        
        CellRegistre()
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
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
        cell.DescriptionLbl.attributedText = descript(for: data[indexPath.row].description!, expanded: false)//data[indexPath.row].description
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
        //cell.delegate = self
        cell.DescriptionLbl.tag = indexPath.row // Tag the label with the row index
        cell.DescriptionLbl.isUserInteractionEnabled = true
        cell.DescriptionLbl.addGestureRecognizer(tapGesture)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  UITableView.automaticDimension
        
        
    }
    
    
    //MARK: TEXT ADD SEE MORE
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        // If expanded, show full text with "See less"
        if expanded {
            let fullString = fullDescription + CommonStringFile.seeLess.translated()
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See less" text to blue and underline it
            let seeLessRange = (fullString as NSString).range(of: "See less")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeLessRange)
            
            return attributedText
        } else {
            var fullString = ""
            // Otherwise, truncate and show "See more"
            if fullDescription.count > 120{
                let truncatedDescription = String(fullDescription.prefix(105))
                fullString = truncatedDescription + CommonStringFile.seemore.translated()
            }else{
                fullString = fullDescription
            }
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See more" text to blue and underline it
            let seeMoreRange = (fullString as NSString).range(of: "See more")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeMoreRange)
            return attributedText
        }
    }
    
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = "Annual Day is a special occasion celebrated by schools, colleges, and organizations to mark the completion of another successful year. It is a time for showcasing the talents and achievements of students or members through cultural performances."
        
        // Toggle the label between expanded and collapsed states
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        
        // Update the label text with the appropriate "See more" or "See less" state
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        
        // Animate the cell height change
        tv.beginUpdates()
        tv.endUpdates()
    }
    
}

extension ImagePdfVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        search.resignFirstResponder()
    }
    
    func addDoneButton(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
            
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(DoneBtnAct))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)


        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        search.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        search.resignFirstResponder()
    }

}


