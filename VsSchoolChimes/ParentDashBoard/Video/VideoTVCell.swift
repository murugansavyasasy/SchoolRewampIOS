//
//  VideoTVCell.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 08/11/24.
//

import UIKit
import WebKit
import AVFoundation
import ImageIO
import AVKit

class VideoTVCell: UITableViewCell, AVPlayerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {

    @IBOutlet weak var dateAndtimeLbl: UILabel!
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var descriptContent: UILabel!
    @IBOutlet weak var Unreadview: UIView!
    @IBOutlet weak var OuterView: UIView!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var newImg: UIImageView!
    @IBOutlet weak var BaseView: UIView!
    var sharedelegate:shareDelegate?
    var isDescriptionExpanded = false
    var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var isPlaying = false
    var url:String?
    var attachment:Attachment?
    var delegate:ReadUpades?
    var file_path: [FilePath]?
//    var onVideoTapped: ((FilePath) -> Void)?
    var onVideoTapped: ((IndexPath) -> Void)?
    private var currentIndexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        datelbl.setFont(style: .body, size: FontSize.BodySize)
        dateAndtimeLbl.setFont(style: .body, size: FontSize.BodySize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        descriptContent.setFont(style: .body, size: FontSize.BodySize)
        Unreadview.isHidden = true
        OuterView.layer.shadowColor = UIColor.black.cgColor
        OuterView.layer.shadowOffset = CGSize(width: 0, height: 2)
        subjectName.isHidden = subjectName.text == ""
        OuterView.layer.shadowRadius = 5
        OuterView.layer.shadowOpacity = 0.3
        OuterView.layer.cornerRadius = 20
        
        let videoTap = (UITapGestureRecognizer(target: self, action: #selector(videoTapped)))
        BaseView.addGestureRecognizer(videoTap)
    }

    
    func configure(indexPath: IndexPath) {
           self.currentIndexPath = indexPath
       }

       @objc func videoTapped() {
           if let indexPath = currentIndexPath {
               onVideoTapped?(indexPath)
           }
       }
   
    func confic(_ url: String) {

        webview.backgroundColor = .black
        webview.isOpaque = false // Allows background to show through
        webview.scrollView.backgroundColor = .black
        let dataTypes = Set([WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeCookies])
         WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast) {
         print("WebView cache cleared")

         // Load video
         if let url = URL(string: url) {
         let request = URLRequest(url: url)
         self.webview.load(request)
         }
         }
        contentView.layoutIfNeeded()
    }

    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    
    @IBAction func sharebtn(_ sender: Any) {
        sharedelegate?.share(url: "https://player.vimeo.com/video/1026769373?h=64e854b656&title=0&byline=0&portrait=0&badge=0&autopause=0&player_id=0&app_id=177030")
    }
}
