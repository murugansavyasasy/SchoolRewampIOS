//
//  TextHomeWorkVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation
import ImagePicker
import Photos
import MobileCoreServices
import ObjectMapper
//import ALCameraViewController
//import BSImagePicker
import DropDown
import FSCalendar

class TextHomeWorkVC: UIViewController,UITextViewDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,AVAudioRecorderDelegate, AVAudioPlayerDelegate,ImagePickerDelegate, UIDocumentPickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource{
    
    @IBOutlet weak var noRecLbl: UILabel!
    
    @IBOutlet weak var calanderView: UIViewX!
    
    @IBOutlet weak var dateFs: FSCalendar!
    
    @IBOutlet weak var sectionTextfld: UITextField!
    @IBOutlet weak var sectionView: UIView!
    
    @IBOutlet weak var standardView: UIView!
    @IBOutlet weak var standardTextFld: UITextField!
    
    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var homeWorkDefaultLbl: UILabel!
    @IBOutlet weak var homeWorkreportLbl: UILabel!
    
    @IBOutlet weak var Fullview: UIView!
    @IBOutlet weak var homeWorkReportView: UIViewX!
    @IBOutlet weak var homeWorkView: UIViewX!
    @IBOutlet weak var voiceCloseView1: UIView!
    
    @IBOutlet weak var closeVieww1: UIView!
    
    @IBOutlet weak var imgPdfAttachBtn: UIButton!
    
    @IBOutlet weak var imgCount: UILabel!
    
    
    @IBOutlet weak var imgCountTop: NSLayoutConstraint!
    @IBOutlet weak var imgShowTop: NSLayoutConstraint!
    
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgShowView: UIView!
    
    @IBOutlet weak var img2: UIImageView!
    
    @IBOutlet weak var img1: UIImageView!
    
    
    @IBOutlet weak var closeView1: UIView!
    
    @IBOutlet weak var attacTopView1: NSLayoutConstraint!
    
    @IBOutlet weak var imgPdfTop: NSLayoutConstraint!
    @IBOutlet weak var closeView3: UIView!
    @IBOutlet weak var closeView2: UIView!
    
    @IBOutlet weak var attachmentBtn: UIButton!
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var VocieRecordButton: UIButton!
    @IBOutlet weak var AudioSlider: UISlider!
    
    
    @IBOutlet weak var TimeTitleLabel: UILabel!
    //    @IBOutlet weak var PlayVoiceMsgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeCountingLbl: UILabel!
    
    @IBOutlet weak var voiceRecordHeight1: NSLayoutConstraint!
    @IBOutlet weak var overallTimeLbl: UILabel!
    @IBOutlet weak var PlayVocieButton: UIButton!
    
    @IBOutlet weak var voiceRecordViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordingTumeLbl: UILabel!
    @IBOutlet weak var voicePlayView: UIView!
    @IBOutlet weak var voiceRecordView: UIView!
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var TitleText: UITextField!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var ToStandardSection: UIButton!
    @IBOutlet weak var ComposeTitleLabel: UILabel!
    @IBOutlet weak var SubmissionDateLabel: UILabel!
    @IBOutlet weak var SubmissionView: UIView!
    @IBOutlet weak var submissionViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionDateButton: UIButton!
    
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var PopupChooseStandardPickerView: UIView!
    
    @IBOutlet weak var CategorypickerView: UIPickerView!
    @IBOutlet weak var selectCategorylbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var updateCategorylbl: UILabel!
    @IBOutlet weak var lblcatTitle: UILabel!
    
    @IBOutlet weak var catlabelHeight: NSLayoutConstraint!
    @IBOutlet weak var cateforyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cateforybottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var catSelView: UIView!
    
    @IBOutlet weak var calanderHoleView: UIView!
    @IBOutlet weak var attachmentViewTop: NSLayoutConstraint!
    var arrSelectedFilePath : [Any] = []
    
    var moreImagesArray = NSMutableArray()
    var imageLimit = 1
    var strPlayStatus : NSString = ""
    var time : Float64 = 0;
    let picker = UIImagePickerController()
    var timer = Timer()
    var loginAsName = String()
    var strSubmissionDate = String()
    var strFrom = String()
    var SchoolId = String()
    var StaffId = String()
    var MaxTextCount = Int()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UtilObj = UtilClass()
    var textViewPlaceholder = String()
    var strLanguage = String()
    var strCountryName = String()
    let dateView = UIView()
    var assignmentDict = NSMutableDictionary()
    var popupLoading : KLCPopup = KLCPopup()
    var pickerCategoryArray = [String]()
    var selectedCategoryRow = 0;
    var LanguageDict = NSDictionary()
    var TableString = String()
    var SelectedCategoryString = String()
    var selType : String!
    var checkSchoolId : String!
    var urlData: URL?
    var TotaldurationFormat = String()
    var MaxMinutes = Int()
    var MaxSeconds = Int()
    var durationString = String()
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var meterTimer:Timer!
    var HomeWorkSecondStr = Int()
    var audioRecorder    : AVAudioRecorder!
    var languageDictionary = NSDictionary()
    var ApiHomeWorkSecondInt = Int()
    var settings         = [String : Int]()
    var urls : URL!
    var pdfData : NSData? = nil
    
    var  HomeWorkType : String!
    var attachmentSelectType : String!
    var recordingSession : AVAudioSession!
    
    var closeType : String!
    
    var imagePicker = UIImagePickerController()
    
    
    
    let rowIdentifier = "ParentHWImagePdfVoiceTableViewCell"
    
    var filePathListArr : [HomeworkDataDetails] = []
    var filepath : [filePathDataDetails] = []
    var dateText :String!
    
   
    var audioFileURL: String!
    var messageId : String!
    var imgCounts : Int!
//
    var contenttype : String!
    var strCountryCode : String!
    var Standar : [StandardData] = []
    var sectionData : [Section] = []
    var dropDown  = DropDown()
    var StandardIdAryy : [Int] = []
    var staffName : [String] = []
    var standardId : Int!
    var SectiondIdAryy : [Int] = []
    var sectionName : [String] = []
    var SectiondId : Int!
    var dates = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        Fullview.isHidden = true
        
        noRecLbl.isHidden = true
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dMMM,yyy" // You can customize this format
        let formattedDate = dateFormatter.string(from: currentDate)
        dateLbl.text = formattedDate
        
        
    
      
        
        
        let currentDate1 = Date()
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd/MM/yyyy" // You can customize this format
        let formattedDate1 = dateFormatter1.string(from: currentDate1)
        
        DefaultsKeys.SelectedDAte = formattedDate1
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(TextHomeWorkVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String

        print(strCountryName)
        print(strFrom)
        
        img1.layer.cornerRadius  = 20
        img2.layer.cornerRadius  = 20
        
        
        print("appDelegateMaxHWVoiceDurationString",appDelegate.MaxHWVoiceDurationString)
        
        
        imgPdfAttachBtn.isHidden = true
        attachmentViewTop.constant = -190
        imagePicker.delegate = self
        
        voicePlayView.isHidden = true
        voiceRecordView.isHidden = true
        
        pickerCategoryArray = ["GENERAL","CLASS WORK","PROJECT","RESEARCH PAPER"]
        SelectedCategoryString = pickerCategoryArray[selectedCategoryRow]
        updateCategorylbl.text = SelectedCategoryString
        picker.delegate = self
        
        imgShowView.isHidden = true
        
        textviewEnableorDisable()
        
        let close2Ges = UITapGestureRecognizer(target: self, action: #selector(closeVc2))
        closeView2.addGestureRecognizer(close2Ges)
        
        
        
        let close1Ges = UITapGestureRecognizer(target: self, action: #selector(closeVc1))
        closeView1.addGestureRecognizer(close1Ges)
        
        imgCount.isHidden = true
        
        let closeViewGes = UITapGestureRecognizer(target: self, action: #selector(closeViewVc))
        closeVieww1.addGestureRecognizer(closeViewGes)
        
        
        let voiceCloseViewGesture = UITapGestureRecognizer(target: self, action: #selector(VoiceCloseViewVc))
        voiceCloseView1.addGestureRecognizer(voiceCloseViewGesture)
        
          let homeWork = UITapGestureRecognizer(target: self, action: #selector(HomerWorkClick))
        homeWorkView.addGestureRecognizer(homeWork)
        
        
        let HomeWorkReportView = UITapGestureRecognizer(target: self, action: #selector(homeWorkReportClick))
      homeWorkReportView.addGestureRecognizer(HomeWorkReportView)
        
        
        let dateClick = UITapGestureRecognizer(target: self, action: #selector(calanderClikcVC))
        calanderView.addGestureRecognizer(dateClick)
        
        
        tv.register(UINib(nibName: rowIdentifier, bundle: nil), forCellReuseIdentifier: rowIdentifier)
        
        calanderHoleView.isHidden = true
          dateFs.delegate = self
        dateFs.dataSource = self
               
               // Optionally, customize the calendar appearance
//        dateFs.appearance.todayColor = .blue
//        dateFs.appearance.selectionColor = .systemBlue
        
        
        dateFs.appearance.todayColor = .clear          // Change background color of today's date
//        dateFs.appearance.todaySelectionColor = .blue // Change border color of today's date
        dateFs.appearance.titleTodayColor = .blue   // Change the title color of today's date
      
    }
    
    @IBAction func backbtn(_ sender: Any) {
        
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"

        // Convert the input string to a Date object
        if let date = inputFormatter.date(from: dates) {
            // Create a DateFormatter for the desired output format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "ddMMM,yyy" // Desired format: 10Sep,204
            
            // Convert the Date object to the desired string format
            let formattedDate = outputFormatter.string(from: date)
            
            print("Formatted Date: \(formattedDate)")
            
            dateLbl.text = formattedDate
        } else {
            print("Invalid date format")
        }
        
        
        calanderHoleView.isHidden = true
        
    
        homeworkReport()
        
    }
    @IBAction func calanderClikcVC(){
        
        calanderHoleView.isHidden = false
    }
    @objc func datePicked(_ sender: UIDatePicker) {
           let selectedDate = sender.date
//           print("Selected Date: \(selectedDate)")
         
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy" // Set the desired date format

            // Format the selected date
            let formattedDate = dateFormatter.string(from: selectedDate)
            
            // Print or use the formatted date
            print("Selected Date: \(formattedDate)")
        DefaultsKeys.SelectedDAte = formattedDate
        
           self.dismiss(animated: true, completion: nil)
        
       
       }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
            // Set minimum date to 30 days ago
            let currentDate = Date()
            return Calendar.current.date(byAdding: .day, value: -30, to: currentDate) ?? currentDate
        }

        func maximumDate(for calendar: FSCalendar) -> Date {
            // Set maximum date to today
            return Date()
        }

        // MARK: - FSCalendarDelegate

        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            // Allow selection only if the date is within the last 30 days
            let currentDate = Date()
            let minDate = Calendar.current.date(byAdding: .day, value: -30, to: currentDate)!
            return date >= minDate && date <= currentDate
        }
   
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
       
        DefaultsKeys.SelectedDAte = result
        
        dates = result
        
      
       
        
    }
    
    @IBAction func standerBtn(_ sender: Any) {
        
        staffName.removeAll()
        Standar.forEach {(arrType)  in
            StandardIdAryy.append((arrType.standardId))
            staffName.append(arrType.standard)
            
        }

        dropDown.dataSource = staffName//4
        dropDown.anchorView = standardView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
          
            standardId = StandardIdAryy[index]
            
            
            standardTextFld.text = item
            
            
            print("standardId",standardId)
//            AttendaceHistory()
            
        }
        
        
        
        
    }
    
    @IBAction func sectionBtn(_ sender: Any) {
        
        sectionData.removeAll()
        sectionName.removeAll()
        for i in Standar{
            
            
            if i.standard == standardTextFld.text{
                
                
                
                sectionData.append(contentsOf: i.sections)
            }
            
        }
        
        
        sectionData.forEach {(arrType)  in
            SectiondIdAryy.append((arrType.sectionId))
            sectionName.append(arrType.sectionName)
            
        }
//        let myArray = stafflistdata[1].staffName
        
        dropDown.dataSource = sectionName//4
        dropDown.anchorView = sectionView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            SectiondId = SectiondIdAryy[index]
            
            
            sectionTextfld.text = item
            
            homeworkReport()
            print("standardId",SectiondId)
            //            AttendaceHistory()
        }
    }
    
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
          let selectedDate = sender.date
          // Handle the selected date
          print("Selected date: \(selectedDate)")
        
       
      }
    @IBAction func closeViewVc() {
        
        imgShowView.isHidden = true
        
        
    }
    @IBAction func homeWorkReportClick() {
        staffName.removeAll()
        sectionName.removeAll()
        homeWorkReportView.backgroundColor = .systemOrange
        homeWorkreportLbl.textColor = .white
        
        homeWorkView.backgroundColor = .white
        homeWorkDefaultLbl.textColor = .black
        Fullview.isHidden = false
        
       
        getStanderAdSec()
    }
    @IBAction func HomerWorkClick() {
        staffName.removeAll()
        sectionName.removeAll()
        homeWorkView.backgroundColor = .systemOrange
        homeWorkDefaultLbl.textColor = .white
        homeWorkReportView.backgroundColor = .white
        homeWorkreportLbl.textColor = .black
        
        Fullview.isHidden = true
        
    }
    
    @IBAction func VoiceCloseViewVc() {
        
        
        
        voiceRecordView.isHidden = true
        attacTopView1.constant = -60
        
    }
    
    @IBAction func closeVc1() {
        img1.isHidden = true
        moreImagesArray.removeObject(at: 0)
        closeView1.isHidden = true
        attachmentBtn.isHidden = false
        imgShowView.isHidden = true
        imgCount.isHidden = true
        attachmentBtn.isHidden = false
        imgCount.text = "+" + String(moreImagesArray.count)
        
    }
    
    @IBAction func closeVc2() {
        
        
        
        if closeType == "PDF"{
            imgPdfAttachBtn.isHidden = true
            img2.isHidden = true
            closeView2.isHidden = true
            imgShowView.isHidden = true
            attachmentBtn.isHidden = false
            imgCount.isHidden = true
            imgPdfAttachBtn.isHidden = true
            voiceRecordView.isHidden = true
        }else{
            imgCount.isHidden = true
            img2.isHidden = true
            attachmentBtn.isHidden = false
            imgPdfAttachBtn.isHidden = true
            closeView2.isHidden = true
            imgShowView.isHidden = true
            voiceRecordView.isHidden = true
            imgShowView.isHidden = true
            moreImagesArray.removeObject(at: 1)
            imgCount.text =  "+" + String(moreImagesArray.count)
            
            
        }
        
    }
    
    @IBAction func closeVc3() {
        
        moreImagesArray.removeObject(at: 2)
        voiceRecordView.isHidden = true
        attachmentBtn.isHidden = false
        imgShowView.isHidden = true
        imgCount.text =  "+" + String(moreImagesArray.count)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    // MARK CATEGORYVIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (TableString == "category"){
            return pickerCategoryArray.count
        }
        else{
            return pickerCategoryArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (TableString == "category"){
            return pickerCategoryArray[row]
        }
        else{
            return pickerCategoryArray[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (TableString == "category"){
            selectedCategoryRow = row
        }
        
    }
    func actionSelectCategory(){
        TableString = "category"
        selectCategorylbl.text = LanguageDict["select_category"] as? String
        self.CategorypickerView.reloadAllComponents()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChooseStandardPickerView.frame.size.height = 300
            PopupChooseStandardPickerView.frame.size.width = 350
            
        }else{
            PopupChooseStandardPickerView.frame.size.width = self.view.frame.width -  20
        }
        
        
        
        //        G3
        
        PopupChooseStandardPickerView.center = view.center
        PopupChooseStandardPickerView.alpha = 1
        PopupChooseStandardPickerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupChooseStandardPickerView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.PopupChooseStandardPickerView.transform = .identity
        })
        
        print("TEXTHOMEWORKVE")
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
        
        
        var SendTextmessageLength = String()
        if(strFrom == "Assignment"){
            SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
            let currentDate: NSDate = NSDate()
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            strSubmissionDate = dateFormatter.string(from: currentDate as Date)
            
            dateFormatter.dateFormat = "dd MMM yyyy"
            submissionDateButton.setTitle("   " + dateFormatter.string(from: currentDate as Date), for: .normal)
            SubmissionView.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad){
                submissionViewHeight.constant = 50
                submissionViewTopHeight.constant = 8
            }else{
                submissionViewHeight.constant = 40
                submissionViewTopHeight.constant = 4
            }
            
            lblcatTitle.isHidden = false
            
        }else{
            SendTextmessageLength = String(appDelegate.MaxHomeWorkSMSCountString)
            SubmissionView.isHidden = true
            submissionViewHeight.constant = 0
            submissionViewTopHeight.constant = 0
            lblcatTitle.isHidden = true
            catlabelHeight.constant = 0
            cateforyViewHeight.constant = 0
            cateforybottomViewHeight.constant = 0
            catSelView.isHidden = true
            
        }
        
        
        ToStandardSection.layer.cornerRadius = 5
        ToStandardSection.layer.masksToBounds = true
        
        attachmentBtn.layer.cornerRadius = 5
        attachmentBtn.layer.masksToBounds = true
        
        
        
        MaxTextCount = Int(SendTextmessageLength)!
        if(strLanguage == "ar"){
            SendTextMessageLabel.text =  SendTextmessageLength +  "/"
        }else{
            SendTextMessageLabel.text = "/" + SendTextmessageLength
        }
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal")
        {
            
            if checkSchoolId == "1" {
                
                SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
                StaffId = String(describing: SchoolDetailDict["StaffID"]!)
            }else{
                let userDefaults = UserDefaults.standard
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
                
            }
        }else{
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        
        
        
        
        if(self.recordingTumeLbl.text != "00:00"){
            voicePlayView.isHidden = false
        }else{
            voicePlayView.isHidden = true
            
        }
        
        
        AudioSlider.value = 0.0
        audioRecorder = nil
        recordingSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 11.0, *) {
                try recordingSession.setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
            } else {
                try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            }
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
                    }
                }
            }
        } catch {
        }
        
        //Audio Setting
        settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey:2,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
    }
    
    //MARK: TEXTFIELD DELEGATE
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
    
    //MARK: TEXTVIEW DELEGATE
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(TextMessageView.text == textViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        setupTextViewAccessoryView()
        if(TextMessageView.text == textViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        return true
    }
    
    func textviewEnableorDisable(){
        if(TextMessageView.text.count > 0 && TextMessageView.text != textViewPlaceholder )
        {
            
            print("attachmentSelectType1222",attachmentSelectType)
            if (attachmentSelectType == "Image" || attachmentSelectType == "Pdf" ||  attachmentSelectType == "Voice" ){
                attachmentBtn.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                attachmentBtn.isUserInteractionEnabled = true
                ToStandardSection.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
                ToStandardSection.isUserInteractionEnabled = true
                
            }else{
                HomeWorkType = "Text"
            }
        }
        else
        {
            print("attachmentSelectType455",attachmentSelectType)
            if (attachmentSelectType == "Image" || attachmentSelectType == "Pdf" || attachmentSelectType == "Voice"  ){
                attachmentBtn.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
                attachmentBtn.isUserInteractionEnabled = false
                
                ToStandardSection.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
                ToStandardSection.isUserInteractionEnabled = false
            }else{
                HomeWorkType = "Text"
            }
            
            
        }
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        return true
    }
    func textViewDidChange(_ textView: UITextView)
    {
        if(TextMessageView.text.count > 0 )
        {
            ToStandardSection.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            ToStandardSection.isUserInteractionEnabled = true
            
            
            attachmentBtn.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            attachmentBtn.isUserInteractionEnabled = true
            
        }
        else
        
        {
            
        }
        
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentCharacterCount = TextMessageView.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount){
            
            return false
        }
        
        let newLength = currentCharacterCount + text.count - range.length
        
        let length : integer_t
        
        length = integer_t(MaxTextCount) - Int32(newLength)
        
        
        remainingCharactersLabel.text = String (length)
        
        if(length <= 0){
            
            return false
        }
        else if textView.text?.last == " "  && text == " "
        {
            return false
        }
        else {
            let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
            return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
        }
    }
    
    func setupTextViewAccessoryView() {
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(didPressDoneButton))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        toolBar.items = [flexsibleSpace, doneButton]
        TextMessageView.inputAccessoryView = toolBar
    }
    
    @objc func didPressDoneButton(button: UIButton) {
        if( TextMessageView.text == "" ||  TextMessageView.text!.count == 0 || ( TextMessageView.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            TextMessageView.text = textViewPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        
        TextMessageView.resignFirstResponder()
    }
    
    //MARK:BUTTON ACTION
    @IBAction func actionDateButton(_ sender: UIButton) {
        self.dismissKeyboard()
        self.congifureDatePicker()
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionStandardOrSectionSelection(_ sender: UIButton) {
        dismissKeyboard()
        print("strFrom23",strFrom)
        if(strFrom == "Assignment"){
            
            assignmentDict = [
                "AssignmentId" : "0",
                "SchoolID" : SchoolId,
                "AssignmentType": "SMS",
                "Title": self.TitleText.text! ,
                "content": self.TextMessageView.text!,
                
                "category" : selectedCategoryRow + 1,
                "Duration":"0" ,
                "ProcessBy":StaffId,
                "isMultiple":"0" ,
                "processType":"add", "EndDate":strSubmissionDate,
                
            ]
            
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
            AddCV.SchoolDetailDict = SchoolDetailDict
            AddCV.sendAssignmentDict = self.assignmentDict
            AddCV.assignmentType = "StaffAssignment"
            self.present(AddCV, animated: false, completion: nil)
        }else{
            
            
            if checkSchoolId == "1" {
                
                SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
                StaffId = String(describing: SchoolDetailDict["StaffID"]!)
                let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
                
                AddCV.SchoolDetailDict = SchoolDetailDict
                AddCV.SendedScreenNameStr = "TextHomeWork"
                AddCV.HomeTitleText = TitleText.text!
                AddCV.HomeTextViewText = TextMessageView.text!
                AddCV.checkSchoolID = "1"
                AddCV.HomeWorkPdf = HomeWorkType
                AddCV.imagesArray = moreImagesArray
                AddCV.pdfData = pdfData
                print("pdfDatapdfData3456",pdfData)
                AddCV.voiceURl = urlData
                AddCV.HomeWorkType = "1"
                
                self.present(AddCV, animated: false, completion: nil)
            }else{
                let userDefaults = UserDefaults.standard
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
                let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
                
                AddCV.SchoolDetailDict = SchoolDetailDict
                AddCV.SendedScreenNameStr = "TextHomeWork"
                AddCV.HomeTitleText = TitleText.text!
                AddCV.HomeTextViewText = TextMessageView.text!
                AddCV.HomeWorkPdf = HomeWorkType
                
                AddCV.imagesArray = moreImagesArray
                AddCV.pdfData = pdfData
                AddCV.voiceURl = urlData
                AddCV.HomeWorkType = "1"
                print("pdfDatapdfData34565678",pdfData)
                self.present(AddCV, animated: false, completion: nil)
                
            }
            
            
            
        }
    }
    
    @IBAction func actionOk(_ sender: Any) {
        SelectedCategoryString = pickerCategoryArray[selectedCategoryRow]
        updateCategorylbl.text = SelectedCategoryString
        PopupChooseStandardPickerView.alpha = 0
        
    }
    
    @IBAction func actionCancel(_ sender: Any) {
        PopupChooseStandardPickerView.alpha = 0
    }
    
    @IBAction func actionCategoryPopup(_ sender: Any) {
        self.actionSelectCategory()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "SendTextMessageSegue")
        {
            let segueid = segue.destination as! SendTextMessageVC
            segueid.SegueText = TextMessageView.text
            
        }
    }
    func dismissKeyboard()
    {
        TextMessageView.resignFirstResponder()
        TitleText.resignFirstResponder()
    }
    @objc  func catchNotification(notification:Notification) -> Void
    {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    self.loadViewData()
                    
                }
            } catch {
                self.loadViewData()
                
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            TitleText.textAlignment = .right
            TextMessageView.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            TitleText.textAlignment = .left
            TextMessageView.textAlignment = .left
        }
        if(strFrom == "Assignment"){
            ComposeTitleLabel.text  =  LangDict["teacher_txt_composemsg"] as? String
            SubmissionDateLabel.text = LangDict["subission_date"] as? String
            
            TitleText.placeholder  =  LangDict["assignment_title"] as? String
            ToStandardSection.setTitle("Choose Recipients", for: .normal)
            textViewPlaceholder =  LangDict["teacher_txt_typemsg"] as? String ?? "Content?"
        }else{
            ComposeTitleLabel.text  = LangDict["teacher_txt_compose_hwmsg"] as? String
            TitleText.placeholder  = LangDict["teacher_txt_hw_title"] as? String
            if (strCountryName.uppercased() == SELECT_COUNTRY){
                ToStandardSection.setTitle(LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal) // Dhanush Aug-2022
            }
            else{
                ToStandardSection.setTitle(LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            }
            textViewPlaceholder =  LangDict["teacher_txt_typemsg"] as? String ?? "Content?"
        }
        TextMessageView.text = textViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        ToStandardSection.isUserInteractionEnabled = false
        attachmentBtn.isUserInteractionEnabled = false
        
        ToStandardSection.layer.cornerRadius = 5
        ToStandardSection.layer.masksToBounds = true
        
        if(TextMessageView.text != textViewPlaceholder){
            TextMessageView.textColor = UIColor.black
        }
        loadViewData()
        self.recordingTumeLbl.text = "00:00"
    }
    
    
    func loadViewData(){
        HomeWorkSecondStr = Int(appDelegate.MaxHWVoiceDurationString)!
        
        let strSeconRecord : String = languageDictionary["teacher_txt_general_title"] as? String ?? "You can record upto "
        let strSeconds : String = languageDictionary["seconds"] as? String ?? " seconds "
        let strminutes : String = languageDictionary["minutes"] as? String ?? " minutes "
        if(HomeWorkSecondStr < 60)
        {
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiHomeWorkSecondInt = HomeWorkSecondStr
            TimeTitleLabel.text = strSeconRecord + String(ApiHomeWorkSecondInt) + strSeconds
        }else{
            UtilObj.printLogKey(printKey: "", printingValue: HomeWorkSecondStr)
            ApiHomeWorkSecondInt = HomeWorkSecondStr/60
            TimeTitleLabel.text = strSeconRecord + String(ApiHomeWorkSecondInt) + strminutes
        }
        
        UtilObj.printLogKey(printKey: "ApiHomeWorkSecondInt", printingValue: ApiHomeWorkSecondInt)
        self.recordingTumeLbl.text = "00:00"
        voicePlayView.isHidden = true
        self.TitleForStartRecord()
    }
    
    //MARK: DatePicker
    func congifureDatePicker()
    {
        dateView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.actionClosePopup(_:)))
        dateView.addGestureRecognizer(tap)
        
        let doneButton = UIButton()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 250, width: self.dateView.frame.width, height: 50)
        }else
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 235, width: self.dateView.frame.width, height: 35)
        }
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        doneButton.addTarget(self, action: #selector(self.actionDoneButton(_:)), for: .touchUpInside)
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        let timeViews = UIView()
        timeViews.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        timeViews.backgroundColor = UIColor.white
        
        let currentDate: NSDate = NSDate()
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.minimumDate = currentDate as Date
        
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        dateView.addSubview(timeViews)
        
        dateView.addSubview(doneButton)
        dateView.addSubview(datePicker)
        
        
        //        G3
        
        
        dateView.center = view.center
        dateView.alpha = 1
        dateView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(dateView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.dateView.transform = .identity
        })
        
        print("TextHOMEWEorkVc")
        
        
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strSubmissionDate = dateFormatter.string(from: sender.date) as String
        submissionDateButton.setTitle("   " + selectedDate + "   ", for: .normal)
        
    }
    
    @objc func actionDoneButton(_ sender: UIButton)
    {
        dateView.alpha = 0
    }
    @objc func actionClosePopup(_ sender: UIButton)
    {
        popupLoading.dismiss(true)
    }
    
    
    
    @IBAction func attachementBtnAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Attachment", message: "", preferredStyle: .actionSheet)
        
        for i in ["Gallery","Camera","Pdf","Voice"] {
            
            alert.addAction(UIAlertAction(title: i, style: .default, handler: choose_image_handler))
            
        }
        
        
        
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        
        
        
        self.present(alert, animated: true, completion: nil)
        
        
        
        
        
    }
    
    
    
    
    func choose_image_handler(action: UIAlertAction){
        
        
        let alert = UIAlertController(title: "Select Attachment", message: "", preferredStyle: .actionSheet)
        
        print(action.title!)
        
        if ((action.title!.elementsEqual("Gallery"))){
            
            print("camera")
            
            
            
            print("gallery")
            voiceRecordView.isHidden = true
            imgShowView.isHidden = true
            FromLibrary()
            
            
        }else if ((action.title!.elementsEqual("Camera"))){
            
            voiceRecordView.isHidden = true
            imgShowView.isHidden = true
            FromPhoto()
            
        }else if ((action.title!.elementsEqual("Pdf"))){
            
            print("Pdf")
            voiceRecordView.isHidden = true
            imgShowView.isHidden = true
            
            FromPDF()
            
        }else if ((action.title!.elementsEqual("Voice"))){
            
            print("Voice")
            
            voiceAction()
            
        }
        
        
        
        else {
            
            
            
            let optionMenu = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            
            self.present(optionMenu, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    
    
    func choose_image_handlerGallery(action: UIAlertAction){
        
        
        
        print(action.title!)
        
        if ((action.title!.elementsEqual("Camera"))){
            
            print("camera1")
            
            voiceRecordView.isHidden = true
            imgShowView.isHidden = true
            FromPhoto()
            
        }else if ((action.title!.elementsEqual("Gallery"))){
            
            print("gallery")
            voiceRecordView.isHidden = true
            imgShowView.isHidden = true
            FromLibrary()
            //
        }
        else {
            
            
            
            let optionMenu = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            
            self.present(optionMenu, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    
    func FromLibrary(){
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
//        imagePicker.
        self.present(imagePicker, animated: true, completion: nil)
        
        
        
        
        print("1")
        
        
        
        
        
    }
    
    
    func FromPhoto(){
        
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
        }
        else
        {
            
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    func FromPDF(){
        
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func shootFromLibrary(sender: integer_t){
        self.ImagePickerGallery()
    }
    
    
    func noCamera(){
            let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera",preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
      alertVC.addAction(okAction)
      present(alertVC,animated: true,completion: nil)
        
    }
    
    
    func ImagePickerGallery() {
        attacTopView1.constant = 100
        
        
        let config = ImagePickerConfiguration()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = false
        config.allowVideoSelection = false
        
        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.delegate = self
        imagePicker.imageLimit = imageLimit
        present(imagePicker, animated: true, completion: {
            imagePicker.navigationController?.navigationBar.topItem?.title = ""
            imagePicker.navigationController?.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
        })
    }
    
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }
    
    
    func voiceAction() {
        attachmentViewTop.constant = 60
        voicePlayView.isHidden = true
        voiceRecordView.isHidden = false
        imgShowView.isHidden = true
        voiceRecordHeight1.constant = 160
    }
    
    
    
    
    
    @IBAction func playAudioAction(_ sender: Any) {
        
        calucalteDuration()
        
        actionPlayButton()
        audioRecorder = nil
    }
    
    
    
    
    @IBAction func recordAction(_ sender: UIButton) {
        
        
        self.playerDidFinishPlaying()
        
        if audioRecorder == nil {
            
            self.TitleForStopRecord()
            self.VocieRecordButton.setBackgroundImage(UIImage(named:"VoiceRecordSelect"), for: UIControl.State.normal)
            voicePlayView.isHidden = true
            //            PlayVoiceMsgViewHeight.constant = 0
            self.startRecording()
            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                   target:self,
                                                   selector:#selector(self.updateAudioMeter(_:)),
                                                   userInfo:nil,
                                                   repeats:true)
        }else{
            self.funcStopRecording()
        }
    }
    
    
    func funcStopRecording()
    {
        self.TitleForStartRecord()
        
        self.VocieRecordButton.setBackgroundImage(UIImage(named:"VocieRecord"), for: UIControl.State.normal)
        
        self.finishRecording(success: true)
        voicePlayView.isHidden = false
        attachmentViewTop.constant = 30
        voiceRecordHeight1.constant = 260
        calucalteDuration()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            
            self.overallTimeLbl.text = TotaldurationFormat
            self.timeCountingLbl.text = "00.00"
        }
        else
        {
            
            self.overallTimeLbl.text = TotaldurationFormat
            self.timeCountingLbl.text = "00.00"
        }
        
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: self.directoryURL() as! URL,
                                                settings: settings)
            urlData = audioRecorder.url
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        if success {
            audioRecorder = nil
            
        } else {
            audioRecorder = nil
        }
    }
    @objc func updateSlider()
    {
        if self.player!.currentItem?.status == .readyToPlay {
            
            time = CMTimeGetSeconds(self.player!.currentTime())
        }
        
        
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        AudioSlider.maximumValue = Float(seconds)
        AudioSlider.minimumValue = 0.0
        
        AudioSlider.value = Float(time)
        
        if(time > 0){
            let minutes = Int(time) / 60 % 60
            let secondss = Int(time) % 60
            MaxSeconds = secondss
            let durationFormat = String(format:"%02i:%02i", minutes, secondss)
            timeCountingLbl.text = durationFormat
            
        }
        
        if(time == seconds)
        {
            
            timer.invalidate()
            PlayVocieButton.isSelected = false
            AudioSlider.value = 0.0
        }
        
        
    }
    
    func Awws3Voice(URLPath : URL) {
        
        
        
        let audioUrl = URL(fileURLWithPath: URLPath.path)
        
        AWSS3Manager.shared.uploadAudio(audioUrl: audioUrl, progress: { [weak self] (progress) in
            
            
            
            
            
            
            
            print("audioUrl!",audioUrl)
            
            guard let strongSelf = self else { return }
            
            
            
        }) { [weak self] (uploadedFileUrl, error) in
            
            
            guard let strongSelf = self else { return }
            
            if let finalPath = uploadedFileUrl as? String {
                
                self!.urlData = URL(string: finalPath)
                print("finalPath123!",finalPath)
                
                
            } else {
                
                print("\(String(describing: error?.localizedDescription))")
                
            }
            
        }
        
        
    }
    func directoryURL() -> NSURL? {
        print("urlData12",urlData)
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sample.mp4")
        UtilObj.printLogKey(printKey: "Recorded Audio", printingValue: soundURL!)
        
        
        
        return soundURL as NSURL?
    }
    
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        do {
            pdfData = try NSData(contentsOf: url, options: NSData.ReadingOptions())
            print("pdfDatapdfData", pdfData)
        } catch {
            print("set PDF filer error : ", error)
        }
        
        print("urldsss",url)
        
        let fileurl: URL = url as URL
        let filename = url.lastPathComponent
        let fileextension = url.pathExtension
        print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
        
        urls = fileurl
        attachmentSelectType = "Pdf"
        
        var pdfUrl : String!
        pdfUrl =  urls.path
        img1.isHidden = false
        
        img1.image = UIImage(named: "hwPdf")
        img1.isUserInteractionEnabled = true
        
        
        imgShowView.isHidden = false
        imgShowTop.constant = 5
        
        
        var pdfGesture = PdfGes(target: self, action: #selector(PdfClick))
        pdfGesture.url = urls.path
        closeType = "PDF"
        img1.addGestureRecognizer(pdfGesture)
        closeView1.isHidden = false
        closeView2.isHidden = true
        
        
        HomeWorkType  = "Pdf"
        textviewEnableorDisable()
        
        
        
        
        
        
    }
    
    
    
    func actionPlayButton()
    {
        
        playerItem = AVPlayerItem(url: urlData!)
        
        player = AVPlayer(playerItem: playerItem!)
        
        if(strPlayStatus.isEqual(to: "close"))
        {
            AudioSlider.value = 0.0
        }
        
        
        if(PlayVocieButton.isSelected)
        {
            
            PlayVocieButton.isSelected = false
            
            let seconds1 : Int64 = Int64(AudioSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            
            player!.seek(to: targetTime)
            strPlayStatus = "play"
            player?.pause()
        }else{
            
            PlayVocieButton.isSelected = true
            
            let seconds1 : Int64 = Int64(AudioSlider.value)
            let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)
            player!.seek(to: targetTime)
            
            strPlayStatus = "play"
            player?.volume = 1
            player?.play()
            
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        
    }
    
    
    
    func getFileUrl() -> URL
    
    {
        
        let filename = "myRecording.m4a"
        
        let filePath = directoryURL()!.appendingPathComponent(filename)
        
        print("filePath!",filePath)
        
      
        
        let audioUrl = URL(fileURLWithPath: filePath!.path)
        
        AWSS3Manager.shared.uploadAudio(audioUrl: audioUrl, progress: { [weak self] (progress) in
            
            
            
            
            
            
            
            print("audioUrl!",audioUrl)
            
            guard let strongSelf = self else { return }
            
            
            
        }) { [weak self] (uploadedFileUrl, error) in
            
            
            
            guard let strongSelf = self else { return }
            
            if let finalPath = uploadedFileUrl as? String {
                
                self!.urlData = URL(string: finalPath)
                print("finalPath123!",finalPath)
                
                
                
            } else {
                
                print("\(String(describing: error?.localizedDescription))")
                
            }
            
        }
        
        
        
        
        
        
        
        return filePath!
        
    }
    
    
    
    
    
    
    func getDocumentsDirectory() -> URL
    {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sample.mp4")
        
        return soundURL!
    }
    
    
    
    
    @objc func updateAudioMeter(_ timer:Timer) {
        
        if let audioRecorder1 = self.audioRecorder {
            if audioRecorder1.isRecording {
                let min = Int(audioRecorder1.currentTime / 60)
                let sec = Int(audioRecorder1.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d:%02d", min, sec)
                let SecString = sec
                recordingTumeLbl.text = s
                audioRecorder1.updateMeters()
                
                if(HomeWorkSecondStr < 60)
                {
                    if(sec == ApiHomeWorkSecondInt)
                    {
                        self.funcStopRecording()
                    }
                }else{
                    if(min == ApiHomeWorkSecondInt)
                    {
                        self.funcStopRecording()
                    }
                }
                
                
            }
        }
    }
    
    func playbackSliderValueChanged(playbackSlider:UISlider)
    {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime : CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        if(player != nil){
            
            player!.seek(to: targetTime)
            
            
        }else{
            AudioSlider.value = playbackSlider.value
            
            
            
        }
        
        
    }
    
    
    func calucalteDuration() -> Void
    {
        
        print("urlData \(urlData!)")
        attachmentSelectType = "Voice"
        HomeWorkType = "Voice"
        textviewEnableorDisable()
        
        playerItem = AVPlayerItem(url: urlData!)
        let duration : CMTime = playerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        
        AudioSlider.maximumValue = Float(seconds)
        let minutes = Int(seconds) / 60 % 60
        let secondss = Int(seconds) % 60
        durationString = String(format:"%i",Int(seconds))
        if(strLanguage == "ar"){
            TotaldurationFormat = String(format:" %02i:%02i/", minutes, secondss)
        }else{
            TotaldurationFormat = String(format:"/ %02i:%02i", minutes, secondss)
        }
        overallTimeLbl.text = TotaldurationFormat
        
    }
    // MARK: Player close
    
    func playerDidFinishPlaying() {
        
        if(player != nil)
        {
            timer.invalidate()
            player?.pause()
            
            AudioSlider.value = 0.0
            player?.rate = 0.0
            timeCountingLbl.text = "00.00"
            
            PlayVocieButton.isSelected = false
            strPlayStatus = "close"
            player = nil
            player =  AVPlayer.init()
            playerItem?.seek(to: CMTime.zero)
            time = CMTimeGetSeconds(self.player!.currentTime())
            
            
        }
    }
    
    @IBAction func sliderAction(_ sender: Any) {
        playbackSliderValueChanged(playbackSlider: AudioSlider)
        
    }
    
    
    
    
    func TitleForStopRecord()
    {
        let firstword : String =  languageDictionary["teacher_txt_start_record"] as? String ?? "Press the button to"
        let secondWord  : String =  languageDictionary["stop_record"] as? String ?? " STOP RECORD"
        let comboWord = firstword + secondWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        var attrs =  [NSAttributedString.Key : NSObject]()
        var attrfirst =  [NSAttributedString.Key : NSObject]()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {  attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        else
        {   attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
            
        }
        let range = NSString(string: comboWord).range(of: secondWord)
        let range2 = NSString(string: comboWord).range(of: firstword)
        attributedText.addAttributes(attrs, range: range)
        attributedText.addAttributes(attrfirst, range: range2)
        TitleLabel.attributedText = attributedText
        
    }
    
    func TitleForStartRecord()
    {
        let firstword : String =  languageDictionary["teacher_txt_start_record"] as? String ?? "Press the button to"
        let secondWord : String  =  languageDictionary["record"] as? String ?? " RECORD"
        let comboWord = firstword + secondWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        var attrs =  [NSAttributedString.Key : NSObject]()
        var attrfirst =  [NSAttributedString.Key : NSObject]()
        if(UIDevice.current.userInterfaceIdiom == .pad){
            attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24), NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        else
        {   attrfirst = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor:UIColor.black]
            attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
            
        }
        
        let range = NSString(string: comboWord).range(of: secondWord)
        let range2 = NSString(string: comboWord).range(of: firstword)
        attributedText.addAttributes(attrs, range: range)
        attributedText.addAttributes(attrfirst, range: range2)
        TitleLabel.attributedText = attributedText
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        //
        print("chosenImage",  chosenImage)
        imgShowView.isHidden = false
        imgShowTop.constant = 5
        
        imgPdfAttachBtn.isHidden = false
        attachmentSelectType = "Image"
        HomeWorkType = "Image"
        textviewEnableorDisable()
        self.moreImagesArray.add(chosenImage)
        print("moreImagesArray",  moreImagesArray.count)
        imgCount.text = "+" + String(moreImagesArray.count)
        imgCount.isHidden = false
        if moreImagesArray.count == 1 {
            img1.image = moreImagesArray[0] as! UIImage
            img1.isUserInteractionEnabled = true
            
            img2.isHidden = true
            
            let img1Ges = Img1Ges(target: self, action: #selector(imgPdfClick))
            img1Ges.url = moreImagesArray[0] as! UIImage
            img1.addGestureRecognizer(img1Ges)
            closeView1.isHidden = false
            closeView2.isHidden = true
            
        }else   if moreImagesArray.count == 2 {
            img2.isHidden = false
            img1.image = moreImagesArray[0] as! UIImage
            img2.image = moreImagesArray[1] as! UIImage
            closeView1.isHidden = false
            closeView2.isHidden = false
            
            img1.isUserInteractionEnabled = true
            img2.isUserInteractionEnabled = true
            
            let img1Ges = Img1Ges(target: self, action: #selector(imgPdfClick))
            img1Ges.url = moreImagesArray[0] as! UIImage
            img1.addGestureRecognizer(img1Ges)
            
            
            let img2Ges = Img2Ges(target: self, action: #selector(imgPdfClick2))
            img2Ges.url = moreImagesArray[1] as! UIImage
            img2.addGestureRecognizer(img2Ges)
            
        }else   if moreImagesArray.count == 3 {
            img1.image = moreImagesArray[0] as! UIImage
            img2.image = moreImagesArray[1] as! UIImage
            closeView1.isHidden = false
            closeView2.isHidden = false
            
            
            img1.isUserInteractionEnabled = true
            img2.isUserInteractionEnabled = true
            
            let img1Ges = Img1Ges(target: self, action: #selector(imgPdfClick))
            img1Ges.url = moreImagesArray[0] as! UIImage
            img1.addGestureRecognizer(img1Ges)
            
            
            let img2Ges = Img2Ges(target: self, action: #selector(imgPdfClick2))
            img2Ges.url = moreImagesArray[1] as! UIImage
            img2.addGestureRecognizer(img2Ges)
            
            
            
        }
        
        
        
    }
    
    
    
    @IBAction func imagePdfAttachShowAct(_ sender: Any) {
        imgShowView.isHidden = false
        attachmentBtn.isHidden = false
        imgCount.isHidden = false
        
        
    }
    
    
    
    
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("images.countt",images.count)
        for image in images{
            self.moreImagesArray.add(image)
            attachmentSelectType = "Image"
            
            print("22222222222")
            
            
            let x : Int =  self.arrSelectedFilePath.count
            
            
            
            
            HomeWorkType = "Image"
            textviewEnableorDisable()
            print("FilePAthImage",image)
        }
        
        
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func imgPdfClick(ges : Img1Ges){
        let vc  = HwImageZoomViewController(nibName: nil, bundle: nil)
        vc.redirectUrl = ges.url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func imgPdfClick2(ges : Img2Ges){
        let vc  = HwImageZoomViewController(nibName: nil, bundle: nil)
        vc.redirectUrl = ges.url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func imgPdfClick3(ges : Img3Ges){
        let vc  = HwImageZoomViewController(nibName: nil, bundle: nil)
        vc.redirectUrl = ges.url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @IBAction func PdfClick(ges : PdfGes){
        let vc  = HwImageZoomViewController(nibName: nil, bundle: nil)
        vc.webUrl = ges.url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("filePathListArr",filePathListArr.count)
        return filePathListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as! ParentHWImagePdfVoiceTableViewCell
        

       
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .black
        
        let filepathList : HomeworkDataDetails = filePathListArr[indexPath.row]
        
        
        var contetntPath : String!

        print("filepath.count",filepath.count)
        var path1 : String!
        var path2 : String!
        if filepathList.file_path.count >= 0 {
            
          
            for i in  filepathList.file_path {
               
                contenttype = i.type
                contetntPath = i.path

                print("pathpath.type",i.type)
                print("pathpath.path",i.path)
                print("filepathList.filepath.count",filepathList.file_path.count)
                if filepathList.file_path.count > 1 {
                    if contenttype == "IMAGE" {
                        path1 = filepathList.file_path[0].path
                        path2 = filepathList.file_path[1].path
                    }
                }
                
                
                if contenttype == "IMAGE" {
                    path1 = filepathList.file_path[0].path
                }else if contenttype == "PDF" {
                    path1 = filepathList.file_path[0].path
                }
                
            }
            print("pathpath.typecontenttype",contenttype)
           
            if contenttype == "" || contenttype == nil {
                
                print("EMPTYY")
                cell.imgView?.isHidden = true
                cell.image2View?.isHidden = true
                
                cell.image3View?.isHidden = true
                cell.image4View?.isHidden = true
                cell.voiceView?.isHidden = true
                cell.pdfView?.isHidden = true
                cell.webView1?.isHidden = true
                cell.webView2?.isHidden = true
            }
                
                
                if contenttype  == "IMAGE" {
                    print("contetntPath.count",filepathList.file_path.count)
                    imgCounts = filepathList.file_path.count

//
                    if imgCounts == 2 {
                       
                        print("path1",path1)
                        print("path2",path2)


                        
                        DispatchQueue.main.async {
                            
                            cell.img1.sd_setImage(with: URL(string:  path1), placeholderImage: UIImage(named: "placeHolder"))
                            
                            cell.img2.sd_setImage(with: URL(string:  path2), placeholderImage: UIImage(named: "placeHolder"))
                           
                            
                        }
                     
                        cell.imgView?.isHidden = false
                        cell.image2View?.isHidden = false
                        
                        cell.image3View?.isHidden = true
                        cell.image4View?.isHidden = true
                        cell.voiceView?.isHidden = true
                        cell.pdfView?.isHidden = true
                        cell.pdfViewHeight.constant = 0
                        cell.voiceViewHeight.constant = 0
                        
                        cell.imgView.isUserInteractionEnabled = true
                        cell.image2View.isUserInteractionEnabled = true
                        
                        
                        let imageGes = FilePathGess(target: self, action: #selector(pdfImageshowVc))
                        imageGes.url = path1
                        cell.imgView.addGestureRecognizer(imageGes)
                        
                        
                        let imageGes2 = FilePathGess(target: self, action: #selector(pdfImageshowVc))
                        imageGes2.url = path2
                        cell.image2View.addGestureRecognizer(imageGes2)
                        
                    }
                    
                    else if imgCounts == 0 {
                        
                  
                        
                    }
                    
                    
                    else{

                            DispatchQueue.main.async {
                                
                                cell.img1.sd_setImage(with: URL(string:  path1), placeholderImage: UIImage(named: "placeHolder"))
                                
                        }
                        cell.imgView.isUserInteractionEnabled = true
                        cell.imgView?.isHidden = false
                        cell.image2View?.isHidden = true
                        
                        cell.image3View?.isHidden = true
                        cell.image4View?.isHidden = true
                        cell.voiceView?.isHidden = true
                        cell.pdfView?.isHidden = true
                        cell.pdfViewHeight.constant = 0
                        
                        let imageGes = FilePathGess(target: self, action: #selector(pdfImageshowVc))
                        imageGes.url = path1
                        cell.imgView.addGestureRecognizer(imageGes)
                        cell.voiceViewHeight.constant = 0
                    }
                } else if contenttype  == "VOICE" {
                    cell.imgView?.isHidden = true
                    cell.voiceView?.isHidden = false
                    cell.pdfView?.isHidden = true
                    cell.pdfViewHeight.constant = 0
                    cell.audioFileURL = contetntPath
                    cell.imgViewHeight.constant = 0
                }  else if contenttype  == "PDF" {
                    cell.imgView?.isHidden = true
                    cell.voiceView?.isHidden = true
                    cell.pdfView?.isHidden = false
                    cell.imgViewHeight.constant = 0
                    cell.voiceViewHeight.constant = 0
                    
                    
                    let previewGes = FilePathGess(target: self, action: #selector(pdfImageshowVc))
                    previewGes.url = contetntPath
                    cell.previewView.addGestureRecognizer(previewGes)
                    //
                    
                }
            
            
            if filepathList.file_path.count == 0{
                    cell.imgView?.isHidden = true
                    cell.voiceView?.isHidden = true
                    cell.pdfView?.isHidden = true
                    
                    cell.imgViewHeight.constant = 0
                    cell.voiceViewHeight.constant = 0
                    
                }

        }else{
            print("Filepath Is Empty")
        }
      
        print("filepathData",filepath)
        cell.topicLbl.text =  filepathList.homeworktopic
        cell.contentLbl.text =   filepathList.homeworkcontent
        cell.subNameLbl.text = filepathList.subjectname
        cell.fullView.shadowRadius = 0
        cell.fullView.shadowOpacity = 0
        return cell
        
        
        
    }

    
    
    @IBAction  func pdfImageshowVc( ges : FilePathGess) {
        print("test")
      let vc =  HomeWorkPdfImageShomViewController(nibName: nil, bundle: nil)
      vc.modalPresentationStyle = .fullScreen
       
        vc.webUrl = ges.url
//      vc.webUrl = "https://schoolchimes-india.s3.ap-south-1.amazonaws.com/File_20231103100703_IMG20231027111100.jpg"
      present(vc, animated: true)
    }
    
   
    
       

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        
        if contenttype  == "IMAGE" {
            return UITableView.automaticDimension
        }
        else if contenttype  == "VOICE" {
            return UITableView.automaticDimension
        }
        else if contenttype  == "PDF" {
            return UITableView.automaticDimension
        }else{
            return UITableView.automaticDimension
        }
       
    }
   
    
    func homeworkReport(){
        
    
       
      // Assume this is your date (e.g., 2024-10-04)

       
       
        let param : [String : Any] =
        [
           
            "sectionId" : SectiondId!,
            
            "date" : DefaultsKeys.SelectedDAte,
            
            "instituteId" : SchoolId,
            
            "userId" : StaffId
            
        ]
        
        print("paramparamm,nc",param)
        
        HomeWorkRequest.call_request(param: param){ [self]
            (res) in
            
            print("resres",res)
            let getattendace : homeWorkRespo = Mapper<homeWorkRespo>().map(JSONString: res)!
            
            if getattendace.status == 1  {
                
                
                filePathListArr = getattendace.data
                
                for i in getattendace.data {
                   
                    filepath = i.file_path
                }
                
                tv.isHidden = false
                noRecLbl.isHidden = true
                tv.dataSource = self
                tv.delegate = self
                tv.reloadData()
            }else{
                
                
                tv.isHidden = true
                noRecLbl.text = getattendace.message
                
                noRecLbl.isHidden = false
//                getStanderAdSec()
            }
        }
        
    }
    
    
    func getStanderAdSec(){
        
        Standar.removeAll()
      
        let getstanderSection = Sectionresquest()

        getstanderSection.SchoolId = Int(SchoolId)
        getstanderSection.StaffID = Int(StaffId)
        getstanderSection.COUNTRY_CODE = strCountryCode
       

        var getstanderSectionStr = getstanderSection.toJSONString()
        print("punchModalStr",getstanderSection.toJSON())


        standerSecReq.call_request(param: getstanderSectionStr!) {

            [self] (res) in

        
            
            let addLocationResp : [StandardData] = Mapper<StandardData>().mapArray(JSONString: res)!

            Standar.append(contentsOf: addLocationResp)
            
            standardTextFld.text = Standar[0].standard
        
            SectiondId = Standar[0].sections[0].sectionId
//

            sectionTextfld.text = Standar[0].sections[0].sectionName

            homeworkReport()

        }

       
    }
    
}

class PdfGes : UITapGestureRecognizer {
    var url : String!
}

class Img1Ges : UITapGestureRecognizer {
    var url : UIImage!
}


class Img2Ges : UITapGestureRecognizer {
    var url : UIImage!
}


class Img3Ges : UITapGestureRecognizer {
    var url : UIImage!
}

class FilePathGess : UITapGestureRecognizer {
    var url : String!
    var type : String!
    var  btnName : UIButton!
var playbackSlider: UISlider!
}
struct FilePathItems {
    
    var url      : String!
    var type  : String!
}
