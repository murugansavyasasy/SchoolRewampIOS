//
//  busListVC.swift
//  School Chimes
//
//  Created by apple on 08/05/26.
//

import UIKit

class busListVC: UIViewController, liveTrakingBtnDelegate {
    func livetrakingBtnAction(index: Int) {
        if is_wonBustracking{
            let vc = BusTrakingVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
          present(vc, animated: true)
        }else{
            let vc = whereismybusVc(nibName: nil, bundle: nil)
            vc.loginasType = loginasType
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    

    @IBOutlet weak var studentname: UILabel!
    @IBOutlet weak var tv: UITableView!
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var busroute: [student_routData] = []
    var loginasType : Int?
    var is_wonBustracking : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.register(UINib(nibName: "BusRouteCell", bundle: nil), forCellReuseIdentifier: "BusRouteCell")
        tv.dataSource = self
        tv.delegate = self
        
        let name = studentDetails?.name ?? ""
        let standard = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        studentname.configureAsBackTitle(firstLine: name, secondLine: standard)
        
        GetBusRoutDetails()
    }


    @IBAction func backbtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    
    func GetBusRoutDetails() {
        APIService.shared.makeApi(url: ServiceUrl.get_student_route_list, parameters: [:], type: ApitTypeSringFile.GET, token: (loginasType == 2 ? UserDefaultFileManager.get_child_Details()?.access_token : UserDefaultFileManager.get_staff_Details()?.access_token) ?? "", isBaseUrl: false) {[self] (result: Result<student_routDataDetails,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false{
                        self.busroute = Success.data ?? []
                        tv.reloadData()
                        
                    }else{
                        
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
    
    
}
extension busListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busroute.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusRouteCell", for: indexPath) as! BusRouteCell
        cell.configure(with: busroute[indexPath.row])
        cell.delegte = self
        
        return cell
    }
    
    
}

