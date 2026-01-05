

import UIKit

class TextMessageVC: UIViewController, selectedTextMsg, SelectedTextDelegate {
    func select(Tittle: String, descriptContent: String) {
        titles = Tittle
        content = descriptContent
        IsSelectedHistory = false
        tv.reloadData()
    }
    
    func sendTextMsg(title: String, content: String) {
        if CheckTextMsgFlow(title: title, content: content){
            user_inputs.description = title
            user_inputs.title = title
            recienpient_validation()
        }
    }
    


    @IBOutlet weak var selectFromHstoryLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var TextHistory:[TextDetail]?
    var IsSelectedHistory : Bool = false
    var selectedIndex : Int?
    let alert = CustomAlert()
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var titles  = ""
    var content = ""
    override func viewDidLoad() {
        super.viewDidLoad()

       
        tv.register(UINib(nibName: "SendMsgTvCell", bundle: nil), forCellReuseIdentifier: "SendMsgTvCell")
        tv.register(UINib(nibName: "TextHistoryTVCell", bundle: nil), forCellReuseIdentifier: "TextHistoryTVCell")
        let selectFromHis = UITapGestureRecognizer(target: self, action: #selector(selectFromHistory))
        selectFromHstoryLbl.addGestureRecognizer(selectFromHis)
        tv.dataSource = self
        tv.delegate = self
    }

}
extension TextMessageVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if IsSelectedHistory{
            return TextHistory?.count ?? 0
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if IsSelectedHistory{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
            cell.descriptContent
                .setupExpandable(
                    text: TextHistory?[indexPath.row].content ?? ""
                )
            cell.descriptContent.onExpandableTap = {
                cell.descriptContent.isExpanded.toggle()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.descriptiontext = TextHistory?[indexPath.row].content ?? ""
            cell.MessageTitle.text = TextHistory?[indexPath.row].title
            cell.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                cell.configureShimmer()
            }
            if let sentOn = TextHistory?[indexPath.row].date,
               let date = DateFormatterHelper.shared.parseDate(from: sentOn) {
                let dateString = DateFormatterHelper.shared.formatDateToDayMonthYear(date: date) // "11 Apr 2025"
                let timeString = DateFormatterHelper.shared.formatTime(date: date) // "01:04 PM"
                let fullText = "\(dateString) \(timeString)" // "11 Apr 2025 01:04 PM"
                let attributedText = NSMutableAttributedString(string: fullText)
                // Change time part color
                if let timeRange = fullText.range(of: timeString) {
                    let nsRange = NSRange(timeRange, in: fullText)
                    attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: nsRange)
                }
                cell.DateLabel.attributedText = attributedText
            }
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SendMsgTvCell", for: indexPath) as? SendMsgTvCell else {
                return UITableViewCell()
            }
         
                cell.titleTextFiled.text = titles
                cell.descriptionTxtView.text = content
            cell.delegate = self
            return cell
        }
       
      
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func selectFromHistory() {
        
        if selectFromHstoryLbl.text == "<<Back to compose"{
            selectFromHstoryLbl.textAlignment = .right
            IsSelectedHistory = false
            selectFromHstoryLbl.text = "<<Select from history"
            tv.reloadData()
        }else if selectFromHstoryLbl.text == "<<Select from history"{
            selectFromHstoryLbl.textAlignment = .left
            IsSelectedHistory = true
            selectFromHstoryLbl.text = "<<Back to compose"
            get_Text_History()
        }
       
    }
    
    
    func CheckTextMsgFlow(title:String,content:String) -> Bool{
        var  bool = false
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if !title.isEmpty && !description.isEmpty {
            user_inputs.title = title
            user_inputs.description = description
            bool = true
        } else {
            bool = false
            alert.showAlert(
                title: "",
                message: AlertstringFile.enter_title_description,
                on: self
            )
        }
     return  bool
        
    }
    
    func recienpient_validation(){
        if(staffDetailsCount?.count ?? 0 > 1){
                if(staff_role == PriorityType.is_principal || staff_role == PriorityType
                    .is_grouphead || staff_role == PriorityType.is_admin){
                    if #available(iOS 14.0, *) {
                        let vc = SchoolListVC(nibName: nil, bundle: nil)
                        vc.screen_type = screenType.communication_text
                        vc.modalPresentationStyle = .fullScreen
                        present(vc, animated: true)
                    }
                }
                
                else{
                    let vc = RecipientVc(nibName: nil, bundle: nil)
                    vc.ScreenType = screenType.communication_text
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
        }
        else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.ScreenType = screenType.communication_text
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
        }
    }

}

extension TextMessageVC {
    func get_Text_History(){
        APIService.shared
            .makeApi(url:  ServiceUrl.comm_text_message_get_text_history, parameters: [:] , type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false){ [self] (
                result : Result<TextDetailsResponse,
                Error>
            ) in switch result {
            case.success(let succesmessage) :
                if succesmessage.status == true {
                    DispatchQueue.main.async { [self] in
//                        no_recordLbl.isHidden = true
                        TextHistory = succesmessage.data
                        tv.reloadData()
//                        historytable.reloadData()
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        TextHistory = []
                        tv.reloadData()
//                        no_recordLbl.isHidden = false
//                        no_recordLbl.text = succesmessage.message
//                        historytable.reloadData()
                    }
                }
            case.failure(let error) :
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
            }
    }
}
