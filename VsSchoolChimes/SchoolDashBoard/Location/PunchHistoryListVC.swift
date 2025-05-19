
//

import UIKit
class PunchHistoryListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    var selected_staff_id : String? ,staffdetails = UserDefaultFileManager.get_staff_Details(),PunchDetails:[puchHistoryList]? =  [],selectedDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rowNiib = UINib(nibName: CellConfingName.PunchHistTableViewCell, bundle: nil)
        tv.register(rowNiib, forCellReuseIdentifier: CellConfingName.PunchHistTableViewCell)
        noRecordLbl.isHidden = true
        let back = UITapGestureRecognizer(target: self, action: #selector(backClick))
        backView.addGestureRecognizer(back)
        
        Geometric_Punch_History()
        
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    
    @IBAction func backClick(){
        dismiss(animated: true)
    }
    
    
    func Geometric_Punch_History(){
        
        let param = [
            punchHistoryStringFile.from_date : selectedDate,
            punchHistoryStringFile.to_date : selectedDate,
            punchHistoryStringFile.staff_id : selected_staff_id
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.staff_attd_geometric_geometric_punch_history, parameters: param, type: ApitTypeSringFile.GET, token: staffdetails?.access_token ?? "") { [self] (result: Result<PunchHistoryResponse,Error>) in
            
            switch result{
                
            case .success(let successMessage):
                
                if successMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        noRecordLbl.isHidden = true
                        tv.isHidden = false
                        PunchDetails = successMessage.data?.first?.timings
                        tv.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        noRecordLbl.isHidden = false
                        tv.isHidden = true
                        noRecordLbl.text = successMessage.message
                        PunchDetails = successMessage.data?.first?.timings
                        tv.reloadData()
                    }
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PunchDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let punch = PunchDetails?[indexPath.row]
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: CellConfingName.PunchHistTableViewCell, for: indexPath) as! PunchHistTableViewCell
        cell.timing.text = punch?.time
        cell.punchType.text = punch?.punch_type?.value//"Fingerprint"
        cell.phoneModel.text = punch?.device_model//"Realme 11 Pro"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

