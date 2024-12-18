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
    
    var examArray = [
        ExamsSchedule(subjectName: "Commerce", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Computer_Command sdsfd", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "English", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Ezee Notes", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Math_Lab", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Physics", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Tamil", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Chemistry", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false)
    ]
    var filterData : [ExamsSchedule]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjectListCollection.register(UINib(nibName: CellConfingName.ExamsListCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ExamsListCVCell)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return examArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ExamsListCVCell, for: indexPath) as! ExamsListCVCell
        let exam = examArray[indexPath.item]
        
        cell.imgView.image = UIImage(named: exam.imageName)
        cell.examSchedul = examArray
        cell.subjectName.text = exam.subjectName
        cell.deletBtn.tag = indexPath.item
        cell.scheduDelegate = self
        cell.deletBtn.isHidden = !exam.isSelected
        if exam.isSelected == false{
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
        let subjectName = examArray[indexPath.item].subjectName
        
        // Calculate the dynamic height of the label
        let font = UIFont.systemFont(ofSize: 16) // Set the same font used in the label
        let labelWidth = cellWidth - 32 // Subtract padding if needed
        let labelHeight = calculateLabelHeight(text: subjectName, font: font, width: labelWidth)
        
        // Add extra height for the image, margins, and other views
        let totalHeight = labelHeight + 120 // 100 can be space for image, padding, etc.
        return CGSize(width: cellWidth, height: totalHeight)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let exam = examArray[indexPath.item]
        guard let cell = collectionView.cellForItem(at: indexPath) as? ExamsListCVCell else { return }
        
        UIView.transition(
            with: cell.outerView,
            duration: 0.3,
            options: examArray[indexPath.row].isSelected ? .transitionFlipFromLeft : .transitionFlipFromRight,
            animations: {
                // Add any changes you want to animate, like updating subviews or labels
            },
            completion: nil
        )

        let vc = SchedulePopupVC(nibName: nil, bundle: nil)
        vc.index = indexPath.row
        vc.examSchedul = self.examArray
        vc.scheduDelegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    func calculateLabelHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        print(boundingBox.height)
        return ceil(boundingBox.height)
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        for i in 0..<(filterData?.count ?? 0){
            print(filterData?[i])
        }
    }
    
    func schedulSubject(ExamsSchedule: [ExamsSchedule], delete: Bool) {
        if delete == false {
            // Update examArray with new array
            self.examArray = ExamsSchedule
            filterData = self.examArray.filter({ exam in
                return exam.isSelected == true
            })
            subjectListCollection.reloadData()
        } else {
            let alert = CustomAlert()
            alert.showAlertCancel(title: "Do you want to remove",
                                  message: "Already Scheduled. Please Remove it first.",
                                  actionLbl1: "Confirm",
                                  actionLbl2: "Cancel",
                                  on: self) {
                self.examArray = ExamsSchedule
                self.subjectListCollection.reloadData()
            } onNo: {
                print("User canceled the action")
            }
        }
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
