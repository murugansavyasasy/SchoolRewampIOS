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
        present(vc, animated: true)
    }
    
    
    

    @IBOutlet weak var tv: UITableView!
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var hostelData : [HostelListData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        hostelData.append(HostelListData(id: "1", name: "National Boys Hostel School", institute_id: "12", institute_name: "Siga Higher Secondary School, Villupuram 605602", type: "Male", max_capacity: 300, address: "Villupuram Railway Station Back Side"))

        hostelData.append(HostelListData(id: "2", name: "Green Valley Boys Hostel", institute_id: "13", institute_name: "Green Valley Matric School, Chennai 600045", type: "Male", max_capacity: 250, address: "Tambaram East, Chennai"))

        hostelData.append(HostelListData(id: "3", name: "Sunrise Girls Hostel", institute_id: "14", institute_name: "Sunrise Girls Higher Secondary School, Trichy 620001", type: "Female", max_capacity: 200, address: "Near Central Bus Stand, Trichy"))

        hostelData.append(HostelListData(id: "4", name: "Bright Future Boys Hostel", institute_id: "15", institute_name: "Bright Future School, Salem 636007", type: "Male", max_capacity: 180, address: "Opposite New Bus Stand, Salem"))

        hostelData.append(HostelListData(id: "5", name: "St. Mary Girls Hostel", institute_id: "16", institute_name: "St. Mary Matriculation School, Madurai 625020", type: "Female", max_capacity: 220, address: "Anna Nagar, Madurai"))

        hostelData.append(HostelListData(id: "6", name: "Royal Boys Hostel", institute_id: "17", institute_name: "Royal International School, Coimbatore 641018", type: "Male", max_capacity: 270, address: "Gandhipuram, Coimbatore"))

        hostelData.append(HostelListData(id: "7", name: "Little Flower Girls Hostel", institute_id: "18", institute_name: "Little Flower School, Erode 638001", type: "Female", max_capacity: 190, address: "Near Railway Colony, Erode"))

        hostelData.append(HostelListData(id: "8", name: "Victory Boys Hostel", institute_id: "19", institute_name: "Victory Higher Secondary School, Tirunelveli 627002", type: "Male", max_capacity: 210, address: "Palayamkottai, Tirunelveli"))

        hostelData.append(HostelListData(id: "9", name: "Lotus Girls Hostel", institute_id: "20", institute_name: "Lotus Matric School, Vellore 632004", type: "Female", max_capacity: 160, address: "Katpadi Road, Vellore"))

        hostelData.append(HostelListData(id: "10", name: "Elite Boys Hostel", institute_id: "21", institute_name: "Elite Public School, Kanchipuram 631501", type: "Male", max_capacity: 240, address: "Near Temple Street, Kanchipuram"))
        
        tv.register(HostelListTvCell.self)
        tv.delegate = self
        tv.dataSource = self
    }

    func GetHostelList() {
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list_staff, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<HostelListSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    hostelData = Success.data ?? []
                    tv.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
                }
            }
        }
    }

    @IBAction func BackBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
}
