//
//  VoiceVC.swift
//  VoicesnapParentApp
//
//  Created by PREMKUMAR on 16/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceVC: UIViewController,UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,Apidelegate {
    
    var typesArray: NSMutableArray = []
    
    @IBOutlet weak var PlayAudioButton: UIButton!
    
    var strConfId : NSString = ""
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    weak var playbackSlider: UISlider?
    var timer = Timer()
    var time : Float64 = 0;
    var sliderIndex : NSInteger = NSInteger()
    var strFilePath : NSString = ""
    @IBOutlet weak var AudioSlider: UISlider!
    @IBOutlet weak var AudioTimeLabel: UILabel!
    @IBOutlet weak var AudioSubjectLabel: UILabel!
    var popupTextFileDetailView : KLCPopup  = KLCPopup()
    
    @IBOutlet weak var PopupDetailView: UIView!
    
    weak var selectedDictionary = NSDictionary()
    
    var selectedDetailDictionary = NSDictionary()
    
    
    
    var strApiFrom = NSString()
    
    var strSelectDate = NSString ()
    
    var hud : MBProgressHUD = MBProgressHUD()
    
    var popupLoading : KLCPopup = KLCPopup()
    
    var strPlayStatus : NSString = ""
    var strCountryCode = String()
    @IBOutlet weak var TextDateLabel: UILabel!
    
    @IBOutlet weak var TextDetailstableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        TextDateLabel.text = (strSelectDate as String)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "AudioFileTableViewCell", for: indexPath) as! AudioFileTableViewCell
        
        cell1.backgroundColor = UIColor.clear
        
        return cell1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        
        height = 180
        
        return height
        
        
    }
    
    
    // MARK: - Button Action
    @IBAction func actionBack(_ sender: Any)
    {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    func playAudioFileButton (sender : UIButton)
    {
        let buttonTag = sender.tag
        
        
        sliderIndex = buttonTag
        let detailsDictionary = typesArray.object(at:buttonTag) as! NSDictionary
        selectedDetailDictionary = detailsDictionary
        let dict = NSMutableDictionary(dictionary: detailsDictionary)
        
        let iReadVoice : Int? = Int((detailsDictionary["AppReadStatus"] as? String)!)
        
        if(iReadVoice == 0){
            // cell1.NewOrOldLabel.isHidden = false
            
            dict["AppReadStatus"] = "1"
            
            typesArray[buttonTag] = dict
            
            if(Util .isNetworkConnected())
            {
                CallReadStatusUpdateApi(detailsDictionary.object(forKey: "Date") as! String , detailsDictionary.object(forKey: "ID") as! String , "VOICE")
            }
            else
            {
                Util .showAlert("", msg: NETWORK_ERROR)
            }
            
        }
        TextDetailstableview.reloadData()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "VoiceDetailSeg", sender: self)
        }
    }
    
    // MARK: - Api Calling
    func CallReadStatusUpdateApi(_ circularDate : String,_ ID : String, _ type : String) {
        showLoading()
        strApiFrom = "detailssss"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["fn" : "ReadStatusUpdate","ChildID": selectedDictionary!.object(forKey: "ChildID") as Any,"SchoolID" : selectedDictionary!.object(forKey: "SchoolID") as Any,"Date" : circularDate,"Type" : type,"ID" : ID, COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertNSMutableArray(toString: arrUserData)
        
        
        apiCall.nsurlConnectionFunction(requestString, myString, type)
    }
    // MARK: - Api Response
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
        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
    }
    
    // MARK: - Loading
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "VoiceDetailSeg")
        {
            let segueid = segue.destination as! VoiceDetailVC
            segueid.selectedDictionary = selectedDetailDictionary
        }
    }
    
}
