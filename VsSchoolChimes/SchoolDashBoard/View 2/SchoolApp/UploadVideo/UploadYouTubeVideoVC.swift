//
//  UploadYouTubeVideoVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MacMini2 on 27/06/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//


import UIKit
import ImagePicker
import MobileCoreServices
import AVFoundation
import AVKit

class UploadYouTubeVideoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource,AVPlayerViewControllerDelegate {
    
    @IBOutlet weak var composeVideoLabel: UILabel!
    @IBOutlet weak var ChangeVideoButton: UIButton!
    @IBOutlet weak var ChooseVideoFromGalleryButton: UIButton!
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet var schoolsTableView: UITableView!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    let picker = UIImagePickerController()
    var selectedSchoolDictionary = NSMutableDictionary()
    var selectedSchoolID = NSString()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var videoURL: URL?
    var urlPath : URL!
    var strFrom = String()
    var LanguageDict = NSDictionary()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.initialSetup()
        print("Video1")
    }
    
    func initialSetup(){
        view.isOpaque = false
        ChangeVideoButton.isEnabled = false
        ChangeVideoButton.layer.cornerRadius = 5
        ChangeVideoButton.layer.masksToBounds = true
        picker.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.callSelectedLanguage()
        if(UIDevice.current.userInterfaceIdiom == .pad){
            headerViewHeight.constant = 577
        }else{
            headerViewHeight.constant = 347
        }
        self.sizeHeaderToFit()
    }
    
    func sizeHeaderToFit() {
        enableDisableChangeVideoButton()
        headerView = schoolsTableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        schoolsTableView.tableHeaderView = headerView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        return true
    }
    //MARK: BUTTON ACTION
    
    func enableDisableChangeVideoButton(){
        if(videoURL != nil){
            ChooseVideoFromGalleryButton.isHidden = true
            ChangeVideoButton.isEnabled = true
            ChangeVideoButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            
        }else{
            
            ChooseVideoFromGalleryButton.isHidden = false
            ChangeVideoButton.isEnabled = false
            ChangeVideoButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func actionChooseVideoFromGallery(_ sender: UIButton) {
        self.openImgPicker()
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionChangeVideo(_ sender: UIButton) {
        self.openImgPicker()
    }
    
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 65
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.LoginSchoolDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
        let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
        cell.SchoolNameLbl.text = schoolDict?["SchoolName"] as? String
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
        selectedSchoolID = schoolDict?["SchoolID"] as! NSString
        selectedSchoolDictionary["SchoolID"] = schoolDict?["SchoolID"] as! NSString
        selectedSchoolDictionary["StaffID"] = schoolDict?["StaffID"] as! NSString
        selectedSchoolDictionary["VideoDescription"] = descriptionTextField.text!
        selectedSchoolDictionary["VideoTitle"] = titleTextField.text!
        selectedSchoolDictionary["type"] = 1
        
        if(self.videoURL != nil && descriptionTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 && titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).count > 0){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "PrincipalVideoVCToSelectionSegue", sender: self)
            }
        }else{
            Util.showAlert("", msg: LanguageDict["fill_all_alert"] as? String)
        }
        
    }
    
    //MARK: Video Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        print("videoURL:\(String(describing: videoURL))")
        self.dismiss(animated: true, completion: nil)
        self.PlayVideo()
    }
    
    func PlayVideo(){
        enableDisableChangeVideoButton()
        let player = AVPlayer(url: videoURL!)
        let playerController = AVPlayerViewController()
        playerController.view.frame = self.VideoView.bounds
        playerController.player = player
        self.addChild(playerController)
        self.VideoView.addSubview(playerController.view)
        playerController.didMove(toParent: self)
        
        player.pause()
        
        
    }
    
    
    func openImgPicker() {
        picker.sourceType = .savedPhotosAlbum
        picker.delegate = self
        picker.mediaTypes = ["public.movie"]
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "PrincipalVideoVCToSelectionSegue"){
            let segueid = segue.destination as! PrincipalGroupSelectionVC
            segueid.fromViewController = "SendVideo"
            segueid.SchoolID = selectedSchoolID
            segueid.selectedSchoolDictionary = selectedSchoolDictionary
            segueid.strFrom = strFrom
            segueid.videoURL = self.videoURL
            segueid.vimeoVideoURL =  videoURL as! URL 
            print("segueid.vimeoVideoURL",videoURL)
        }
    }
    
    
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }
            } catch {
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        LanguageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            descriptionTextField.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            descriptionTextField.textAlignment = .left
        }
        composeVideoLabel.text = LangDict["teacher_txt_composeImg"] as? String
        descriptionTextField.placeholder = LangDict["teacher_image_hint_title"] as? String
        titleTextField.placeholder = LangDict["teacher_image_hint_title"] as? String
        ChangeVideoButton.setTitle(LangDict["teacher_txt_chgimg"] as? String, for: .normal)
        ChooseVideoFromGalleryButton.setTitle(LangDict["teacher_txt_chgimg"] as? String, for: .normal)
        
    }
    
}

