//
//  VideoTVCell.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 08/11/24.
//

import UIKit
import WebKit
import AVFoundation

class VideoTVCell: UITableViewCell {

    @IBOutlet weak var descriptContent: UILabel!
    @IBOutlet weak var Sentbtn: UIButton!
    @IBOutlet weak var Unreadview: UIView!
    @IBOutlet weak var OuterView: AnimatView!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var videoName: UILabel!

    @IBOutlet weak var thumimg: UIImageView!
    @IBOutlet weak var videoloadview: WKWebView!
    @IBOutlet weak var playbtl: UIButton!
    
    var sharedelegate:shareDelegate?
    var isDescriptionExpanded = false
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set up shadowView for shadow
        
        datelbl.setFont(style: .title, size: FontSize.TitleSize)
        videoName.setFont(style: .title, size: FontSize.TitleSize)
        descriptContent.setFont(style: .body, size: FontSize.BodySize)
        
        hiddenui(true)
        animationview()
        Unreadview.isHidden = true
        OuterView.layer.shadowColor = UIColor.black.cgColor
        OuterView.layer.shadowOffset = CGSize(width: 0, height: 2)
        OuterView.layer.shadowRadius = 5
        OuterView.layer.shadowOpacity = 0.3
        OuterView.layer.cornerRadius = 20  // Optional for rounded shadow
        Sentbtn.transform = CGAffineTransform(rotationAngle: .pi / 2)
        Unreadview.layer.cornerRadius = Unreadview.frame.size.height/2
        

        playbtl.layer.cornerRadius = playbtl.frame.height/2

    }
    func hiddenui(_ hide:Bool){
        OuterView.changeHeightAndAnimate(40, 110, 21, 30, top: 5)
        descriptContent.isHidden = hide
//        Sentbtn.isHidden = hide
        Unreadview.isHidden = hide
        datelbl.isHidden = hide
        videoName.isHidden = hide
        thumimg.isHidden = hide
        videoloadview.isHidden = hide
//        playbtl.isHidden = hide
        let color = hide == true ? UIColor.dashBoardClr : UIColor.white
        OuterView.backgroundColor = color
    }
    func animationview(){
        OuterView.animateView(enable:true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
            // Code to execute after delay
            self.OuterView.animateView(enable:false)
            OuterView.parentview.isHidden = true
            hiddenui(false)
        }
        
    }
    @IBAction func play(_ sender: UIButton) {
        sharedelegate?.playvideo(index: sender.tag)
        
    }

    
    @IBAction func sharebtn(_ sender: Any) {
        sharedelegate?.share(url: "https://player.vimeo.com/video/1026769373?h=64e854b656&title=0&byline=0&portrait=0&badge=0&autopause=0&player_id=0&app_id=177030")
    }
    
}
