//
//  LsrwListShowViewController.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/20/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import PhotosUI
import Alamofire
//import ObjectMapper

//enum UploadResult {
//case success(String)
//case failure(Error)
//}

class LsrwListShowViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
  
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var tv: UITableView!
    var currentImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    
    var selectedImages: [UIImage] = []
    var authToken = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    var videoEmbdUrl : String!
    var iframeLink : String!
    var videoSucessId = 0
  
    var imageStr : [String] = []
    var totalImageCount = 0
    var onImagesPicked: (([UIImage]) -> Void)?

    var onPdfPicked: ((Data) -> Void)?
    var onImagePicked: (([UIImage]) -> Void)?
//    var viewSkillDatas : [ViewAllSkillByData] = []
//    var clone_list : [ViewAllSkillByData] = []
    //var rowIdentifier = "LsrwListShowTableViewCell"
    //var rowIdentifier = "LSRWTvCell"
    var rowIdentifier = "NewLSRWTVcell"
    var instituteId  = Int()
    var studentId = String()
    
    let tasks: [LSRW] = [
        LSRW(
            title: "Listening Comprehension - The Environment",
            description: "Listen to an audio about saving the environment and answer questions.",
            subject: "English",
            SubmitedOn: "2025-01-15"
        ),
        
        LSRW(
            title: "Speaking - Debate on Climate Change",
            description: "Give a 5-minute speech about whether climate change is real or not.",
            subject: "English",
            SubmitedOn: "2025-01-20"
        ),
        
        LSRW(
            title: "Reading - Short Story Analysis",
            description: "Read a short story and write about its characters and themes.",
            subject: "Literature",
            SubmitedOn: "2025-01-18"
        ),
        
        LSRW(
            title: "Writing - Persuasive Essay",
            description: "Write an essay arguing if homework should be banned or not.",
            subject: "English",
            SubmitedOn: "2025-01-25"
        ),
        
        LSRW(
            title: "Listening - Understanding News Broadcast",
            description: "Listen to a news report and summarize the main points.",
            subject: "Social Studies",
            SubmitedOn: "2025-01-22"
        ),
        
        LSRW(
            title: "Speaking - Show and Tell",
            description: "Present an item that is important to you and explain why.",
            subject: "English",
            SubmitedOn: "2025-01-30"
        ),
        
        LSRW(
            title: "Reading - Poetry Analysis",
            description: "Read a poem and explain its meaning and main ideas.",
            subject: "Literature",
            SubmitedOn: "2025-01-28"
        ),
        
        LSRW(
            title: "Writing - Creative Writing",
            description: "Write a short, creative story with a good plot and characters.",
            subject: "English",
            SubmitedOn: "2025-02-01"
        )
    ]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.addDoneButton()
        backBtn.applyBackButton()
        
        let userDefaults = UserDefaults.standard
       
        let formattedText = breakIntoLines(text: ReceiverMenuItems.LSRW.translated(), maxCharactersPerLine: 15)
        backBtn.setTitle(formattedText, for: .normal)
        backBtn.titleLabel?.numberOfLines = 0
        backBtn.titleLabel?.lineBreakMode = .byWordWrapping
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        
        tv.register(UINib(nibName: rowIdentifier, bundle: nil), forCellReuseIdentifier: rowIdentifier)
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        print("dismiss")
        
    }
    @IBAction func takeReadingSkill() {
        let vc = LSRWTakingSkillViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated:   true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as! NewLSRWTVcell
        cell.TitleLbl.text = tasks[indexPath.row].title
        cell.DescriptionLbl.text = tasks[indexPath.row].description
        cell.Subject.setTitle(tasks[indexPath.row].subject, for: .normal)
        cell.Date.setTitle(tasks[indexPath.row].SubmitedOn, for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(AttachmentRedirect))
        cell.TakeSkillBtn.addGestureRecognizer(tap)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    
    @IBAction func AttachmentRedirect(ges : LsrwListShowGesture) {
        
        
        let vc = LSRWTakingSkillViewController(nibName: nil, bundle: nil)
        //vc.skillId = ges.getSkillId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
//        let filtered_list : [ViewAllSkillByData] = Mapper<ViewAllSkillByData>().mapArray(JSONString: clone_list.toJSONString()!)!
//        
//        if !searchText.isEmpty{
//            viewSkillDatas = filtered_list.filter { $0.Description.lowercased().contains(searchText.lowercased()) ||
//                $0.Title.lowercased().contains(searchText.lowercased()) ||
//                $0.subject.lowercased().contains(searchText.lowercased()) ||
//                $0.SubmittedOn.lowercased().contains(searchText.lowercased())
//            }
//            
//            
//        }else{
//          
//          
//            viewSkillDatas = filtered_list
//            print("pendingOrder")
//        }
//        
//        if viewSkillDatas.count > 0{
//            
//            nodataView.isHidden = true
//            nodataLbl.isHidden = true
//          
//            print ("seCount",viewSkillDatas.count)
//        }else{
//            
//            nodataView.isHidden = false
//            nodataLbl.isHidden = false
//            nodataLbl.text = "No Data Found"
//            print ("searchListPendigCount",viewSkillDatas.count)
//            
//           
//        }
        
        tv.reloadData()
        //        }
    }
    
     func breakIntoLines(text: String, maxCharactersPerLine: Int) -> String {
           var result = ""
           var currentLine = ""

           for word in text.split(separator: " ") {
               if currentLine.count + word.count + 1 <= maxCharactersPerLine {
                   currentLine += (currentLine.isEmpty ? "" : " ") + word
               } else if word.count > maxCharactersPerLine {
                   if !currentLine.isEmpty {
                       result += currentLine + "\n"
                       currentLine = ""
                   }
                   var startIndex = word.startIndex
                   while startIndex < word.endIndex {
                       let endIndex = word.index(startIndex, offsetBy: maxCharactersPerLine, limitedBy: word.endIndex) ?? word.endIndex
                       result += word[startIndex..<endIndex] + "\n"
                       startIndex = endIndex
                   }
               } else {
                   result += currentLine + "\n"
                   currentLine = String(word)
               }
           }
           result += currentLine // Add the last line

           return result
       }
    
}


class LsrwListShowGesture : UITapGestureRecognizer {
    var getSkillId : String!
}


struct LSRW {
   var title : String
   var description : String
   var subject : String
   var SubmitedOn : String
    
}
