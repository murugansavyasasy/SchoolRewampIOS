//
//  CreateLocationViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import DropDown
import ObjectMapper
class CreateLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backView: UIView!
   
    @IBOutlet weak var distancetxtFldHeight: NSLayoutConstraint!
    @IBOutlet weak var tapToView: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var ImpoartPaghLbl: UILabel!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var loactiontextfiled: UITextField!
    @IBOutlet weak var distanceTextfiled: UITextField!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var distanceDropDownView: UIViewX!
    @IBOutlet weak var adressStackview: UIStackView!
    @IBOutlet weak var yuouraddressHeight: NSLayoutConstraint!
    
    @IBOutlet weak var submitview: UIViewX!
    @IBOutlet weak var currentlatAndlongDefltLbl: UILabel!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var latiAndLongiView: UIViewX!
    @IBOutlet weak var getLongiAndLatHeigh: NSLayoutConstraint!
    @IBOutlet weak var latLongLbl: UILabel!
    @IBOutlet weak var imageGif: UIImageView!
    let dropDown = DropDown()
    var latitude = ""
    var longitude = ""
    var InstitudeId : Int!
    var refrenceAddress = ""
    var userId : Int!
    
    let firstParagraph = """
    Accurate location settings are crucial for ensuring that attendance is only marked when users are within the designated area of the institute. Please double-check the location before submitting.
    """

    let secondParagraph = """
    Once saved, this location will be used to verify the proximity of users when they mark their attendance. Ensure that the location is correct as it will directly impact attendance functionality.
    """
    

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addDoneButtonOnKeyboard()
       
        let combinedText = "\(firstParagraph)\n\n\(secondParagraph)"

        let attributedString = NSMutableAttributedString(string: combinedText)

        // Apply custom formatting if needed
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

        // Set the attributed text to the label
        ImpoartPaghLbl.attributedText = attributedString

        // Optionally, adjust the label's number of lines to allow for multiple lines
        ImpoartPaghLbl.numberOfLines = 0
        addressLbl.text = refrenceAddress
        latLongLbl.text = latitude + " - " + longitude
        getLongiAndLatHeigh.constant = 0
        cvHeight.constant = 0
        loactiontextfiled.delegate = self
        distanceTextfiled.delegate = self
        distanceTextfiled.keyboardType = .numberPad
        distanceTextfiled.text = "10"
     
        let gifImage = UIImage.gifImageWithName("Map Location")
        //
        imageGif.image = gifImage
       
        let clickgtLat = UITapGestureRecognizer(target: self, action: #selector(latlong))
        latiAndLongiView.addGestureRecognizer(clickgtLat)
        let distancDrop = UITapGestureRecognizer(target: self, action: #selector(distance))
        distanceDropDownView.addGestureRecognizer(distancDrop) 
        
        let submitView = UITapGestureRecognizer(target: self, action: #selector(submitView))
        submitview.addGestureRecognizer(submitView)  
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTonext))
        tapToView.addGestureRecognizer(tap)
      
        
        let back = UITapGestureRecognizer(target: self, action: #selector(backclick))
        backView.addGestureRecognizer(back)
      
    }
    
    @IBAction func backclick(){
        
        dismiss(animated: true)
        
        
    }
    
    func addDoneButtonOnKeyboard(){
    let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    doneToolbar.barStyle = .default

    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

    let items = [flexSpace, done]
    doneToolbar.items = items
    doneToolbar.sizeToFit()

        distanceTextfiled.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        distanceTextfiled.resignFirstResponder()
    }
    @IBAction func tapTonext(){
        
        let vc = deleteVc(nibName: nil, bundle: nil)
        vc.InstitudeId  = InstitudeId
        vc.userId = userId
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
    @IBAction func submitView(){
        var textConver  = Int(distanceTextfiled.text!)
//        var a = 10
//        print("textConver",textConver)
        if loactiontextfiled.text == "Pin your loaction name" || loactiontextfiled.text == ""{
            
            let refreshAlert = UIAlertController(title: "", message: "Enter your location", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
            
        }
        
        
        else if  9 >= textConver!  {
            
            let refreshAlert = UIAlertController(title: "", message: "Distance Should be 10 Or above 10Meters", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
            
            
            
        }
        else{
            
            
            let refreshAlert = UIAlertController(title: "Hold on!", message: "Are you sure you want to add this Location?", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [self] (action: UIAlertAction!) in
                
                AddLocation()
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
            
            
           
        }
       
        
    }

    @IBAction func latlong(){
        
        print("hiiiii")
        if loactiontextfiled.text == "Pin your loaction name" || loactiontextfiled.text == ""{
            
            let refreshAlert = UIAlertController(title: "", message: "Enter your location", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
            
        }
        
        else{
            
            
//            currentlatAndlongDefltLbl.isHidden = false
//            submitview.isHidden = false
//         
//            adressStackview.isHidden = false
//            yuouraddressHeight.constant = 22.33
//            bottomViewHeight.constant = 133.66
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder() // Dismiss the keyboard
           return true
       }
   
    @IBAction func distance(){
        let myArray = [ "20","30","40","50","60","70","80","90","100"]
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = distanceDropDownView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            distanceLbl.text = item
            distanceTextfiled.text = item
           
        }
    }
    

    
    
    func AddLocation(){
        
                    let addLocationModal = AddloactionModal()
        
        addLocationModal.instituteId = InstitudeId
        addLocationModal.latitude = latitude
        addLocationModal.longitude = longitude
        addLocationModal.location = loactiontextfiled.text!
        addLocationModal.userId = userId
        
        addLocationModal.distance = Int(distanceTextfiled.text!)
        
                    var  addLocationModalStr = addLocationModal.toJSONString()
                    print("punchModalStr",addLocationModal.toJSON())
        
        
        LocationRequest.call_request(param: addLocationModalStr!) {
        
                        [self] (res) in
        
                        let addLocationResp : punchResponce = Mapper<punchResponce>().map(JSONString: res)!
        
                        if addLocationResp.status == 1 {
        
                            let refreshAlert = UIAlertController(title: "", message: addLocationResp.message, preferredStyle: UIAlertController.Style.alert)
        
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
        
                              dismiss(animated: true)
                                
                                
                            }))
                        present(refreshAlert, animated: true, completion: nil)
                        }else{
        
                            
                            
                            
                            let refreshAlert = UIAlertController(title: "", message: addLocationResp.message, preferredStyle: UIAlertController.Style.alert)
        
                            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
        
                              dismiss(animated: true)
                                
                                
                            }))
                        present(refreshAlert, animated: true, completion: nil)
                        }
        
        
        
                    }
        
        
    }
   
  
}

   

