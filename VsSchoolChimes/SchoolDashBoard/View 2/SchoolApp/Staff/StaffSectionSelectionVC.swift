//
//  StaffSectionSelectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 09/08/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffSectionSelectionVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var SelectAllBtn: UIButton!
    @IBOutlet weak var AddNewClassButton: UIButton!
    @IBOutlet weak var ConfirmButton: UIButton!
    @IBOutlet weak var MyTableView: UITableView!
    
    var DetailsofSubjectArray :  Array = [Any]()
    var SegueDetailsofSubjectArray :  Array = [Any]()
    var SelectedDetailsofSubjectArray :  NSMutableArray = []
    var MainSelectedDetailsofSubjectArray :  NSMutableArray = []
    var selectedIndexpath = IndexPath()
    var Mystring = String()
    var MessageToAll = String()
    var SendTextMessage = String()
    var SelectedStudentID:Array = [String]()
    var TargetCodeArray:Array = [Any]()
    var StudentCount = Int()
    var AlertSectionData = String()
    var SecCodeDic:NSDictionary = [String:String]() as NSDictionary
    var SubCodeDic:NSDictionary = [String:String]() as NSDictionary
    var MessageToDic:NSDictionary = [String:String]() as NSDictionary
    var SelectedStudentDic:NSDictionary = [String:Any]() as NSDictionary
    var MyNewClassDic:NSDictionary = [String:Any]() as NSDictionary
    var SelectedStudentIdArray:Array = [Any]()
    var SelectedSectionDetailArray : NSMutableArray = []
    var AddtionalDetailsofSubjectArray : NSMutableArray = []
    var RemoveSelectedSectionDetailArray : NSMutableArray = []
    var DetailedSubjectArray : Array = [Any]()
    var MessageToAllArray : Array = [Any]()
    var SelectedMessageToAllArray : Array = [Any]()
    var SelectedEditButtonTag = 0
    var SegueSelectedSectionDetailArray :  NSMutableArray = []
    var SegueSelectedDetailsofSubjectArray :  NSMutableArray = []
    var CommonSelectedSectionDetailArray :  NSMutableArray = []
    var CommontSelectedDetailsofSubjectArray :  NSMutableArray = []
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        SelectAllBtn.isSelected = true
        ConfirmButton.isUserInteractionEnabled = false
        
        if(SelectedSectionDetailArray.count > 0){
            
            if(SelectedSectionDetailArray.count == DetailsofSubjectArray.count){
                SelectAllBtn.isSelected = false
            }
            
            ConfirmButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            ConfirmButton.isUserInteractionEnabled = true
            
        }
        
        if(SegueDetailsofSubjectArray.count > 0){
            var dic:NSDictionary = [String : Any]() as NSDictionary
            
            for i in 0..<SegueDetailsofSubjectArray.count{
                dic = SegueDetailsofSubjectArray[i] as! NSDictionary
            }
            
            let SubjectName = dic["SubjectName"] as! String
            AlertSectionData = dic["SubjectCode"] as! String
            if(SubjectName == "")
            {
                
                Util.showAlert("Warning", msg: AlertSectionData)
                self.MyTableView.isHidden = true
                ConfirmButton.isUserInteractionEnabled = false
                SelectAllBtn.isUserInteractionEnabled = false
            }
            else
            {
                self.MyTableView.isHidden = false
                SelectAllBtn.isUserInteractionEnabled = true
                DetailsofSubjectArray = SegueDetailsofSubjectArray
                let AddDetail : NSMutableArray = []
                for i in 0..<DetailsofSubjectArray.count
                {
                    
                    SelectedStudentDic = DetailsofSubjectArray[i] as! NSDictionary
                    var temp = NSMutableDictionary(dictionary: SelectedStudentDic)
                    temp.setValue("T", forKey: "MsgToAll")
                    
                    let mydic:NSDictionary = ["StudentIdArrayData": SelectedStudentIdArray]
                    
                    temp.addEntries(from: mydic as! [AnyHashable : Any])
                    
                    
                    AddDetail.add(temp)
                    
                }
                
                AddtionalDetailsofSubjectArray = AddDetail
                self.MyTableView.reloadData()
            }
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffSectionSelectionVC.catchNotification), name: NSNotification.Name(rawValue: "NewClassComeBack"), object:nil)
        nc.addObserver(self,selector: #selector(StaffSectionSelectionVC.StudentcatchNotification), name: NSNotification.Name(rawValue: "StudentSelectionComeBack"), object:nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.ButtonCornerDesign()
        
        
    }
    
    @IBAction func actionCloseView(_ sender: Any)
    {
        
        let nc = NotificationCenter.default
        
        nc.post(name:Notification.Name(rawValue:"StaffSectionComeback"),
                object: nil,userInfo: ["SectionDetail":DetailsofSubjectArray,"SelectedSectionDetail":SelectedSectionDetailArray,"MainSelectedSectionDetail": SelectedDetailsofSubjectArray,"AddtionalSectionDetail": AddtionalDetailsofSubjectArray,"actionkey":"cancel"])
        
        
        self.dismiss(animated: false, completion: nil)
        
        
    }
    
    
    
    
    
    @IBAction func actionSelectAllButton(_ sender: UIButton)
    {
        let cell:StaffSectionTVCell = MyTableView.dequeueReusableCell(withIdentifier: "StaffSectionTVCell") as! StaffSectionTVCell
        
        if(SelectAllBtn.isSelected == true)
        {
            let CloneSelectedSectionDetailArray : NSMutableArray = []
            
            for i in 0..<AddtionalDetailsofSubjectArray.count
            {
                let dic = AddtionalDetailsofSubjectArray[i] as! NSDictionary
                CloneSelectedSectionDetailArray.add(dic)
            }
            SelectedSectionDetailArray = CloneSelectedSectionDetailArray
            
            let CloneSelectedDetailsofSubjectArray : NSMutableArray = []
            for i in 0..<DetailsofSubjectArray.count
            {
                let dic = DetailsofSubjectArray[i] as! NSDictionary
                CloneSelectedDetailsofSubjectArray.add(dic)
            }
            SelectedDetailsofSubjectArray = CloneSelectedDetailsofSubjectArray
            
            
            
            cell.SelectAllButton.isSelected = false
            
            
            ConfirmButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            ConfirmButton.isUserInteractionEnabled = true
            
            SelectAllBtn.isSelected = false
            self.MyTableView.reloadData()
            
        }
        else
        {
            SelectedSectionDetailArray = []
            SelectedDetailsofSubjectArray = []
            
            
            ConfirmButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ConfirmButton.isUserInteractionEnabled = false
            cell.SelectAllButton.isSelected = true
            SelectAllBtn.isSelected = true
            self.MyTableView.reloadData()
            
            
        }
        
    }
    
    //MARK: CONFIRN BUTTON ACTION
    @IBAction func actionConfirmButton(_ sender: Any)
    {
        
        let nc = NotificationCenter.default
        
        nc.post(name:Notification.Name(rawValue:"StaffSectionComeback"),
                object: nil,userInfo: ["SectionDetail":DetailsofSubjectArray,"SelectedSectionDetail":SelectedSectionDetailArray,"MainSelectedSectionDetail": SelectedDetailsofSubjectArray,"AddtionalSectionDetail": AddtionalDetailsofSubjectArray,"actionkey":"ok"])
        
        
        self.dismiss(animated: false, completion: nil)
        
        
    }
    
    
    @IBAction func actionAddNewClass(_ sender: Any) {
        
        let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
        self.present(AddCV, animated: false, completion: nil)
    }
    
    //MARK: TABLEVIEW
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return DetailsofSubjectArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StaffSectionTVCell", for: indexPath) as! StaffSectionTVCell
        cell.backgroundColor = UIColor.clear
        
        let DetailSubjectDic = DetailsofSubjectArray[indexPath.row] as! NSDictionary
        let AddtionDic = AddtionalDetailsofSubjectArray[indexPath.row] as! NSDictionary
        let StudArrayData = AddtionDic["StudentIdArrayData"] as! NSArray
        
        
        
        cell.SubjectNameLabel.text = DetailSubjectDic["SubjectName"] as? String
        let TotalStudent = DetailSubjectDic["NoOfStudents"] as? String
        cell.TotalStudentLabel.text = "/" + TotalStudent!
        if(StudArrayData.count == 0)
        {
            cell.StudentCountLabel.text = TotalStudent
        }
        else
        {
            cell.StudentCountLabel.text = String(StudArrayData.count)
            
        }
        let StandardName = DetailSubjectDic["Class"] as! String
        let SectionName = DetailSubjectDic["Section"] as! String
        cell.SectionNameLabel.text = StandardName + " - " + SectionName
        
        cell.SelectAllButton.addTarget(self, action: #selector(actionSelectAllCell(sender:)), for: .touchUpInside)
        cell.SelectAllButton.tag = indexPath.row
        cell.EditButton.isUserInteractionEnabled = false
        cell.EditButton.addTarget(self, action: #selector(actionEditButton(sender:)), for: .touchUpInside)
        cell.EditButton.tag = indexPath.row
        
        
        if(SelectedDetailsofSubjectArray.count > 0)
        {
            for i in 0..<SelectedDetailsofSubjectArray.count
            {
                let SelectedDic = SelectedDetailsofSubjectArray[i] as! NSDictionary
                
                if(SelectedDic == DetailSubjectDic)
                {
                    let StudentDic = SelectedSectionDetailArray[i] as! NSDictionary
                    let NumberofStudent = SelectedDic["NoOfStudents"] as! String
                    let StudArrayData = StudentDic["StudentIdArrayData"] as! NSArray
                    
                    let image = UIImage(named: "CheckBoximage") as UIImage?
                    cell.SelectAllButton.setImage(image, for: .normal)
                    if(StudArrayData.count > 0)
                    {
                        cell.StudentCountLabel.text = String(StudArrayData.count)
                    }
                    else
                    {
                        cell.StudentCountLabel.text = NumberofStudent
                    }
                    cell.SelectAllButton.isSelected = false
                    cell.EditButton.isUserInteractionEnabled = true
                    cell.EditButton.backgroundColor = UIColor.white
                }
                
            }
            
            
        }
        else
        {
            
            let image = UIImage(named: "UnCheckBoxIcon") as UIImage?
            cell.SelectAllButton.setImage(image, for: .normal)
            cell.EditButton.isUserInteractionEnabled = false
            cell.EditButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        
    }
    @objc func actionSelectAllCell(sender:UIButton)
    {
        let buttonTag = sender.tag
        let selectedindexpath = NSIndexPath(row: sender.tag, section: 0)
        let cell:StaffSectionTVCell  = MyTableView.cellForRow(at: selectedindexpath as IndexPath) as! StaffSectionTVCell
        
        if(cell.SelectAllButton.isSelected == true)
        {
            
            
            let  SelectedData = AddtionalDetailsofSubjectArray[buttonTag] as! NSDictionary
            let selecteddetail = DetailsofSubjectArray[buttonTag] as! NSDictionary
            
            SelectedSectionDetailArray.add(SelectedData)
            SelectedDetailsofSubjectArray.add(selecteddetail)
            
            
            let NumberofStudent = selecteddetail["NoOfStudents"] as! String
            let StudArrayData = SelectedData["StudentIdArrayData"] as! NSArray
            
            if(StudArrayData.count > 0)
            {
                cell.StudentCountLabel.text = String(StudArrayData.count)
            }
            else
            {
                cell.StudentCountLabel.text = NumberofStudent
            }
            
            
            
            let image = UIImage(named: "CheckBoximage") as UIImage?
            
            cell.SelectAllButton.setImage(image, for: .normal)
            cell.SelectAllButton.isSelected = false
            cell.EditButton.isUserInteractionEnabled = true
            cell.EditButton.backgroundColor = UIColor.white
            
            
            
            
            
            if(SelectedDetailsofSubjectArray.count == DetailsofSubjectArray.count)
            {
                SelectAllBtn.isSelected = false
            }
            else
            {
                SelectAllBtn.isSelected = true
                
            }
            
            ConfirmButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            ConfirmButton.isUserInteractionEnabled = true
            
            
        }
        else
        {
            let  SelectedData = AddtionalDetailsofSubjectArray[buttonTag] as! NSDictionary
            let selecteddetail = DetailsofSubjectArray[buttonTag] as! NSDictionary
            
            
            if(SelectedSectionDetailArray.contains(SelectedData))
            {
                SelectedSectionDetailArray.remove(SelectedData)
            }
            if(SelectedDetailsofSubjectArray.contains(selecteddetail))
            {
                SelectedDetailsofSubjectArray.remove(selecteddetail)
            }
            
            if(SelectedDetailsofSubjectArray.count == DetailsofSubjectArray.count)
            {
                SelectAllBtn.isSelected = false
            }
            else
            {
                SelectAllBtn.isSelected = true
                
            }
            
            let image = UIImage(named: "UnCheckBoxIcon") as UIImage?
            
            cell.SelectAllButton.setImage(image, for: .normal)
            cell.SelectAllButton.isSelected = true
            cell.EditButton.isUserInteractionEnabled = false
            cell.EditButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            
            ConfirmButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ConfirmButton.isUserInteractionEnabled = false
            
            if(SelectedSectionDetailArray.count > 0 )
            {
                ConfirmButton.isUserInteractionEnabled = true
                ConfirmButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
                
            }
            else
            {
                ConfirmButton.isUserInteractionEnabled = false
                ConfirmButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
                SelectAllBtn.isSelected = true
                
                
            }
            
        }
        
        
    }
    
    @objc func actionEditButton(sender:UIButton)
    {
        SelectedEditButtonTag = sender.tag
        
        let StudentVC = self.storyboard?.instantiateViewController(withIdentifier: "StaffStudentSelectionVC") as! StaffStudentSelectionVC
        
        let EditSectionData = AddtionalDetailsofSubjectArray[SelectedEditButtonTag] as! NSDictionary
        
        StudentVC.DetailedStudentDictionary = EditSectionData
        StudentVC.SelectedStudentIDArray = SelectedStudentID
        self.present(StudentVC, animated: false, completion: nil)
    }
    func updateSelectedStudentCount()
    {
        let selectedindexpath = NSIndexPath(row: SelectedEditButtonTag, section: 0)
        let cell:StaffSectionTVCell  = MyTableView.cellForRow(at: selectedindexpath as IndexPath) as! StaffSectionTVCell
        
        cell.StudentCountLabel.text = String(StudentCount)
        
    }
    
    
    //MARK: STUDENT SELECTION COMEBACK
    @objc func StudentcatchNotification(notification:Notification) -> Void
    {
        
        let PerformAction = notification.userInfo?["actionkey"] as! String
        if(PerformAction == "ok")
            
            
        {
            
            let selectedDic = notification.userInfo?["SelectedStudentIDdic"] as! NSDictionary
            AddtionalDetailsofSubjectArray[SelectedEditButtonTag] = selectedDic
            SelectedSectionDetailArray[SelectedEditButtonTag] = selectedDic
            let StudentArrayvalue = selectedDic["StudentIdArrayData"] as! NSArray
            StudentCount = StudentArrayvalue.count
            self.updateSelectedStudentCount()
            
            
            
            
        }
        
    }
    
    
    //MARK: ADD NEW SECTION COMEBACK
    
    @objc func catchNotification(notification:Notification) -> Void
    {
        self.MyTableView.isHidden = false
        SelectAllBtn.isUserInteractionEnabled = true
        SelectAllBtn.isSelected = true
        let PerformAction = notification.userInfo?["actionkey"] as! String
        
        if(PerformAction == "ok")
        {
            
            MyNewClassDic = notification.userInfo?["NewSectionDetail"] as! NSDictionary
            let AddDetail : NSMutableArray = []
            
            var arrayMutable : NSMutableArray = []
            arrayMutable = DetailsofSubjectArray as! NSMutableArray
            
            if(arrayMutable.contains(MyNewClassDic))
            {
                
            }
            else
            {
                DetailsofSubjectArray.append(MyNewClassDic)
                SelectedStudentDic = MyNewClassDic
                var temp = NSMutableDictionary(dictionary: SelectedStudentDic)
                temp.setValue("T", forKey: "MsgToAll")
                
                let mydic:NSDictionary = ["StudentIdArrayData": SelectedStudentIdArray]
                
                temp.addEntries(from: mydic as! [AnyHashable : Any])
                
                AddtionalDetailsofSubjectArray.add(temp)
            }
            
            
            self.MyTableView.reloadData()
        }
    }
    
    func ButtonCornerDesign(){
        AddNewClassButton.layer.cornerRadius = 5
        AddNewClassButton.layer.masksToBounds = true
        ConfirmButton.layer.cornerRadius = 5
        ConfirmButton.layer.masksToBounds = true
        
    }
}
