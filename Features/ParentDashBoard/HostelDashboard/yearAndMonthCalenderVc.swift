//
//  yearAndMonthCalenderVc.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/03/26.
//

import UIKit

class yearAndMonthCalenderVc: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var yearCollectionView: UICollectionView!
    @IBOutlet weak var monthCollectionView: UICollectionView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var monthCVHeight: NSLayoutConstraint!
    @IBOutlet weak var selectYearDefLbl: UILabel!
    @IBOutlet weak var selectMonthDefLbl: UILabel!
    
    var months: [MonthItem] = []
    var years: [String] = []
    var selectdMonth: MonthItem?
    var onDateSelected: ((MonthItem) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap(_:)))
        tapGesture.cancelsTouchesInView = false // IMPORTANT
        view.addGestureRecognizer(tapGesture)
        
        popupView.layer.cornerRadius = 6
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = UIColor.lightGray.cgColor
        
        closeBtn.layer.cornerRadius = 8
        closeBtn.layer.borderWidth = 1
        closeBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        selectYearDefLbl.setFont(style: .body, size: 17)
        selectMonthDefLbl.setFont(style: .body, size: 17)
        closeBtn.setTitleFont(style: .body, size: 15)
        
        monthCollectionView.delegate = self
        monthCollectionView.dataSource = self
        yearCollectionView.delegate = self
        yearCollectionView.dataSource = self
        
        monthCollectionView.register(UINib(nibName: "SessionStatusCell", bundle: nil), forCellWithReuseIdentifier: "SessionStatusCell")
        yearCollectionView.register(UINib(nibName: "SessionStatusCell", bundle: nil), forCellWithReuseIdentifier: "SessionStatusCell")
        
        generateMonths(for: selectdMonth?.year ?? Calendar.current.component(.year, from: Date()))
    }
    
    func generateMonths(for year: Int){
        let calendar = Calendar.current
        let fullNames = calendar.monthSymbols
        let shortNames = calendar.shortMonthSymbols
        
        var tempMonths: [MonthItem] = []
        
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        let maxMonth = (year == currentYear) ? currentMonth : 12
        
        for i in 0..<maxMonth {
            
            let monthNumber = i + 1
            
            let isSelected = (
                selectdMonth?.year == year &&
                selectdMonth?.monthNumber == monthNumber
            )
            
            let month = MonthItem(
                id: monthNumber,
                name: fullNames[i],
                shortName: shortNames[i],
                monthNumber: monthNumber,
                year: year,
                isSelected: isSelected
            )
            
            tempMonths.append(month)
        }
        
        self.months = tempMonths
        let height = ceil(Double((months.count) / 3)) * 45.0
        monthCVHeight.constant = CGFloat(height)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        monthCollectionView.reloadData()
        yearCollectionView.reloadData()
    }
    
    @IBAction func handleOutsideTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        // If tap is outside popupView → dismiss
        if !popupView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    @IBAction func closeBtnAct(_ sender: Any) {
        
        if let selected = selectdMonth {
            onDateSelected?(selected)
        }
        
        dismiss(animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionView == yearCollectionView ? years.count : months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "SessionStatusCell", for: indexPath) as! SessionStatusCell
        
        cell.cellView.isHidden = false
        
        if collectionView == monthCollectionView {
            
            cell.yearMonthLbl.text = months[indexPath.row].name
            
            if selectdMonth?.monthNumber == months[indexPath.row].monthNumber &&
                selectdMonth?.year == months[indexPath.row].year {
                
                cell.cellView.backgroundColor = .parentClr
                cell.yearMonthLbl.textColor = .white
            } else {
                cell.cellView.backgroundColor = .white
                cell.yearMonthLbl.textColor = .black
            }
            
        }else{
            
            cell.yearMonthLbl.text = years[indexPath.row]
            
            if String(selectdMonth?.year ?? 0) == years[indexPath.row] {
                cell.cellView.backgroundColor = .parentClr
                cell.yearMonthLbl.textColor = .white
            }else{
                cell.cellView.backgroundColor = .white
                cell.yearMonthLbl.textColor = .black
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == yearCollectionView {
            
            let selectedYear = Int(years[indexPath.row]) ?? 0
            
            // Update year but keep same month if possible
            let currentMonthNumber = selectdMonth?.monthNumber ?? 1
            
            generateMonths(for: selectedYear)
            
            // Try to reselect same month in new year
            if let index = months.firstIndex(where: { $0.monthNumber == currentMonthNumber }) {
                selectdMonth = months[index]
            } else {
                selectdMonth = months.first // fallback
            }
            
            yearCollectionView.reloadData()
            monthCollectionView.reloadData()
            
        } else {
            
            // Only update selection locally
            selectdMonth = months[indexPath.row]
            monthCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == yearCollectionView {
            let width:CGFloat = (collectionView.frame.width/4)
            return CGSize(width: width, height: 45)
        }else{
            let width:CGFloat = (collectionView.frame.width/3)
            return CGSize(width: width, height: 45)
        }
    }
}


struct MonthItem {
    let id: Int
    let name: String
    let shortName: String
    let monthNumber: Int
    let year: Int
    var isSelected: Bool
}
