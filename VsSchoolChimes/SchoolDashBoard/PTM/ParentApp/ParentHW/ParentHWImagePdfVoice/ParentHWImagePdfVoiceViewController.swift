//
//  ParentHWImagePdfVoiceViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import UIKit
import AVFAudio
import AVFoundation
import KRProgressHUD
//import SDWebImage

class ParentHWImagePdfVoiceViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    

    @IBOutlet weak var backView: UIView!
    
    
    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet weak var dateLbl: UILabel!
    
    
    
    let rowIdentifier = "ParentHWImagePdfVoiceTableViewCell"
    
    var filePathListArr : [HWDataList] = []
    var filepath : [HWFilePath] = []
    var dateText :String!
    
   
    var audioFileURL: String!
    var messageId : String!
    var imgCount : Int!
//
    var contenttype : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        tv.dataSource = self
        tv.delegate = self
        
        tv.register(UINib(nibName: rowIdentifier, bundle: nil), forCellReuseIdentifier: rowIdentifier)
        
        let backGes = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGes)
        
    }


    
    @IBAction func backVc() {
        
        
        dismiss(animated: true)
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("filePathListArr",filePathListArr.count)
        return filePathListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as! ParentHWImagePdfVoiceTableViewCell
        

       
        cell.selectionStyle = .none
        
        let filepathList : HWDataList = filePathListArr[indexPath.row]
        
        
        var contetntPath : String!

        print("filepath.count",filepath.count)
        var path1 : String!
        var path2 : String!
        if filepathList.filepath.count > 0 {
            
          
            for i in  filepathList.filepath {
               
                contenttype = i.type
                contetntPath = i.path

                print("pathpath.type",i.type)
                print("pathpath.path",i.path)
                print("filepathList.filepath.count",filepathList.filepath.count)
                if filepathList.filepath.count > 1 {
                    if contenttype == "IMAGE" {
                        path1 = filepathList.filepath[0].path
                        path2 = filepathList.filepath[1].path
                    }
                }
                
                
                if contenttype == "IMAGE" {
                    path1 = filepathList.filepath[0].path
                }else if contenttype == "PDF" {
                    path1 = filepathList.filepath[0].path
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
                    print("contetntPath.count",filepathList.filepath.count)
                    imgCount = filepathList.filepath.count

//
                    if imgCount == 2 {
                       
                        print("path1",path1)
                        print("path2",path2)


                        
                        DispatchQueue.main.async {
                            
                            if path1 != nil &&  path2 != nil {
                                cell.img1.sd_setImage(with: URL(string:  path1), placeholderImage: UIImage(named: "placeHolder"))

                                cell.img2.sd_setImage(with: URL(string:  path2), placeholderImage: UIImage(named: "placeHolder"))
                            }else{
                                print("Path is nil")
                            }

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
                        
                        
                        let imageGes = FilePathGes(target: self, action: #selector(pdfImageshowVc))
                        imageGes.url = path1
                        cell.imgView.addGestureRecognizer(imageGes)
                        
                        
                        let imageGes2 = FilePathGes(target: self, action: #selector(pdfImageshowVc))
                        imageGes2.url = path2
                        cell.image2View.addGestureRecognizer(imageGes2)
                    }else{


                        print("path1",path1)
//                            DispatchQueue.main.async {
//                                

                        if path1 != nil {



                                cell.img1.sd_setImage(with: URL(string:  path1), placeholderImage: UIImage(named: "placeHolder"))
//                                
                        }else{
                            print("Path is nil")
                        }
                        cell.imgView.isUserInteractionEnabled = true
                        cell.imgView?.isHidden = false
                        cell.image2View?.isHidden = true
                        
                        cell.image3View?.isHidden = true
                        cell.image4View?.isHidden = true
                        cell.voiceView?.isHidden = true
                        cell.pdfView?.isHidden = true
                        cell.pdfViewHeight.constant = 0
                        
                        let imageGes = FilePathGes(target: self, action: #selector(pdfImageshowVc))
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
                    
                    
                    let previewGes = FilePathGes(target: self, action: #selector(pdfImageshowVc))
                    previewGes.url = contetntPath
                    cell.previewView.addGestureRecognizer(previewGes)
                    //
                    
                }
            
            
            if filepathList.filepath.count == 0{
                    cell.imgView?.isHidden = true
                    cell.voiceView?.isHidden = true
                    cell.pdfView?.isHidden = true
                    
                    cell.imgViewHeight.constant = 0
                    cell.voiceViewHeight.constant = 0
                    
                }

        }else{
            print("Filepath Is Empty")
            cell.imgView?.isHidden = true
            cell.image2View?.isHidden = true

            cell.image3View?.isHidden = true
            cell.image4View?.isHidden = true
            cell.voiceView?.isHidden = true
            cell.pdfView?.isHidden = true
            cell.webView1?.isHidden = true
            cell.webView2?.isHidden = true
        }
      
        print("filepathData",filepath)
        cell.topicLbl.text =  filepathList.topic
        cell.contentLbl.text =   filepathList.content
        cell.subNameLbl.text = filepathList.subjectname
//
        dateLbl.text =  dateText

        
        
        return cell
        
    }

    
    
    @IBAction  func pdfImageshowVc( ges : FilePathGes) {
        print("test")
      let vc =  HomeWorkPdfImageShomViewController(nibName: nil, bundle: nil)
      vc.modalPresentationStyle = .fullScreen
       
        vc.webUrl = ges.url
//      vc.webUrl = "https://schoolchimes-india.s3.ap-south-1.amazonaws.com/File_20231103100703_IMG20231027111100.jpg"
      present(vc, animated: true)
    }
    
   
    
       

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  
        
//        if contenttype  == "IMAGE" {
//            return UITableView.automaticDimension
//        }
//        else if contenttype  == "VOICE" {
//            return UITableView.automaticDimension
//        }
//        else if contenttype  == "PDF" {
//            return UITableView.automaticDimension
//        }else{
            return UITableView.automaticDimension
//        }
       
    }
   
}



class FilePathGes : UITapGestureRecognizer {
    var url : String!
    var type : String!
    var  btnName : UIButton!
var playbackSlider: UISlider!
}
struct FilePathItem {
    
    var url      : String!
    var type  : String!
}
