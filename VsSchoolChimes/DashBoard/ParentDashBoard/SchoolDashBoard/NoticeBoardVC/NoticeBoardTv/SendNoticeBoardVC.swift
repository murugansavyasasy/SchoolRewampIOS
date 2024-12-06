//
//  SendNoticeBoardVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 03/12/24.
//

import UIKit

class SendNoticeBoardVC: UIViewController {
    
    @IBOutlet weak var fromDteLabel: UILabel!
    @IBOutlet weak var fromCalenderBtn: HalfColorButton!
    
    @IBOutlet weak var ToCalenderBtn: HalfColorButton!
    @IBOutlet weak var TodateLbl: UILabel!
    
    @IBOutlet weak var SubHeader: UILabel!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var FromDateBtn: UIButton!
    @IBOutlet weak var TodateBtn: UIButton!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var titleTxtFld: UITextField!
    @IBOutlet weak var DescTxtView: UITextView!
    @IBOutlet weak var LetterCountLbl: UILabel!
    @IBOutlet weak var AddPhotoLbl: UILabel!
    @IBOutlet weak var SelectImgview: ImageSelection!
    @IBOutlet weak var SubmitBtn: UIButton!
    
    var datePicker : UIDatePicker!
    var doneButton : UIButton!
    var dateselection = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatepicker()
        StyleAndTranslater()
        

        fromDteLabel.textColor = .black

       
    }
    
    func StyleAndTranslater() {
        
        //MARK: UI Update
        DescTxtView.layer.cornerRadius = Colornames.CORadius10
        DescTxtView.layer.borderWidth = 1
        DescTxtView.layer.borderColor = UIColor.black.cgColor
        
        //MARK: Translate
        
        //MARK: Font Style
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        TitleLabel.setFont(style: .title, size: FontSize.TitleSize)
        LetterCountLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        AddPhotoLbl.setFont(style: .title, size: FontSize.TitleSize)
        fromDteLabel.setFont(style: .body, size: FontSize.BodySize)
        TodateLbl.setFont(style: .body, size: FontSize.BodySize)
        
        FromDateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TodateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        SubmitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
    }


    @IBAction func SetToDate(_ sender: Any) {
        dateselection = false
        showDatepicker(button: sender as! UIButton)
        
    }
    @IBAction func SetFromDate(_ sender: Any) {
        
        dateselection = true
        showDatepicker(button: sender as! UIButton)
    }
    
    
    @IBAction func FromCalenderAct(_ sender: Any) {
        
        dateselection = true
        showDatepicker(button: sender as! UIButton)
    }
    
    @IBAction func ToCalenderAct(_ sender: Any) {
        
        dateselection = false
        showDatepicker(button: sender as! UIButton)
    }
    
    @IBAction func SubmitAct(_ sender: Any) {
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func createDatepicker(){
          datePicker = UIDatePicker()
          datePicker.datePickerMode = .date
          datePicker.minimumDate = Date()
          datePicker.backgroundColor = .white
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        
        datePicker.isHidden = true
        self.view.addSubview(datePicker!)
        
        // Initialize and configure Done button
        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        doneButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.view.addSubview(doneButton)
        
      }
    
    func showDatepicker(button: UIButton) {
        datePicker.isHidden = false
        doneButton.isHidden = false
        
        let buttonFrame = button.convert(button.bounds, to: self.view)
        
        // Set the frame for the datePicker
        let pickerYPosition = buttonFrame.maxY + 10
        datePicker.frame = CGRect(x: (self.view.frame.width - 300) / 2, y: pickerYPosition, width: 300, height: 300)
        
        // Set appearance for datePicker
        datePicker.backgroundColor = .white
        datePicker.layer.shadowColor = UIColor.black.cgColor
        datePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        datePicker.layer.shadowRadius = 5
        datePicker.layer.shadowOpacity = 0.3
        datePicker.layer.cornerRadius = 20
        
        doneButton.frame = CGRect(x: datePicker.frame.maxX - 80, y: pickerYPosition + datePicker.frame.height - 40, width: 70, height: 30)

        // Add both datePicker and Done button to the view
        self.view.addSubview(datePicker)
        self.view.addSubview(doneButton)
    }

    @IBAction func doneButtonTapped(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "EEE d MMM yyyy"
        let datelabel = dateFormatter.string(from: datePicker.date)
        
        if dateselection == true {
           var fromdate = datePicker.date
            //if fromdate
            FromDateBtn.setTitle(datelabel, for: .normal)
            datePicker.minimumDate = datePicker.date
        }
        else{
            
            var todate = datePicker.date
            TodateBtn.setTitle(datelabel, for: .normal)
        }
        
        datePicker.isHidden = true
        doneButton.isHidden = true
    }
    
}
