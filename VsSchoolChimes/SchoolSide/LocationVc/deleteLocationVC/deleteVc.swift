//
//  deleteVc.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 02/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper
class deleteVc: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noRecLbl: UILabel!
    
    var identifier = "deleteTV"
    
    var InstitudeId : Int!
    var userId : Int!
    @IBOutlet weak var backView: UIView!
    var getdata : [GetLatModaldataDetails] = []
    
    @IBOutlet weak var tv: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        noRecLbl.isHidden = true
        let rowNib = UINib(nibName: identifier, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: identifier)
        let gifImage = UIImage.gifImageWithName("Map Location")
        //
        imageView.image = gifImage
        let back  = UITapGestureRecognizer(target: self, action: #selector(backViewss))
        backView.addGestureRecognizer(back)
        standerAndSec()
    }

    
    @IBAction func backViewss(){
        
        dismiss(animated: true)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getdata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as!
        deleteTV
        
        cell.selectionStyle = .none
        let data : GetLatModaldataDetails = getdata[indexPath.row]
        
       
        cell.logidudeLbl.text = data.longitude + " - " + data.latitude
        cell.locationLbl.text = data.location
        cell.distanceLbl.text =  "Distance" +  " - " +  data.distance + "Meters"

        let deleteImage = Deleteclick(target: self, action: #selector(deletClick))
        deleteImage.deleteID = data.id
        cell.deleteImageView.addGestureRecognizer(deleteImage)
        let editImages = Deleteclick(target: self, action: #selector(Edit))
      
        editImages.deleteID = data.id
        editImages.distance = data.distance
        editImages.location = data.location
        cell.editImageView.addGestureRecognizer(editImages)
     
        return cell
        
        
        
      
        
      
        
    }
    
    
    
    @IBAction func Edit(ges : Deleteclick){
        
        
        let alertController = UIAlertController(title: "Update", message: "Please enter your details", preferredStyle: .alert)
                
                // Add the first text field
                alertController.addTextField { (textField) in
                    textField.placeholder = "Enter your location name"
                    textField.text = ges.location
                }
                
                // Add the second text field
                alertController.addTextField { (textField) in
                    textField.placeholder = "Enter your distance"
                    textField.text = ges.distance
                }
                
                // Create the actions (OK and Cancel)
        let confirmAction = UIAlertAction(title: "Update", style: .default) { [self] (_) in
                    // Retrieve the text from the two text fields
                    if let location = alertController.textFields?[0].text, let distance = alertController.textFields?[1].text {
                        print("location Name: \(location)")
                        print("distance Name: \(distance)")
                        
                        
                        if distance != "" && location != ""{
                            
                            
                            edit(Id: ges.deleteID, Distance: distance, Location: location)
                        }else{
                            
                            let refreshAlert = UIAlertController(title: "", message: "Location or distance field is empty", preferredStyle: UIAlertController.Style.alert)
        
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                           
                            }))
                        present(refreshAlert, animated: true, completion: nil)
                            
                        }
                  
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                // Add the actions to the alert
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                // Present the alert
                self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func deletClick(ges : Deleteclick){
        
        
        let refreshAlert = UIAlertController(title: "", message: "Are you sure do you want to delete this Loacation", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in


      
            deletApi(LocationId : ges.deleteID)
      
        }))


        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        print("Handle Cancel Logic here")
        }))

        present(refreshAlert, animated: true, completion: nil)

        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    
    func standerAndSec(){
        
       
        
        let param : [String : Any] =
        [

            "institute_id": InstitudeId!


        ]

        print("paramparam",param)

        GetLocationReq.call_request(param: param){ [self]
            (res) in

            print("resres",res)
            let getLocationResponse : getLatModel = Mapper<getLatModel>().map(JSONString: res)!


            if getLocationResponse.status == 1  {
              
                getdata = getLocationResponse.data
                
                if getdata.count == 0{
                    
                   
                    noRecLbl.isHidden = false
                    noRecLbl.text = "No record found."
                }else{
                    
                    noRecLbl.isHidden = true
                    
                }
                tv.isHidden  = false
                tv.dataSource = self
                tv.delegate = self
                tv.reloadData()

            }else{
                tv.isHidden  = true
                noRecLbl.isHidden = false
                noRecLbl.text = getLocationResponse.message
            }
        }
        
        
    }
    
    func  deletApi(LocationId : Int){
        
        
        
        let delet = deleteModal()
        
        delet.instituteId = InstitudeId
        delet.locationId = LocationId
        
        var deletstr = delet.toJSONString()
        
        
        DeleteRequest.call_request(param: deletstr!) {
        
                        [self] (res) in
        
                        let addLocationResp : punchResponce = Mapper<punchResponce>().map(JSONString: res)!
        
                        if addLocationResp.status == 1 {
        
                            noRecLbl.isHidden = true
                            
                            let refreshAlert = UIAlertController(title: "", message: addLocationResp.message, preferredStyle: UIAlertController.Style.alert)
        
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                                standerAndSec()
                            
                                
                                
                            }))
                        present(refreshAlert, animated: true, completion: nil)
                        }else{
        
                            
                            noRecLbl.isHidden = true
                            
                            let refreshAlert = UIAlertController(title: "", message: addLocationResp.message, preferredStyle: UIAlertController.Style.alert)
        
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
        
                          
                                
                                
                            }))
                        present(refreshAlert, animated: true, completion: nil)
                        }
        
        
        
                    }
    }
    
    
    func  edit(Id : Int,Distance : String,Location : String){
        
        
        
        let edit = EditLocModal()
        
        
        edit.id = Id
        edit.distance = Distance
        edit.location = Location
        edit.userId = userId
        
    
        
        var editstr = edit.toJSONString()
        
        
        EditLocrequest.call_request(param: editstr!) {
        
                        [self] (res) in
        
                        let addLocationResp : EditLocResponce = Mapper<EditLocResponce>().map(JSONString: res)!
        
                        if addLocationResp.status == 1 {
        
                            noRecLbl.isHidden = true
                            
                            let refreshAlert = UIAlertController(title: "", message: addLocationResp.message, preferredStyle: UIAlertController.Style.alert)
        
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                                standerAndSec()
                            
                                
                                
                            }))
                        present(refreshAlert, animated: true, completion: nil)
                        }else{
        
                            
                            noRecLbl.isHidden = true
                            
                            let refreshAlert = UIAlertController(title: "", message: addLocationResp.message, preferredStyle: UIAlertController.Style.alert)
        
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
        
                          
                                
                                
                            }))
                        present(refreshAlert, animated: true, completion: nil)
                        }
        
        
        
                    }
    }
    
    
    
}

class Deleteclick : UITapGestureRecognizer{
    
    var deleteID : Int!
    var location : String!
    var distance : String!
    
}
