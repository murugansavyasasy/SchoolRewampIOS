//
//  StaffPtmViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
//import ObjectMapper
@available(iOS 14.0, *)
class StaffPtmViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, Datepicker, ShowPopupDelegate, UIPopoverPresentationControllerDelegate {
    func showPopup(sender: UIButton) {
        let popoverContentVC = PopupVC(nibName: nil, bundle: nil)
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.preferredContentSize = CGSize(width: 150, height: 100)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
        }
        
        // For iPhones: Present as a pop-up instead of full-screen
        if UIDevice.current.userInterfaceIdiom == .phone {
            popoverContentVC.modalPresentationStyle = .overFullScreen
            popoverContentVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3) // Optional dim effect
        }
        
        self.present(popoverContentVC, animated: true, completion: nil)
    }
    
    func date(date: String) {
        let dateFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        
        // Set the input date format that matches "19 Feb 25"
        dateFormatter.dateFormat = "d MMM yy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // Ensures correct parsing
        
        // Convert string to Date
        guard let parsedDate = dateFormatter.date(from: date) else {
            print("Invalid date format: \(date)")
            return
        }
        
        // Set the output format for weekday and day (e.g., "Mon 19")
        dateOnlyFormatter.dateFormat = "EEE d"
        let dateOnly = dateOnlyFormatter.string(from: parsedDate)
        
        // Pass formatted values to dateSet
        dateSet(date, dateOnly, dateOnly)
        tv.reloadData()
    }
    
    
    
    
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var Backbtn: UIButton!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var calanderBtn: HalfColorButton!
    @IBOutlet weak var nodatalabl: UILabel!
    @IBOutlet weak var slotView: UIView!
    @IBOutlet weak var todaSlotView: UIView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var AllslotsLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet weak var TodaysBookedSlotsLbl: UILabel!
    var instituteId  = Int()
    var sectionId = Int()
    var staffId  = Int()
    var studentId  = Int()
    var classId  = Int()
    var display_date : String!
    var url_date : String!
    var CustomOrange = "AppDark"
    var type : Int!
    var SchoolId : String!
    var lastContentOffset: CGFloat = 0
    var isButtonHidden: Bool = false
    var collectionViewCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        Backbtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        Backbtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        Backbtn.imageView?.applyRTLFlip(Language == "ar")
    
        todaSlotView.applyGradient(
            colors: [UIColor.blue,UIColor.systemTeal],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        TodaysBookedSlotsLbl.textColor = .white
        AllslotsLbl.textColor = .gray
        tv.register(UINib(nibName: CellConfingName.StaffPtmTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.StaffPtmTableViewCell)
        let rownib2 = UINib(nibName: CellConfingName.SlotHeader, bundle: nil)
        tv.register(rownib2, forHeaderFooterViewReuseIdentifier: CellConfingName.SlotHeader)
        nodatalabl.isHidden = true
        calanderBtn.layer.borderWidth = 1 // Border width
        calanderBtn.layer.borderColor = UIColor.gray.cgColor // Border color
        calanderBtn.layer.cornerRadius = 10 // Add
        let create  = UITapGestureRecognizer(target: self , action:#selector(cretaeVC) )
        createView.addGestureRecognizer(create)
        
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
        setInitialButtonTitles()
    }
    //MARK: BUTTON TITLE CURRANT TIME
    func setInitialButtonTitles() {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        
        // Set the date format (e.g., "Tue 3 Dec 2024")
        dateFormatter.dateFormat = "d MMM yy"
        dateOnlyFormatter.dateFormat = "EEE d"
        
        // Set the time format (e.g., "4:30 PM")
        timeFormatter.timeStyle = .short
        
        // Get the current date and time
        let currentDate = Date() // Current date and time
        let nextHourTime = Calendar.current.date(byAdding: .hour, value: 0, to: currentDate) ?? currentDate
        
        // Format the date and time
        let formattedDate = dateFormatter.string(from: currentDate)   // "Tue 3 Dec 2024"
        let formattedTime = timeFormatter.string(from: nextHourTime)  // "4:30 PM"
        let dateOnly = dateOnlyFormatter.string(from: nextHourTime)   // "Tue 3"
        
        // Set the date and time to the date button
        dateSet(formattedDate, dateOnly,dateOnly)
    }
    func dateSet(_ date: String, _ splitDate: String, _ currentDate: String) {
        // Fonts for different parts
        let monthFont = UIFont.systemFont(ofSize: 12) // Smaller font for month
        let dayFont = UIFont.boldSystemFont(ofSize: 22) // Larger font for day number
        
        // Split the date into components (Expecting "Feb 26")
        let components = splitDate.split(separator: " ")
        guard components.count > 1 else {
            print("Error: Invalid format for splitDate -> \(splitDate)")
            return
        }
        
        let month = components[0] // Extract the month first
        let day = components[1]   // Extract the day
        
        // Create an attributed string
        let attributedText = NSMutableAttributedString()
        
        // Add the month part
        attributedText.append(NSAttributedString(string: "\(month)\n", attributes: [
            .font: monthFont,
            .foregroundColor: UIColor.darkGray // Optional: Set month color
        ]))
        
        // Add the day part
        attributedText.append(NSAttributedString(string: "\(day)", attributes: [
            .font: dayFont,
            .foregroundColor: UIColor.black // Optional: Set day color
        ]))
        
        // Set paragraph style for centered alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        // Apply the attributed string to `toDateLbl`
        toDateLbl.attributedText = attributedText
    }
    
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    
    @IBAction func slotSelection(_ sender: UISegmentedControl) {
        configureSegmentedControlText(sender)
        if sender.selectedSegmentIndex == 0 {
            createView.isHidden = false
            dateLbl.text = "--- Select Date ---"
            todaSlotView.applyGradient(
                colors: [UIColor.blue,UIColor.systemTeal],
                startPoint: CGPoint(x: 0, y: 0.5),
                endPoint: CGPoint(x: 0.8, y: 0.5)
            )
            slotView.applyGradient(
                colors: [UIColor.systemGray6,UIColor.systemGray6],
                startPoint: CGPoint(x: 0, y: 0.5),
                endPoint: CGPoint(x: 0.8, y: 0.5)
            )
            TodaysBookedSlotsLbl.textColor = .white
            AllslotsLbl.textColor = .gray
            
            tv.reloadData()
        } else if sender.selectedSegmentIndex == 1 {
            createView.isHidden = true
            dateLbl.text = "--- Select Date ---"
            display_date = "ALL"
            
            slotView.applyGradient(
                colors: [UIColor.blue,UIColor.systemTeal],
                startPoint: CGPoint(x: 0, y: 0.5),
                endPoint: CGPoint(x: 0.8, y: 0.5)
            )
            todaSlotView.applyGradient(
                colors: [UIColor.systemGray6,UIColor.systemGray6],
                startPoint: CGPoint(x: 0, y: 0.5),
                endPoint: CGPoint(x: 0.8, y: 0.5)
            )
            TodaysBookedSlotsLbl.textColor = .gray
            AllslotsLbl.textColor = .white
            
            tv.reloadData()
        }
    }
    func configureSegmentedControlText(_ segmentedControl: UISegmentedControl) {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkGray, // Text color for unselected segments
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue.withAlphaComponent(0.7), // Text color for selected segment
            .font: UIFont.systemFont(ofSize: 13, weight: .bold)
        ]
        
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    @IBAction func SelectDate(_ sender:UIButton){
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func backVC(){
        dismiss(animated: true)
    }
    
    @IBAction func cretaeVC(){
        let vc = SltoCreationViewController(nibName: nil, bundle: nil)
        vc.instute = Int(instituteId)
        vc.staffId = staffId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func  TodaySlotVC (){
        createView.isHidden = false
        dateLbl.text = "--- Select Date ---"
        todaSlotView.applyGradient(
            colors: [UIColor.blue,UIColor.systemTeal],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        slotView.applyGradient(
            colors: [UIColor.systemGray6,UIColor.systemGray6],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        TodaysBookedSlotsLbl.textColor = .white
        AllslotsLbl.textColor = .gray
        
        tv.reloadData()
    }
    
    @IBAction func  SlotVC (){
        createView.isHidden = true
        dateLbl.text = "--- Select Date ---"
        display_date = "ALL"
        
        slotView.applyGradient(
            colors: [UIColor.blue,UIColor.systemTeal],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        todaSlotView.applyGradient(
            colors: [UIColor.systemGray6,UIColor.systemGray6],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        TodaysBookedSlotsLbl.textColor = .gray
        AllslotsLbl.textColor = .white
        
        tv.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if  slotView.backgroundColor == UIColor(named: CustomOrange){
            return 1
        }else if todaSlotView.backgroundColor == .systemOrange{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  AllslotsLbl.textColor == .white{
            return UITableView.automaticDimension
        }else  if  todaSlotView.backgroundColor == .systemOrange{
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  slotView.backgroundColor == .systemOrange{
            return 1
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.StaffPtmTableViewCell, for: indexPath) as! StaffPtmTableViewCell
        cell.selectionStyle = .none
        
        cell.statusview.layer.masksToBounds = true
        cell.backView.layer.cornerRadius = 10
        cell.backView.layer.shadowColor = UIColor.black.cgColor
        cell.backView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.backView.layer.shadowRadius = 5
        cell.backView.layer.shadowOpacity = 0.3
        cell.statusview.layer.shadowColor = UIColor.white.cgColor
        cell.statusview.layer.shadowOpacity = 0.5
        cell.statusview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cell.statusview.layer.shadowRadius = 5
        cell.statusview.layer.masksToBounds = false
        cell.showpopup = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.SlotsCollectionViewCell, for: indexPath) as! SlotsCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: 50) // Adjust item size as needed
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
    
}
class linkClick : UITapGestureRecognizer{
    
    var link  : String!
    var slotid : Int!
    
}
