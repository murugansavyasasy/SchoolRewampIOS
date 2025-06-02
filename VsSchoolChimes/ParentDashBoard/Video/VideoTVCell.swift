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

    @IBOutlet weak var playerview: UIView!
    @IBOutlet weak var descriptContent: UILabel!
    @IBOutlet weak var Sentbtn: UIButton!
    @IBOutlet weak var Unreadview: UIView!
    @IBOutlet weak var OuterView: AnimatView!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var videoName: UILabel!
    @IBOutlet weak var newImg: UIImageView!
    @IBOutlet weak var thumimg: UIImageView!
    @IBOutlet weak var videoloadview: WKWebView!
    @IBOutlet weak var playbtl: UIButton!
    
    var sharedelegate:shareDelegate?
    var isDescriptionExpanded = false
    var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var isPlaying = false
    var url:String?
    let YOUR_VIMEO_TOKEN = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set up shadowView for shadow
        
        confic(url ?? "")
        datelbl.setFont(style: .body, size: FontSize.BodySize)
        videoName.setFont(style: .title, size: FontSize.TitleSize)
        descriptContent.setFont(style: .body, size: FontSize.BodySize)
        
//        hiddenui(true)
        animationview()
        Unreadview.isHidden = true
        OuterView.layer.shadowColor = UIColor.black.cgColor
        OuterView.layer.shadowOffset = CGSize(width: 0, height: 2)
        OuterView.layer.shadowRadius = 5
        OuterView.layer.shadowOpacity = 0.3
        OuterView.layer.cornerRadius = 20  // Optional for rounded shadow
        Sentbtn.transform = CGAffineTransform(rotationAngle: .pi / 2)
        playbtl.layer.cornerRadius = playbtl.frame.height/2

    }


    func confic(_ url :String){
        if let videoID = extractVimeoID(from: url) {
            
            fetchVimeoVideoFiles(videoID: videoID, accessToken: YOUR_VIMEO_TOKEN) { urls in
                if let urls = urls {
                    if let firstURLString = urls.first, let videoURL = URL(string: firstURLString) {
                        DispatchQueue.main.async {
                            self.setupPlayer(url: videoURL)
                        }
                    }
                } else {
                    print("No video URLs found or error")
                }
            }
        }
    }
    func hiddenui(_ hide:Bool){
        OuterView.changeHeightAndAnimate(40, 110, 21, 30, top: 5)
        descriptContent.isHidden = hide
//        Sentbtn.isHidden = hide
        Unreadview.isHidden = hide
        datelbl.isHidden = hide
        videoName.isHidden = hide
        thumimg.isHidden = !hide
        videoloadview.isHidden = hide
//        playbtl.isHidden = hide
        let color = hide == true ? UIColor.dashBoardClr : UIColor.white
        OuterView.backgroundColor = color
    }
    
    func playvideo(url:String){
        
        if let mediaURL:URL = URL(string: url) {
            let request:URLRequest = URLRequest(url: mediaURL)
            videoloadview.load(request)
        }

    }
    func animationview(){
        OuterView.animateView(enable:false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
            // Code to execute after delay
//            self.OuterView.animateView(enable:false)
            OuterView.parentview.isHidden = true
            hiddenui(false)
        }
        
    }
    func setupPlayer(url: URL) {
         player = AVPlayer(url: url)
         
         if let existingLayer = playerLayer {
             existingLayer.removeFromSuperlayer()
         }
         
         playerLayer = AVPlayerLayer(player: player)
         playerLayer?.frame = playerview.bounds
         playerLayer?.videoGravity = .resizeAspect
         if let pl = playerLayer {
             playerview.layer.addSublayer(pl)
         }
         
         isPlaying = false
        let img = isPlaying ? UIImage(named: "pause-button"):UIImage(named: "play-button")
        playbtl.setImage(img, for: .normal)
     }
    @IBAction func play(_ sender: UIButton) {
        guard let player = player else { return }

//           if isPlaying {
//               player.pause()
//               playbtl.setImage(UIImage(named: "play-button"), for: .normal)
//           } else {
               let vc = getCurrentViewController()
               let playerViewController = AVPlayerViewController()
               playerViewController.player = player
               playerViewController.delegate = self
               vc?.present(playerViewController, animated: true) {
                   player.play()
                   playerViewController.presentationController?.delegate = self
               }
               playbtl.setImage(UIImage(named: "play-button"), for: .normal)
//           }

           isPlaying.toggle()
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
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        isPlaying = false
        playbtl.setImage(UIImage(named: "play-button"), for: .normal)
    }

}
