//
//  StudentMarkVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 16/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StudentMarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource,Apidelegate {
    @IBOutlet weak var StudentMarkTableView: UITableView!
    @IBOutlet weak var SubjectLbl : UILabel!
    @IBOutlet weak var MarkLbl: UILabel!
    var selectedTermRow = NSMutableArray()
    
    var strApiFrom = String()
    var AlertString = String()
    var ExamIDString = String()
    var ChildIDString = String()
    var SchoolIDString = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var languageDictionary = NSDictionary()
    var checkCount = 0
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ExamDictionary = NSDictionary()
    var arrExamDetail : NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        StudentMarkTableView.contentInset = UIEdgeInsets.zero
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let dicSubj = arrExamDetail.object(at: 0) as? NSDictionary
        let arrSub = dicSubj!.object(forKey: "groups") as? NSArray
        let arrSubs = dicSubj!.object(forKey: "subjects") as? NSArray
        
        return arrSubs!.count + 1 + arrSub!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var iCount = 0
        let dicSubj = arrExamDetail.object(at: 0) as? NSDictionary
        let arrSubs = dicSubj!.object(forKey: "subjects") as? NSArray
        
        let sec = section - (arrSubs!.count + 1)
        
        if(section < arrSubs!.count){
            if( self.selectedTermRow.contains(section)){
                //let arrSub = dicSubj!.object(forKey: "subjects") as? NSArray
                let arrSub = dicSubj!.object(forKey: "subjects") as? NSArray
                let dicsubgrp = arrSub?.object(at: section) as? NSDictionary
                let arrDicgrp = dicsubgrp?.object(forKey: "split") as? NSArray
                if( self.selectedTermRow.contains(section)){
                    iCount = arrDicgrp?.count ?? 0
                }else{
                    iCount =  0
                    
                }
            }else{
                iCount =  0
                
            }
            
            
        }else if(section == arrSubs!.count){
            let arrSub = dicSubj!.object(forKey: "elements") as? NSArray
            iCount = arrSub?.count ?? 0
        }else{
            let arrSub = dicSubj!.object(forKey: "groups") as? NSArray
            let dicsubgrp = arrSub?.object(at: sec) as? NSDictionary
            let arrDicgrp = dicsubgrp?.object(forKey: "subgroups") as? NSArray
            iCount = arrDicgrp?.count ?? 0
            
        }
        return iCount
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            height =  70
            
        }else{
            
            height =  32
            
        }
        return height
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView : UIView = UIView()
        let label : UILabel = UILabel()
        let sectionButton : UIButton = UIButton()
        let radioButton : UIButton = UIButton()
        let dropDownImage : UIImageView = UIImageView()
        let rightLabel : UILabel = UILabel()
        
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            headerView.frame =  CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
            sectionButton.frame =  CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
            label.frame = CGRect(x: 15, y: 0, width: view.frame.size.width, height: 50)
            label.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        }else{
            headerView.frame =  CGRect(x: 0, y: 0, width:  view.frame.size.width , height: 32)
            dropDownImage.frame =  CGRect(x: 15, y: 21, width:  20 , height: 20)
            label.frame = CGRect(x:50, y: 0, width: view.frame.size.width - 120, height: 32)
            sectionButton.frame =  CGRect(x: 0, y: 0, width: view.frame.size.width, height: 32)
            rightLabel.frame = CGRect(x:view.frame.size.width - 120, y: 0, width: 120, height: 32)
            label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
            rightLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
            
        }
        
        
        if( self.selectedTermRow.contains(section)){
            dropDownImage.image = UIImage(named: "smallUpArrow")
        }else{
            dropDownImage.image = UIImage(named: "downArrow")
        }
        
        
        var strTitle = ""
        let dicSubj = arrExamDetail.object(at: 0) as? NSDictionary
        let arrSubs = dicSubj!.object(forKey: "subjects") as? NSArray
        
        let sec = section - (arrSubs!.count + 1)
        
        if(section < arrSubs!.count){
            //let arrSub = dicSubj!.object(forKey: "subjects") as? NSArray
            let arrSub = dicSubj!.object(forKey: "subjects") as? NSArray
            let dicsubgrp = arrSub?.object(at: section) as? NSDictionary
            strTitle = dicsubgrp?.object(forKey: "subjectname") as? String ?? ""
            strTitle = "\(strTitle) \(dicsubgrp?.object(forKey: "markobt") as? String ?? "") / \(dicsubgrp?.object(forKey: "maxmark") as? String ?? "")"
            dropDownImage.frame =  CGRect(x: 15, y: 8, width:  20 , height: 20)
            label.frame = CGRect(x:50, y: 0, width: view.frame.size.width - 120, height: 32)
            rightLabel.frame = CGRect(x:view.frame.size.width - 120, y: 0, width: 120, height: 32)
            label.textColor =  UIColor(red: 0/255.0, green: 96/255.0, blue: 100/255.0, alpha: 1)
            rightLabel.textColor =  UIColor(red: 0/255.0, green: 96/255.0, blue: 100/255.0, alpha: 1)
            
            headerView.addSubview(dropDownImage)
            
            
        }else if(section == arrSubs!.count){
            let arrSub = dicSubj!.object(forKey: "elements") as? NSArray
            strTitle = ""
            label.frame = CGRect(x:8, y: 0, width: view.frame.size.width, height: 36)
            label.textColor  = .black
            
        }else{
            let arrSub = dicSubj!.object(forKey: "groups") as? NSArray
            let dicsubgrp = arrSub?.object(at: sec) as? NSDictionary
            strTitle = dicsubgrp?.object(forKey: "name") as? String ?? ""
            rightLabel.frame = CGRect(x:view.frame.size.width - 130, y: 0, width: 120, height: 32)
            label.frame = CGRect(x:8, y: 0, width: view.frame.size.width - 130, height: 32)
            // label.backgroundColor = .green
            rightLabel.text = ": \(dicsubgrp?.object(forKey: "mark") as? String ?? "")"
            label.textColor  = .black
            rightLabel.textColor  = .black
            
        }
        
        sectionButton.addTarget(self, action: #selector(actionTermDetailButton(sender:)), for: .touchUpInside)
        
        label.text = strTitle
        
        sectionButton.tag = section
        
        label.numberOfLines = 0
        label.textAlignment = .left
        //
        
        rightLabel.numberOfLines = 0
        rightLabel.textAlignment = .left
        // rightLabel.textColor  = .black
        
        headerView.backgroundColor = .lightGray.withAlphaComponent(0.4)
        headerView.addSubview(label)
        headerView.addSubview(rightLabel)
        
        // headerView.addSubview(dropDownImage)
        headerView.addSubview(sectionButton)
        
        
        
        return headerView
    }
    
    
    
    
    @objc func actionTermDetailButton(sender: UIButton){
        let buttonTag = sender.tag
        self.selectedTermRow.removeAllObjects()
        
        if(self.selectedTermRow.contains(buttonTag)){
            self.selectedTermRow.remove(buttonTag)
        }else{
            self.selectedTermRow.add(buttonTag)
        }
        
        print(selectedTermRow)
        // self.table.reloadData()
        StudentMarkTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let dicSubj = arrExamDetail.object(at: 0) as? NSDictionary
        let arrSubs = dicSubj!.object(forKey: "subjects") as? NSArray
        if(section == arrSubs?.count){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 0
            }else{
                return 0
            }
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 50
            }else{
                return 36
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentMarkTVCell", for: indexPath) as! StudentMarkTVCell
        cell.backgroundColor = UIColor.clear
        let Dict : NSDictionary = arrExamDetail[0] as! NSDictionary
        // let iIndex = indexPath.section - 2
        let arrSubs = Dict.object(forKey: "subjects") as? NSArray
        
        let iIndex = indexPath.section - (arrSubs!.count + 1)
        
        if(indexPath.section < arrSubs!.count){
            let arrSub = Dict.object(forKey: "subjects") as? NSArray
            let dicsubgrp = arrSub?.object(at: indexPath.section) as? NSDictionary
            let arrDicgrp = dicsubgrp?.object(forKey: "split") as? NSArray
            let DictSub : NSDictionary = arrDicgrp?.object(at: indexPath.row) as! NSDictionary
            
            cell.ExamTitleLbl.text = String(describing: DictSub["name"]!)
            cell.ExamMarkLbl.text = "\(DictSub.object(forKey: "markobt") as? String ?? "") / \(DictSub.object(forKey: "maxmark") as? String ?? "")"
            cell.ExamTitleLbl.backgroundColor = .white
            cell.ExamMarkLbl.backgroundColor = .white
        }else if(indexPath.section == arrSubs!.count){
            let arrSub = Dict.object(forKey: "elements") as? NSArray
            let DictSub : NSDictionary = arrSub?.object(at: indexPath.row) as! NSDictionary
            cell.ExamTitleLbl.text = String(describing: DictSub["name"]!)
            cell.ExamMarkLbl.text =  " : \(DictSub["mark"] as? String ?? "")"
            cell.ExamTitleLbl.backgroundColor = .lightGray.withAlphaComponent(0.2)
            cell.ExamMarkLbl.backgroundColor = .lightGray.withAlphaComponent(0.2)
            
        }else{
            let arrSub = Dict.object(forKey: "groups") as? NSArray
            let dicsubgrp = arrSub?.object(at: iIndex) as? NSDictionary
            let arrDicgrp = dicsubgrp?.object(forKey: "subgroups") as? NSArray
            let DictSub : NSDictionary = arrDicgrp?.object(at: indexPath.row) as! NSDictionary
            cell.ExamTitleLbl.text = String(describing: DictSub["name"]!)
            cell.ExamMarkLbl.text =  " : \(DictSub["mark"] as? String ?? "")"
            
        }
        
        
        
        
        return cell
        
    }
    //MARK: API CALLING
    
    func GetExamDetailApiCalling()
    {
        showLoading()
        strApiFrom = "GetExamDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EXAM_DETAIL_METHOD
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EXAM_DETAIL_METHOD
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolIDString,"ChildID" : ChildIDString,"ExamID" : ExamIDString, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString,"GetExamDetailApi")
    }
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual("GetExamDetailApi"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        if let val =  dict["StudentID"] {
                            let strVal:String = String(describing: val)
                            AlertString = String(describing: dict["StudentName"]!)
                            if(strVal == "-2")
                            {                                self.AlerMessage(alertStr: AlertString)
                            }
                            
                            else
                            {
                                
                                let DetailDict : NSDictionary = CheckedArray[0] as! NSDictionary
                                
                                let ArrData : NSArray = DetailDict["details"] as! NSArray
                                //appDelegate.ArrExamDetailMark = arrExamDetail
                                for i in 0..<ArrData.count
                                {
                                    let dict = ArrData[i] as! NSDictionary
                                    var MutalDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
                                    
                                    MutalDict["ID"] = String(describing: i)
                                    arrExamDetail.add(MutalDict)
                                    
                                    //ID
                                }
                                Childrens.saveStudentExamMarkDetail(arrExamDetail as! [Any] , ChildIDString , ExamIDString)
                                
                                checkCount = arrExamDetail.count - 4
                                //      print(arrExamDetail)
                                StudentMarkTableView.reloadData()
                            }
                            
                        }else
                        {
                            self.AlerMessage(alertStr: strNoRecordAlert)
                        }
                        
                    }else
                    {
                        self.AlerMessage(alertStr: strNoRecordAlert)
                    }
                    
                }else
                {
                    self.AlerMessage(alertStr: strNoRecordAlert)
                }
                
            }
            
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
    }
    
    func AlerMessage(alertStr: String)
    {
        
        let alertController = UIAlertController(title: "Alert", message: alertStr, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            //    print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
        Util .showAlert("", msg: strSomething);
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    func navTitle(){
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        //titleLabel.textColor = UIColor (red:128.0/255.0, green:205.0/255.0, blue: 244.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord : String =  languageDictionary["student"] as? String ?? "Student"//"Student "
        let thirdWord  : String =  languageDictionary["marksss"] as? String ?? "Marks" //"Marks"
        let comboWord = secondWord  + " " + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord)
        attributedText.addAttributes(attrs, range: range)
        
        titleLabel.attributedText = attributedText
        self.navigationItem.titleView = titleLabel
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
                }else{
                    
                }
            } catch {
                
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            
        }
        
        strNoRecordAlert = LangDict["no_exams"] as? String ?? "No Exams Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.navTitle()
        
    }
}
