


import UIKit
class AddLocationHistory: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noRecLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tv: UITableView!
    var locationHistory:[GeometricLocation]?
    var InstitudeId : Int?
    var userId : Int?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        noRecLbl.isHidden = true
       
        let rowNib = UINib(nibName: CellConfingName.deleteTV, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: CellConfingName.deleteTV)
        let gifImage = UIImage.gifImageWithName("Map Location")
        imageView.image = gifImage
        let back  = UITapGestureRecognizer(target: self, action: #selector(backViewss))
        backView.addGestureRecognizer(back)
        fetchAttachments()
    }
    
    
    
    @IBAction func backViewss(){
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationHistory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.deleteTV, for: indexPath) as!
        deleteTV
        if let locationData = locationHistory?[indexPath.row]{
            cell.configure(with:locationData, at: indexPath)
        }
        
        
//        cell.coordinatesLbl.text = "\(locationHistory?[indexPath.row].latitude ?? "") - \(locationHistory?[indexPath.row].longitude ?? "")"
//        cell.locationLbl.text = locationHistory?[indexPath.row].location
//        cell.distanceLbl.text = "\(locationHistory?[indexPath.row].distance ?? "") Meter"
        cell.deleteBtn.addTarget(self, action: #selector(DeletTapped(_:)), for: .touchUpInside)
        cell.editBtn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        cell.deleteBtn.tag = indexPath.row
        cell.editBtn.tag = indexPath.row
        cell.selectionStyle = .none
        return cell
    }
    @objc func buttonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Update", message: "Please update your details", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your location name"
            textField.text =  self.locationHistory?[sender.tag].location
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your distance"
            textField.text = self.locationHistory?[sender.tag].distance
        }
        let confirmAction = UIAlertAction(title: "Update", style: .default) { [self] (_) in
            if let location = alertController.textFields?[0].text, let distance = alertController.textFields?[1].text {
                print("location Name: \(location)")
                print("distance Name: \(distance)")
                if distance != "" && location != ""{
                    update(param: ["id":String(self.locationHistory?[sender.tag].id ?? 0),
                                   "location":location,
                                   "distance":Int(distance) ?? 0])
                }else{
                    let refreshAlert = UIAlertController(title: "", message: "Location or distance field is empty", preferredStyle: UIAlertController.Style.alert)
                    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                    }))
                    present(refreshAlert, animated: true, completion: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func DeletTapped(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "", message: "Are you sure want to delete this loacation ?", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
            if #available(iOS 15.0, *) {
                showActivityLoader()
            }
            
            APIService.shared.makeApi(
                url: ServiceUrl.staff_attd_geometric_remove_geometric_location,
                parameters: ["location_id":locationHistory?[sender.tag].id ?? 0],
                type: ApitTypeSringFile.POST,
                token:staffDetails?.access_token ?? ""
            ) { [weak self] (result: Result<StaffGeometricLocation, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self?.hideActivityLoader()
                    }
                    
                    switch result {
                    case .success(let result):
                        DispatchQueue.main.async {
                            self?.fetchAttachments()
                        }
                    case .failure(let error):
                        print("Error fetching attachments:", error.localizedDescription)
                    }
                }
            }
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func update(param:[String:Any]){
        
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.staff_attd_geometric_update_geometric_location,
            parameters:param,
            type: ApitTypeSringFile.POST,
            token:staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<StaffGeometricLocation, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideActivityLoader()
                }
                
                switch result {
                case .success(let result):
                    self?.fetchAttachments()
//                    self?.tv.reloadData()
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.staff_attd_geometric_get_geometric_location_history,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<StaffGeometricLocation, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideActivityLoader()
                }
                
                switch result {
                case .success(let response):
                    
                    if response.status == true{
                        DispatchQueue.main.async {
                            self?.noRecLbl.isHidden = true
                            self?.locationHistory = response.data
                            self?.tv.delegate = self
                            self?.tv.dataSource = self
                            self?.tv.reloadData()
                        }
                    }else{
                        
                        DispatchQueue.main.async {
                            self?.noRecLbl.isHidden = false
                            self?.noRecLbl.text = response.message
                            self?.locationHistory = response.data
                            self?.tv.reloadData()
                        }
                    }
                   
                    
                    
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                }
            }
        }
    }
}

class Deleteclick : UITapGestureRecognizer{
    var deleteID : Int?
    var location : String?
    var distance : String?
}


