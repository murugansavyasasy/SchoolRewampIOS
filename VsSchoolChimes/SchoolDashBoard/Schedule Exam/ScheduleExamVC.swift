//
//  ScheduleExamVC.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//

import UIKit

class ScheduleExamVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, ScheduleDelegate {
    
    @IBOutlet weak var subjectListCollection: UICollectionView!
    @IBOutlet weak var tilteLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var examArray :[ExamsSchedule]?
    var filterData : [ExamsSchedule]?
    var finalArray = [ExamsSchedule]()
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardDionebtn()
        filterData = examArray
        subjectListCollection.register(UINib(nibName: CellConfingName.ExamsListCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ExamsListCVCell)
        tilteLbl.setFont(style: .header, size: FontSize.HeaderSize)
        tilteLbl.text = CommonStringFile.scheduleExam.translated()
        searchBar.placeholder = CommonStringFile.Search.translated()
    }
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: AlertstringFile.Done, style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        searchBar.inputAccessoryView = toolbar
    }
    @objc func doneKeyboard() {
        view.endEditing(true)
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ExamsListCVCell, for: indexPath) as! ExamsListCVCell
        let exam = filterData?[indexPath.item]
        cell.imgView.image = UIImage(named: exam?.imageName ?? "")
        cell.examSchedul = filterData
        cell.subjectName.text = exam?.subjectName
        cell.subName = exam?.subjectName
        cell.deletBtn.tag = indexPath.item
        cell.scheduDelegate = self
        cell.finalArray = finalArray
        cell.deletBtn.isHidden = !(exam?.isSelected ?? false)
        if exam?.isSelected == false{
            cell.outerView.layer.borderColor = UIColor.clear.cgColor
            cell.outerView.layer.borderWidth = 0
        }else{
            cell.outerView.layer.borderColor = UIColor.green.cgColor
            cell.outerView.layer.borderWidth = 1
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 20 // total spacing between items
        let screenWidth = collectionView.frame.width
        let numberOfItemsPerRow: CGFloat = 2 // You can change this to 2 or 3 as required
        let availableWidth = screenWidth - (itemSpacing * (numberOfItemsPerRow - 1))
        let cellWidth = availableWidth / numberOfItemsPerRow
        
        // Get the subject name for the current index
        guard let subjectName = filterData?[indexPath.item].subjectName else {
            // Default size when subject name is not available
            return CGSize(width: cellWidth, height: 150) // Default height if no subject name is available
        }
        
        // Calculate the dynamic height of the label
        let font = UIFont.systemFont(ofSize: 16) // Set the same font used in the label
        let labelWidth = cellWidth - 32 // Subtract padding/margins if needed
        let labelHeight = calculateLabelHeight(text: subjectName, font: font, width: labelWidth)
        
        // Add extra height for the image, margins, and other views
        let imageHeight: CGFloat = 100 // Assume 100 for the image, can be adjusted
        let verticalPadding: CGFloat = 20 // Padding between elements inside the cell
        let totalHeight = labelHeight + imageHeight + verticalPadding
        
        return CGSize(width: cellWidth, height: totalHeight)
    }
    
    // Helper function to calculate label height dynamically
    func calculateLabelHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let exam = filterData?[indexPath.item]{
            guard let cell = collectionView.cellForItem(at: indexPath) as? ExamsListCVCell else { return }
            
            UIView.transition(
                with: cell.outerView,
                duration: 0.3,
                options: ((filterData?[indexPath.row].isSelected) != nil) ? .transitionFlipFromLeft : .transitionFlipFromRight,
                animations: {
                    // Add any changes you want to animate, like updating subviews or labels
                },
                completion: nil
            )
            
            let vc = SchedulePopupVC(nibName: nil, bundle: nil)
            vc.index = indexPath.item
            vc.finalArray = finalArray
            if filterData?[indexPath.row].isSelected == true {
                if let index = finalArray.firstIndex(where: { $0.subjectName ==  filterData?[indexPath.row].subjectName }) {
                    vc.examSchedul = self.finalArray[index]
                }
            }else{
                vc.examSchedul = filterData?[indexPath.row]
            }
            
            vc.scheduDelegate = self
            vc.modalPresentationStyle = .overCurrentContext
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.present(vc, animated: false)
            
        }
        
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        for i in 0..<(finalArray.count){
            print(finalArray[i])
        }
    }
    
    func schedulSubject(ExamsSchedule: [ExamsSchedule], delete: Bool,index:Int) {
        if delete == false {
            finalArray = ExamsSchedule
            filterData?[index].isSelected = true
            subjectListCollection.reloadData()
        } else {
            let alert = CustomAlert()
            alert.showAlertCancel(title: "Do you want to remove",
                                  message: "Already Scheduled. Please Remove it first.",
                                  actionLbl1: "Confirm",
                                  actionLbl2: "Cancel",
                                  on: self) {
                
                self.finalArray = ExamsSchedule
                self.filterData?[index].isSelected = false
                self.subjectListCollection.reloadData()
            } onNo: {
                print("User canceled the action")
            }
        }
    }
    
}
@available(iOS 14.0, *)
extension ScheduleExamVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Reset to full data when the search text is cleared
            filterData = examArray
        } else {
            // Filter data based on the search text
            filterData = examArray?.filter { student in
                student.subjectName.lowercased().contains(searchText.lowercased())
            }
        }
        subjectListCollection.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func addDoneButton(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(DoneBtnAct))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        searchBar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        searchBar.resignFirstResponder()
    }
}
struct ExamsSchedule {
    var subjectName: String
    var subjectSyllabus: String
    var date: String
    var mark: String
    var imageName: String
    var session: String
    var isSelected: Bool
}
