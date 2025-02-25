//
//  ImageDetailVC.swift
//  VoicesnapParentApp
//
//  Created by PREMKUMAR on 16/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ImageDetailVC: UIViewController {
    
    var selectedDictionary = NSDictionary()
    
    @IBOutlet weak var DescriptionConst: NSLayoutConstraint!
    @IBOutlet var TextDateLabel: UILabel!
    @IBOutlet var DescriptionView: UIView!
    
    @IBOutlet var DescriptionLbl: UILabel!
    @IBOutlet var TextTitleLabel: UILabel!
    var hud : MBProgressHUD = MBProgressHUD()
    var DescriptionStr = String()
    var Screenheight = Int()
    var SenderType = NSString ()
    @IBOutlet weak var fullImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        Screenheight = Int(self.view.frame.size.height)
        DescriptionView.isHidden = true
        DescriptionConst.constant = 0
        
        TextDateLabel.text =  String(describing: selectedDictionary["Time"]!)
        TextTitleLabel.text = String(describing: selectedDictionary["Subject"]!)
        if(SenderType == "FromStaff")
        {
            DescriptionStr = ""
        }else{
            
            DescriptionStr  = String(describing: selectedDictionary["Description"]!)
        }
        if(DescriptionStr != "")
        {
            DescriptionView.isHidden = false
            
            
            let Stringlength : Int = DescriptionStr.count
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                
                let MuValue : Int = Stringlength/61
                DescriptionConst.constant  = 40 + (22 * CGFloat(MuValue))
                DescriptionLbl.text = DescriptionStr
                
            }else{
                if(Screenheight > 580)
                {
                    let MuValue : Int = Stringlength/50
                    DescriptionConst.constant  = 30 + ( 18 * CGFloat(MuValue))
                    
                }else{
                    let MuValue : Int = Stringlength/44
                    DescriptionConst.constant  = 30 + ( 18 * CGFloat(MuValue))
                }
                DescriptionLbl.text = DescriptionStr
            }
            
        }
        
        
        
        self.showLoading()
        DispatchQueue.global(qos: .background).async {
            
            // Validate user input
            
            
            SDImageCache.shared().shouldDecompressImages = false
            SDWebImageDownloader.shared().shouldDecompressImages = false
            
            // Go back to the main thread to update the UI
            DispatchQueue.main.async {
                
                self.fullImageView.sd_setImage(
                    with: NSURL(string: (self.selectedDictionary["URL"] as? String)!) as URL?,
                    placeholderImage: UIImage.init(named: "placeHolder.png"),
                    options: SDWebImageOptions.retryFailed,
                    progress: nil,
                    completed: { (image, error, cacheType, imageUrl) in
                        
                        guard let image = image else { return }
                        //  print("Image arrived!")
                        self.hideLoading()
                        
                    }
                )
                
            }
        }
        
    }
    
    @IBAction func actionBack(_ sender: Any)
    {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
    
    
}
