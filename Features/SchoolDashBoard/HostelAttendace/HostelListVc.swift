//
//  HostelListVc.swift
//  School Chimes
//
//  Created by apple on 09/03/26.
//

import UIKit

class HostelListVc: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostelData.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HostelListTvCell",
            for: indexPath
        ) as? HostelListTvCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if let data = hostelData[safe: indexPath.row] {
            cell.configure(with: data )
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let vc = HostelDashBoardVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.hostelData = hostelData[safe: indexPath.row]
        present(vc, animated: true)
    }
    
    
    
    @IBOutlet weak var hostelAviabelCountLbl: UILabel!
    
    @IBOutlet weak var tv: UITableView!
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var hostelData : [HostelListData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.register(HostelListTvCell.self)
        tv.delegate = self
        tv.dataSource = self
        GetHostelList()
       
    }

    func GetHostelList() {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_hostel_list, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<HostelListSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    
                    if Success.status ?? false{
                        hostelData = Success.data ?? []
                        hostelAviabelCountLbl.text = "\(Success.data?.count ?? 0) HOSTELS AVAILABLE"
                        tv.reloadData()
                    }else{
                        hostelAviabelCountLbl.isHidden = true
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: Success.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }
                   
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }

    @IBAction func BackBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
}
