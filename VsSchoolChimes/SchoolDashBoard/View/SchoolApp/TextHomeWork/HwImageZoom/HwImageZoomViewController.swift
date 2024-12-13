//
//  HwImageZoomViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 16/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import UIKit
import WebKit


class HwImageZoomViewController: UIViewController {
    
    @IBOutlet weak var web_view: WKWebView!
    
    @IBOutlet weak var closeView: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    var redirectUrl : UIImage!
    
    var webUrl : String!
    var pinch_gesture = UIPinchGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        web_view.isHidden = true
        print("webUrl",webUrl)
        if webUrl != nil {
            print("webUrl12",webUrl)
            web_view.isHidden = false
            let url = URL (string: "file://" + webUrl)
            //            let url = URL (string: "file:///Users/admin/Library/Developer/CoreSimulator/Devices/CEA7F5AA-10D5-45D8-B722-40CB50029FCA/data/Containers/Shared/AppGroup/0B8421E0-D399-4E79-825F-2BC2EB3BF9A3/File%20Provider%20Storage/Downloads/sample.pdf" )
            let requestObj = URLRequest(url: url!)
            web_view.load(requestObj)
            
        }else {
            print("webUrl145")
            imgView.image = redirectUrl
        }
        
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(cancelVc))
        closeView.addGestureRecognizer(cancelGesture)
        
        
        
        
        
        let pinch_gesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom_img))
            imgView.addGestureRecognizer(pinch_gesture)
        
        
        imgView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func cancelVc(){
        
        
        
        dismiss(animated: true)
    }
    
    
    
    @IBAction func zoom_img( _ sender : UIPinchGestureRecognizer){
            print("img gesture")
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
          sender.scale = 1.0
        
          }
}
