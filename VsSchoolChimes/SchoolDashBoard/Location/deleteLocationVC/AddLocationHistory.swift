//
//  deleteVc.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 02/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

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
        fetchAttachments()
        noRecLbl.isHidden = true
        let rowNib = UINib(nibName: CellConfingName.deleteTV, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: CellConfingName.deleteTV)
        let gifImage = UIImage.gifImageWithName("Map Location")
        imageView.image = gifImage
        let back  = UITapGestureRecognizer(target: self, action: #selector(backViewss))
        backView.addGestureRecognizer(back)
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
        cell.lattidudeLbl.text = locationHistory?[indexPath.row].latitude
        cell.logidudeLbl.text = locationHistory?[indexPath.row].longitude
        cell.locationLbl.text = locationHistory?[indexPath.row].location
        cell.selectionStyle = .none
        return cell
    }
    
    @IBAction func Edit(ges : Deleteclick){
        
        let alertController = UIAlertController(title: "Update", message: "Please enter your details", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your location name"
            textField.text = ges.location
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your distance"
            textField.text = ges.distance
        }
        let confirmAction = UIAlertAction(title: "Update", style: .default) { [self] (_) in
            if let location = alertController.textFields?[0].text, let distance = alertController.textFields?[1].text {
                print("location Name: \(location)")
                print("distance Name: \(distance)")
                if distance != "" && location != ""{
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
    
    @IBAction func deletClick(ges : Deleteclick){
        let refreshAlert = UIAlertController(title: "", message: "Are you sure do you want to delete this Loacation", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
            if #available(iOS 15.0, *) {
                showLottieProgressLoader(animationName: "loader (2)")
            }
            
            APIService.shared.makeApi(
                url: ServiceUrl.staff_attd_geometric_remove_geometric_location,
                parameters: ["location_id":ges.deleteID ?? 0],
                type: ApitTypeSringFile.GET,
                token:staffDetails?.access_token ?? ""
            ) { [weak self] (result: Result<StaffGeometricLocation, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self?.hideLottieProgressLoader()
                    }
                    
                    switch result {
                    case .success(let response):
                        self?.tv.reloadData()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.staff_attd_geometric_get_geometric_location_history,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<StaffGeometricLocation, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    self?.locationHistory = response.data
                    self?.tv.reloadData()
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


