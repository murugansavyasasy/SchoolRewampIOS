//
//  IntractwithStudentVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/07/25.
//

import UIKit

class IntractwithStudentVc: UIViewController {

    @IBOutlet weak var tv: UITableView!
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var getStandardDetails:[StaffMember]?
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: CellConfingName.interactTvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.interactTvcell)
        tv.delegate = self
        tv.dataSource = self
        getStaff()
    }


   
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension IntractwithStudentVc:UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStandardDetails?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.interactTvcell,
            for: indexPath
        ) as? interactTvcell else {
            return UITableViewCell()
        }
        
        
        let datas = getStandardDetails?[indexPath.row]
        cell.teacherNameLbl.text = (datas?.name ?? "")  + "   -  " + (
            datas?.section_name ?? "")
        cell.subjectNameLbl.text = datas?.subject_name ?? ""
        cell.profileImage.image = UIImage(systemName: "person.3.sequence.fill")
        
        return cell
        
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        let vc = chatWithStudentVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        if let datas = getStandardDetails?[indexPath.row]{
            vc.staffMembersData = datas
        }
        
        // vc.getValue = getValue
        present(vc, animated: true)
        
        
    }
    

    func getStaff(){
        APIService.shared
            .makeApi(url: ServiceUrl.interaction_classes_for_chat , parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? ""){ [self] (
                result:Result <StaffListResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            getStandardDetails = successMessage.data ?? []
                            
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
}
