//
//  ImageVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll_IMac on 15/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ImageVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    var typesArray: NSMutableArray = []
    
    @IBOutlet  var PopupViewFullImage: UIView!
    
    @IBOutlet  var FullImageView: UIImageView!
    
    var selectedDictionary = NSDictionary()
    
    var strSelectDate = NSString ()
    
    var strApiFrom = NSString()
    
    var hud : MBProgressHUD = MBProgressHUD()
    
    var popupLoading : KLCPopup = KLCPopup()
    
    var popupTextFileDetailView : KLCPopup  = KLCPopup()
    @IBOutlet weak var DateImageLabel: UILabel!
    @IBOutlet weak var ImageSubjectLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "IMAGE" + (strSelectDate as String)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "ImageFileTableViewCell", for: indexPath) as! ImageFileTableViewCell
        
        
        cell1.backgroundColor = UIColor.clear
        
        return cell1
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 420
        }else{
            return 268
        }
    }
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        // let scale = newWidth / image.size.width
        let newHeight = newWidth
        // let newHeight = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = newImage!.jpegData(compressionQuality: 0.5)! as Data
        UIGraphicsEndImageContext()
        
        return  UIImage(data:imageData)!;
    }
    
    
   
    
    
    func ViewFullImage(sender: UIButton)
    {
        let buttonTag = sender.tag
        
        callViewFullImage(buttonTag)
        
        
    }
    
    func SaveImageButton (sender : UIButton)
    {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
        
        let buttonTag = sender.tag
        
        let detailsDictionary = typesArray.object(at: buttonTag) as! NSDictionary
        let urlstring = detailsDictionary["URL"] as! String
        FullImageView.getURLString(urlString: urlstring)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIImageWriteToSavedPhotosAlbum(self.FullImageView.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        hideLoading()
        if error != nil {
            Util.showAlert("", msg: SAVE_ERROR)
            
        } else {
            Util.showAlert("", msg: SAVE_SUCCESS)
            
        }
    }
    func CallReadStatusUpdateApi(_ circularDate : String,_ ID : String, _ type : String) {
        showLoading()
        strApiFrom = "detailssss"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let requestStringer = LIVE_DOMAIN + READ_STATUS_UPDATE
        
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["fn" : "ReadStatusUpdate","ChildID": selectedDictionary.object(forKey: "ChildID") as Any,"SchoolID" : selectedDictionary.object(forKey: "SchoolID") as Any,"Date" : circularDate,"Type" : type,"ID" : ID]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertNSMutableArray(toString: arrUserData)
        
        apiCall.nsurlConnectionFunction(requestString, myString, type)
    }
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        if(csData != nil)
        {
            if((csData?.count)! > 0){
                for var i in 0..<(csData?.count)!
                {
                    
                }
            }
        }
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
        hideLoading()
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: pagename.localizedDescription);
    }
    
    
    // MARK: - Loading
    func showLoading() -> Void {
        //  self.view.window?.userInteractionEnabled = false
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    
    
    @IBAction func closeDetailTextFileView(_ sender: UIButton) {
        
        PopupViewFullImage.isHidden = true
        
        popupTextFileDetailView.dismiss(true)
        
        
        
    }
    
    func callViewFullImage(_ buttonTag : NSInteger) -> Void {
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
        
        let detailsDictionary = typesArray.object(at: buttonTag) as! NSDictionary
        let weburl = detailsDictionary["URL"] as! String
        
        
        
        
        DispatchQueue.global(qos: .background).async {
            
            
            DispatchQueue.main.async {
                self.FullImageView.sd_setImage(with: URL(string: (detailsDictionary["URL"] as? String)!), placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
                
            }
        }
        
        
        ImageSubjectLabel.text = detailsDictionary["Subject"] as? String
        DateImageLabel.text = detailsDictionary["Time"] as? String
        
        
        let dict = NSMutableDictionary(dictionary: detailsDictionary)
        
        let iReadVoice : Int? = Int((detailsDictionary["AppReadStatus"] as? String)!)
        
        if(iReadVoice == 0){
            
            dict["AppReadStatus"] = "1"
            
            typesArray[buttonTag] = dict
            
            CallReadStatusUpdateApi(detailsDictionary.object(forKey: "Date") as! String , detailsDictionary.object(forKey: "ID") as! String , "IMAGE")
            
        }
        
        
        
        PopupViewFullImage.isHidden = false
        
        
    }
    
    
}
