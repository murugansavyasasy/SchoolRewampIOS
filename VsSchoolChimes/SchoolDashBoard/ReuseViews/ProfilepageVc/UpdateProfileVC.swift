//
//  UpdateProfileVC.swift
//  School Chimes
//
//  Created by Chandhru on 02/09/25.
//

import UIKit

@available(iOS 14.0, *)
class UpdateProfileVC: UIViewController {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var detailTable: UITableView!
    
    var userDetails: [UserDetailItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImg.layer.cornerRadius = profileImg.layer.frame.width/2
        editBtn.layer.cornerRadius = editBtn.layer.frame.width/2
        detailTable.register(UINib(nibName: "UserDetailsTVC", bundle: nil), forCellReuseIdentifier: "UserDetailsTVC")
        detailTable.dataSource = self
        detailTable.delegate = self
        setupUserDetails(isStudent: true)
    }
    
    private func setupUserDetails(isStudent: Bool) {
        if isStudent {
            userDetails = [
                UserDetailItem(placeholder: "Name", value: "Arun Kumar", isEditable: true, type: .text, options: nil),
                UserDetailItem(placeholder: "Address", value: "Chennai", isEditable: true, type: .address, options: nil),
                UserDetailItem(
                    placeholder: "Mobile Number",
                    value: "9876543210",
                    isEditable: true,
                    type: .mobile,
                    options: ["+91", "+1", "+44", "+61", "+81", "+971", "+974", "+65", "+49", "+33"]
                ),
                UserDetailItem(placeholder: "Email", value: "arun.kumar@gmail.com", isEditable: true, type: .text, options: ["arun.kumar@gmail.com", "arun123@yahoo.com"]),
                UserDetailItem(placeholder: "Date of Birth", value: "02/09/2005", isEditable: true, type: .date, options: nil),
                UserDetailItem(placeholder: "Gender", value: "Male", isEditable: true, type: .gender, options: ["Male", "Female", "Other"]),
                UserDetailItem(placeholder: "Standard", value: "10th", isEditable: true, type: .dropdown, options: ["9th", "10th", "11th", "12th"]),
                UserDetailItem(placeholder: "Section", value: "A", isEditable: true, type: .dropdown, options: ["A", "B", "C"]),
                UserDetailItem(placeholder: "Blood Group", value: "O+", isEditable: true, type: .dropdown, options: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]),
                UserDetailItem(placeholder: "Nationality", value: "Indian", isEditable: true, type: .dropdown, options: ["Indian", "American", "British", "Canadian"]),
                UserDetailItem(
                    placeholder: "Student Documents",
                    value: nil,
                    isEditable: true,
                    type: .doc,
                    options: nil,
                    file_Path: [
                        FilePath(url: "https://school.com/docs/report1.pdf", type: "pdf"),
                        FilePath(url: "https://school.com/docs/result.xls", type: "xls"),
                        FilePath(url: "https://school.com/docs/profile.txt", type: "txt")
                    ]
                )
            ]
        } else {
            userDetails = [
                UserDetailItem(placeholder: "Name", value: "Karthik", isEditable: true, type: .text, options: nil),
                UserDetailItem(placeholder: "Address", value: "Coimbatore", isEditable: true, type: .address, options: nil),
                UserDetailItem(placeholder: "Mobile Number", value: "9876512345", isEditable: true, type: .mobile, options: nil),
                UserDetailItem(placeholder: "Email", value: "karthik.teacher@gmail.com", isEditable: true, type: .text, options: ["karthik.teacher@gmail.com"]),
                UserDetailItem(placeholder: "Date of Birth", value: "15/03/1988", isEditable: true, type: .date, options: nil),
                UserDetailItem(placeholder: "Gender", value: "Female", isEditable: true, type: .gender, options: ["Male", "Female", "Other"]),
                UserDetailItem(placeholder: "Degree", value: "M.Sc", isEditable: true, type: .dropdown, options: ["B.Sc", "M.Sc", "PhD", "M.Ed", "B.Ed"]),
                UserDetailItem(placeholder: "Blood Group", value: "B+", isEditable: true, type: .dropdown, options: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]),
                UserDetailItem(placeholder: "Department", value: "Mathematics", isEditable: true, type: .dropdown, options: ["Maths", "Physics", "Chemistry", "Biology", "Computer Science"]),
                UserDetailItem(
                    placeholder: "Teacher Certificates",
                    value: nil,
                    isEditable: true,
                    type: .doc,
                    options: nil,
                    file_Path: [
                        FilePath(url: "https://school.com/docs/degree.pdf", type: "pdf"),
                        FilePath(url: "https://school.com/docs/idcard.txt", type: "txt")
                    ]
                )
            ]
        }
        
        detailTable.reloadData()
    }
    
    @IBAction func changeProfile(_ sender: UIButton) {
        // TODO: image picker
    }
}

@available(iOS 14.0, *)
extension UpdateProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Extra row for update button cell
        return userDetails.count + 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailsTVC",
                                                       for: indexPath) as? UserDetailsTVC else {
            return UITableViewCell()
        }
        
        if indexPath.row < userDetails.count {
            // Normal user detail cell
            let item = userDetails[indexPath.row]
            cell.configure(with: item)
        } else {
            // Last row → update button cell
            cell.configure(with: nil)
            cell.updateBtn.addTarget(self,
                                     action: #selector(updateButtonTapped(_:)),
                                     for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func updateButtonTapped(_ sender: UIButton) {
        var params: [String: Any] = [:]

        for (index, item) in userDetails.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = detailTable.cellForRow(at: indexPath) as? UserDetailsTVC {
                if let updatedValue = cell.getUpdatedValue() {
                    params[item.placeholder] = updatedValue
                }
            }
        }
        
        print("Final Params: \(params)")
    }
}
