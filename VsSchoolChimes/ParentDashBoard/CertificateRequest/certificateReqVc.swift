//
//  certificateReqVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit

class certificateReqVc: UIViewController,UITableViewDelegate,UITableViewDataSource, certificateRequest {
    func reqestBtn(type: String, urgencyLevel: String, reason: String) {
        SendeRequestApi(reason: reason , type: type, urgencyLevel: urgencyLevel)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "certificateReqTVCell") as? certificateReqTVCell else{
                return UITableViewCell()
            }
            
            cell.delegate = self
            cell.textChanged = { [weak self] updatedText in
//                self?.yourDataArray[indexPath.row] = updatedText
                UIView.setAnimationsEnabled(false)
                self?.tv.beginUpdates()
                self?.tv.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
            return cell
          } else {
              
              guard let cell = tableView.dequeueReusableCell(withIdentifier: "certificateHstryCell") as? certificateHstryCell else{
                  return UITableViewCell()
              }
              cell.configure(with: filteredCertificates)
              return cell
          }
        
        
        
    }
    
  
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "certificateHstryCell") as? certificateHstryCell else {
                return 100
            }
            cell.configure(with:filteredCertificates)
            return cell.collectionContentHeight() + 60
        }
        
    }


    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var studentNameLbl: UILabel!
    
    var certificates: [CertificateRequest]? = []
    var filteredCertificates: [CertificateRequest]? = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        studentNameLbl.configureAsBackTitle(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        // Do any additional setup after loading the view.
        
        tv
            .register(
                UINib(nibName: "certificateReqTVCell", bundle: nil),
                forCellReuseIdentifier: "certificateReqTVCell"
            )
        tv
            .register(
                UINib(nibName: "certificateHstryCell", bundle: nil),
                forCellReuseIdentifier: "certificateHstryCell"
            )
        
        tv.dataSource = self
        tv.delegate = self
        certificateListApi()
    }
    
    func SendeRequestApi(reason: String,type:String,urgencyLevel:String) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_certificate_send_request,
            parameters: [
                "requested_for": type,
                "urgency_level": urgencyLevel,
                "reason": reason
            ],
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ChangePasswordSuc, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    let alert = CustomAlert()
                    alert.showAlert(title: "Success", message: "Request submitted successfully.", on: self ?? UIViewController())
                    self?.certificateListApi()
                    
                    if let cell = self?.tv.cellForRow(at: IndexPath(row: 0, section: 0)) as? certificateReqTVCell {
                                        cell.resetFields()
                                    }
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }

    
    func certificateListApi() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_certificate_request_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<CertificateResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                  //  self?.tv.isHidden = false
                    self?.certificates = response.data
                    self?.filteredCertificates = response.data
                  //  self?.tv.reloadData()
                   
                    self?.tv.reloadData()
//                    self?.noDataImg.isHidden = !(self?.filteredCertificates?.isEmpty ?? false)
//                    self?.noDataLbl.isHidden = !(self?.filteredCertificates?.isEmpty ?? false)
//                    self?.noDataLbl.text = response.message
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }
    
    
    @IBAction func backbtn(_ sender: Any) {
        dismiss(animated: true)
    }
  
}
