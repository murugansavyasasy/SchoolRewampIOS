//
//  VideoVC.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 08/11/24.
//

import UIKit
import AVFoundation
import AVKit

protocol shareDelegate{
    func share(url:String)
    func playvideo(index:Int)
}
class VideoVC: UIViewController {
    
    
    
    @IBOutlet weak var HeaderLabel: UILabel!
    
    @IBOutlet weak var searchview: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    //    var truncatedDescription = ""
    var image = UIImage()
    var activityIndicator: UIActivityIndicatorView!
    var filteredData: [Video] = []
    var data = [
        Video(name: "Introduction to Swift", url: "https://www.w3schools.com/tags/mov_bbb.mp4", description: "A beginner's guide to Swift programming language. A beginner's guide to Swift programming language. A beginner's guide to Swift programming language.A beginner's guide to Swift programming language.A beginner's guide to Swift programming language.", readed: false, hasAnimated: true, img: nil),
        Video(name: "Advanced iOS Animations", url: "https://videos.pexels.com/video-files/3205789/3205789-hd_1080_1920_25fps.mp4", description: "Learn how to implement complex animations in iOS.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Swift UI Basics", url: "https://videos.pexels.com/video-files/5512609/5512609-hd_1080_1920_25fps.mp4", description: "Introduction to building user interfaces with Swift UI.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Networking in iOS", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", description: "Explore how to make network requests in iOS apps.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Data Persistence", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", description: "Techniques for saving data locally in an iOS app.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Debugging in Xcode", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", description: "Tips and tricks for efficient debugging in Xcode.", readed: false,hasAnimated: true, img: nil),
        Video(name: "Publishing to App Store", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", description: "Step-by-step guide to publishing an app on the App Store.", readed: false,hasAnimated: true, img: nil)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HeaderLabel.text = "Video".translated()
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        filteredData = data
        keyboardDionebtn()
        uiupdate()
        for i in 0..<data.count{
            if let url = URL(string: data[i].url ?? "https://www.w3schools.com/tags/mov_bbb.mp4") {
                getThumbnailImage(forUrl: url) { image in
                    DispatchQueue.main.async { [self] in
                        self.data[i].img = image
                        self.filteredData[i].img = image
                     
                        if i == data.count-1{
//                            self.hideLoading()
                            tableview.reloadData()
                        }
//                        OuterView.animateView(enable: false)
                       
                    }
                }
            }
        }
        
    }
    func uiupdate(){
        searchview.placeholder = "Search Videos..."
        searchview.delegate = self
        searchview.layer.borderWidth = 0
        searchview.backgroundImage = UIImage()
        
        CellRegistre()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCliboard(_:)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center  // Position it at the center of the view
        activityIndicator.hidesWhenStopped = true // Hide it when stopped
        view.addSubview(activityIndicator)
//        self.showLoading()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.hideLoading()  // Hide the loader after 2 seconds
//        }
    }
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        searchview.inputAccessoryView = toolbar
    }
    @objc func doneButtonTapped() {
        view.endEditing(true)  // Dismiss the keyboard
    }
//    func showLoading() {
//        activityIndicator.startAnimating() // Start the loading animation
//    }
//    
//    func hideLoading() {
//        activityIndicator.stopAnimating() // Stop the loading animation
//    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Automatically show the keyboard when search bar is clicked
        searchBar.becomeFirstResponder()
    }
    
    @objc func handleCliboard(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    func CellRegistre(){
        tableview.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}
extension VideoVC:UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, shareDelegate{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
        cell.videoName.text = filteredData[indexPath.row].name
        cell.playbtl.tag = indexPath.row
        cell.descriptContent.attributedText = descript(for: filteredData[indexPath.row].description ?? "", expanded: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
        cell.descriptContent.tag = indexPath.row // Tag the label with the row index
        cell.descriptContent.isUserInteractionEnabled = true
        cell.descriptContent.addGestureRecognizer(tapGesture)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
            cell.Unreadview.isHidden = self.data[indexPath.row].readed
        }
        cell.thumimg.image = filteredData[indexPath.row].img
        cell.sharedelegate = self
        return cell
    }
    
    
    
    
    //MARK: EXPANDABLE LABLE
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = filteredData[indexPath.row].description ?? ""
        
        // Toggle the label between expanded and collapsed states
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        
        // Update the label text with the appropriate "See more" or "See less" state
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        
        // Animate the cell height change
        tableview.beginUpdates()
        tableview.endUpdates()
    }
    
    //MARK: TEXT ADD SEE MORE
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        // If expanded, show full text with "See less"
        if expanded {
            let fullString = fullDescription + " See less"
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See less" text to blue and underline it
            let seeLessRange = (fullString as NSString).range(of: "See less")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeLessRange)
            
            return attributedText
        } else {
            var fullString = ""
            // Otherwise, truncate and show "See more"
            if fullDescription.count > 120{
                let truncatedDescription = String(fullDescription.prefix(100))
                fullString = truncatedDescription + " See more"
            }else{
                fullString = fullDescription
            }
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See more" text to blue and underline it
            let seeMoreRange = (fullString as NSString).range(of: "See more")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeMoreRange)
            //            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: seeMoreRange)
            
            return attributedText
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data
        if searchText.isEmpty {
            filteredData = data
        } else {
            filteredData = data.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Reload the table view
        tableview.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredData = data
        tableview.reloadData()
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func share(url: String) {
        // Convert the string to a URL
        if let videoURL = URL(string: url) {
            // Initialize the activity view controller with the video URL
            let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
            print(videoURL)
            // For iPad: Popover presentation configuration
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = self.view // Set a source view for iPad compatibility
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Center the popover
                popoverController.permittedArrowDirections = []
            }
            UIPasteboard.general.string = url
            // Present the activity view controller
            self.present(activityVC, animated: true, completion: nil)
        } else {
            print("Invalid video URL.")
        }
    }
    
    func playvideo(index:Int){
        
        
        guard let url = URL(string: filteredData[index].url ?? "") else {
            print("Invalid URL")
            return
        }
        
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // Present the AVPlayerViewController
        present(playerViewController, animated: true) {
            player.play()  // Start playback automatically when presented
            self.data[index].readed = true
            self.tableview.reloadData()
        }
    }
    func getThumbnailImage(forUrl url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
        if #available(iOS 16.0, *) {
            assetImageGenerator.generateCGImageAsynchronously(for: time) { cgImage, actualTime, error in
                guard let cgImage = cgImage, error == nil else {
                    print("Error generating thumbnail: \(error?.localizedDescription ?? "Unknown error")")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}
struct Video{
    let name :String
    let url : String?
    let description : String?
    var readed : Bool
    var hasAnimated : Bool
    var img :UIImage?
}
