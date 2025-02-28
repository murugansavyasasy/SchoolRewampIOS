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
    
    
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchview: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    var downloadButton: UIButton?
    var playerViewController: AVPlayerViewController?
    var image = UIImage()
    var activityIndicator: UIActivityIndicatorView!
    var filteredData: [Video] = []
    var data = [
        Video(id: "1", name: "Introduction to Swift", url: "https://www.w3schools.com/tags/mov_bbb.mp4", description: "A beginner's guide to Swift programming language. A beginner's guide to Swift programming language. A beginner's guide to Swift programming language.A beginner's guide to Swift programming language.A beginner's guide to Swift programming language.", readed: false, hasAnimated: true, img: nil),
        Video(id:"2", name: "Advanced iOS Animations", url: "https://videos.pexels.com/video-files/3205789/3205789-hd_1080_1920_25fps.mp4", description: "Learn how to implement complex animations in iOS.", readed: false,hasAnimated: true, img: nil),
        Video(id: "3", name: "Swift UI Basics", url: "https://videos.pexels.com/video-files/5512609/5512609-hd_1080_1920_25fps.mp4", description: "Introduction to building user interfaces with Swift UI.", readed: false,hasAnimated: true, img: nil),
        Video(id: "4", name: "Networking in iOS", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", description: "Explore how to make network requests in iOS apps.", readed: false,hasAnimated: true, img: nil),
        Video(id: "5", name: "Data Persistence", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", description: "Techniques for saving data locally in an iOS app.", readed: false,hasAnimated: true, img: nil),
        Video(id: "6", name: "Debugging in Xcode", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", description: "Tips and tricks for efficient debugging in Xcode.", readed: false,hasAnimated: true, img: nil),
        Video(id: "7", name: "Publishing to App Store", url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", description: "Step-by-step guide to publishing an app on the App Store.", readed: false,hasAnimated: true, img: nil)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
       
        backBtn.setTitle(ReceiverMenuItems.Video.translated(), for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        backBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        backBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        backBtn.imageView?.applyRTLFlip(Language == "ar")
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
                            tableview.reloadData()
                        }
                       
                    }
                }
            }
        }
        scrollToVideo(withId: "4")
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    // Function to scroll to a specific Video by ID
    func scrollToVideo(withId id: String) {
        if let rowIndex = data.firstIndex(where: { $0.id == id }) {
            let indexPath = IndexPath(row: rowIndex, section: 0)
            if tableview.numberOfRows(inSection: 0) > rowIndex {
                tableview.scrollToRow(at: indexPath, at: .top, animated: true)
            } else {
                print("Row index \(rowIndex) is out of bounds for the table view.")
            }
        } else {
            print("Video with ID \(id) not found.")
        }
    }
    func uiupdate(){
        searchview.placeholder = "Search"
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
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Automatically show the keyboard when search bar is clicked
        searchBar.becomeFirstResponder()
    }
    
    @objc func handleCliboard(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    func CellRegistre(){
        tableview.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    

   
}
extension VideoVC:UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, shareDelegate{
    
    func playvideo(index: Int) {
        guard let videoURL = filteredData[index].url, !videoURL.isEmpty,
              let url = URL(string: videoURL) else {
            print("Invalid URL")
            return
        }

        let player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        // Observe UI visibility changes
        playerViewController?.addObserver(self, forKeyPath: "showsPlaybackControls", options: [.new, .initial], context: nil)

        // Present AVPlayerViewController
        if let playerVC = playerViewController {
            present(playerVC, animated: true) {
                player.play()
            }
        }

        // Add the download button
        addDownloadButton(to: playerViewController, videoURL: url)
    }

    func addDownloadButton(to playerViewController: AVPlayerViewController?, videoURL: URL) {
        guard let overlayView = playerViewController?.contentOverlayView else { return }

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: overlayView.frame.width - 50, y: 40, width: 40, height: 40)
        blurView.layer.cornerRadius = 20
        blurView.clipsToBounds = true
        blurView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]

        downloadButton = UIButton(type: .system)
        downloadButton?.setTitle("⬇️", for: .normal)
        downloadButton?.tintColor = .white
        downloadButton?.frame = blurView.bounds
       // downloadButton?.addTarget(self, action: #selector(downloadVideo(_:)), for: .touchUpInside)

        downloadButton?.accessibilityHint = videoURL.absoluteString
        blurView.contentView.addSubview(downloadButton!)
        overlayView.addSubview(blurView)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "showsPlaybackControls",
              let isVisible = change?[.newKey] as? Bool,
              let playerVC = playerViewController else { return }

        DispatchQueue.main.async {
            if isVisible {
                // Add the download button when controls are visible
                self.addDownloadButton(to: playerVC, videoURL: URL(string: self.downloadButton?.accessibilityHint ?? "")!)
            } else {
                // Remove the download button when controls are hidden
                self.downloadButton?.superview?.removeFromSuperview()
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
        cell.datelbl.text = filteredData[indexPath.row].name
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
        
        let playTap = UITapGestureRecognizer(target: self, action: #selector(playVideo))
        cell.playbtl.addGestureRecognizer(playTap)
        cell.playbtl.isUserInteractionEnabled = true
        
        return cell
    }
    
    @IBAction func playVideo(){
        let vc = VideoPlayerVC(nibName: nil, bundle: nil)
        vc.url = URL(string: filteredData[0].url!)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
    
   /* func playvideo(index:Int){
        
        
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
        
        // Add the download button to contentOverlayView
           addDownloadButton(to: playerViewController, videoURL: url)
    } */
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
    let id:String
    let name :String
    let url : String?
    let description : String?
    var readed : Bool
    var hasAnimated : Bool
    var img :UIImage?
}
