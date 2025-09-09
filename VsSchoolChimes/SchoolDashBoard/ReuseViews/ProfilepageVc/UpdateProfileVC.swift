//
//  UpdateProfileVC.swift
//  School Chimes
//
//  Created by Chandhru on 02/09/25.
//

import UIKit
import PhotosUI

@available(iOS 14.0, *)
class UpdateProfileVC: UIViewController {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var detailTable: UITableView!

    var userDetails: [ProfileList] = []
    var attachments: [AttachmentItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupUserDetails(isStudent: true)
    }

    private func setupUI() {
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        profileImg.clipsToBounds = true
        profileImg.layer.borderWidth = 1
        profileImg.layer.borderColor = UIColor.white.cgColor
        editBtn.layer.cornerRadius = editBtn.frame.width / 2
        editBtn.clipsToBounds = true

        detailTable.register(UINib(nibName: "UserDetailsTVC", bundle: nil), forCellReuseIdentifier: "UserDetailsTVC")
        detailTable.dataSource = self
        detailTable.delegate = self
        detailTable.tableFooterView = UIView()
    }

    private func setupUserDetails(isStudent: Bool) {
        let url = isStudent ? ServiceUrl.admin_api_student_profile_list : ServiceUrl.admin_api_staff_profile_list
        let token = isStudent ? UserDefaultFileManager.get_child_Details()?.access_token ?? "" : UserDefaultFileManager.get_staff_Details()?.access_token ?? ""

        APIService.shared.makeApi(
            url: url,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: token
        ) { [weak self] (result: Result<UserProfileResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        // Process the response data here
                        // self?.userDetails = response.data // Assuming response contains data
                        self?.detailTable.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.loadDummyData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error:", error.localizedDescription)
                    self?.loadDummyData()
                }
            }
        }
    }

    @IBAction func changeProfile(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select", message: "Choose an option", preferredStyle: .actionSheet)
          alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
              self?.openCameraForProfile()
          })
          alert.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
              self?.openGalleryForProfile()
          })
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

          // iPad support
          if let popover = alert.popoverPresentationController {
              popover.sourceView = view
              popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
              popover.permittedArrowDirections = []
          }

          present(alert, animated: true)
    }
    func openGalleryForProfile() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(message: "Photo Library not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary  // <-- important
        picker.allowsEditing = true        // allow cropping if needed
        present(picker, animated: true)
    }
    func openCameraForProfile() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    // Fixed: Removed duplicate method declaration and corrected implementation
    func loadDummyData() {
        let section = UserDetailsSection(
            General: [
                UserDetailItem(title: "Student Name", value: "M BHARATH", type: .text, options: [], is_editable: true, optional: false, node: "studentName", file_Path: nil),
                UserDetailItem(title: "Admission No", value: "SS-18", type: .text, options: [], is_editable: false, optional: false, node: "admissionNo", file_Path: nil),
                UserDetailItem(title: "Roll No", value: "343434", type: .number, options: [], is_editable: false, optional: false, node: "rollNo", file_Path: nil),
                UserDetailItem(title: "Class", value: "VI", type: .text, options: [], is_editable: false, optional: false, node: "class", file_Path: nil),
                UserDetailItem(title: "Section", value: "B", type: .text, options: [], is_editable: false, optional: false, node: "section", file_Path: nil),
                UserDetailItem(title: "Date of Birth", value: "05-12-2002", type: .calendar, options: [], is_editable: true, optional: false, node: "dob", file_Path: nil),
                UserDetailItem(title: "Date of Joining", value: "09-06-2021", type: .calendar, options: [], is_editable: false, optional: true, node: "doj", file_Path: nil),
                UserDetailItem(title: "Gender", value: "male", type: .radioButton, options: ["male", "female", "others"], is_editable: true, optional: false, node: "gender", file_Path: nil),
                UserDetailItem(title: "Hobbies", value: "", type: .address, options: [], is_editable: true, optional: true, node: "hobbies", file_Path: nil)
            ],
            FatherDetails: [
                UserDetailItem(title: "Father Name", value: "Mayan M", type: .text, options: [], is_editable: true, optional: true, node: "fatherName", file_Path: nil),
                UserDetailItem(title: "Father Qualification", value: "", type: .text, options: [], is_editable: true, optional: true, node: "fatherQualification", file_Path: nil),
                UserDetailItem(title: "Father Occupation", value: "Farming", type: .text, options: [], is_editable: true, optional: true, node: "fatherOccupation", file_Path: nil),
                UserDetailItem(title: "Father Annual Income", value: "--", type: .text, options: [], is_editable: true, optional: true, node: "fatherAnnualIncome", file_Path: nil),
                UserDetailItem(title: "Father Email", value: "", type: .text, options: [], is_editable: true, optional: true, node: "fatherEmailAddress", file_Path: nil),
                UserDetailItem(title: "Father Office Address", value: "", type: .text, options: [], is_editable: true, optional: true, node: "fatherOfficeAddress", file_Path: nil)
            ],
            MotherDetails: [
                UserDetailItem(title: "Mother Name", value: "Malarkodi M", type: .text, options: [], is_editable: true, optional: true, node: "motherName", file_Path: nil),
                UserDetailItem(title: "Mother Qualification", value: "8 std", type: .text, options: [], is_editable: true, optional: true, node: "motherQualification", file_Path: nil),
                UserDetailItem(title: "Mother Occupation", value: "Farming", type: .text, options: [], is_editable: true, optional: true, node: "motherOccupation", file_Path: nil),
                UserDetailItem(title: "Mother Annual Income", value: "", type: .text, options: [], is_editable: true, optional: true, node: "motherAnnualIncome", file_Path: nil),
                UserDetailItem(title: "Mother Email", value: "", type: .text, options: [], is_editable: true, optional: true, node: "motherEmailAddress", file_Path: nil),
                UserDetailItem(title: "Mother Office Address", value: "", type: .text, options: [], is_editable: true, optional: true, node: "motherOfficeAddress", file_Path: nil)
            ],
            Communication: [
                UserDetailItem(title: "Primary Mobile", value: "9345443519", type: .text, options: [], is_editable: true, optional: false, node: "primaryMobile", file_Path: nil),
                UserDetailItem(title: "Secondary Mobile", value: "1111111111", type: .text, options: [], is_editable: true, optional: true, node: "secondaryMobile", file_Path: nil),
                UserDetailItem(title: "Whatsapp Number", value: "1111111111", type: .text, options: [], is_editable: true, optional: true, node: "whatsappNumber", file_Path: nil),
                UserDetailItem(title: "Email", value: "bharath@savyasasy.com", type: .text, options: [], is_editable: true, optional: true, node: "email", file_Path: nil),
                UserDetailItem(title: "Father Mobile", value: "1111111111", type: .text, options: [], is_editable: true, optional: true, node: "fatherMobile", file_Path: nil),
                UserDetailItem(title: "Mother Mobile", value: "1111111111", type: .text, options: [], is_editable: true, optional: true, node: "motherMobile", file_Path: nil)
            ],
            Address: [
                UserDetailItem(title: "Residential Address", value: "t.nagar,\nchennai", type: .address, options: [], is_editable: true, optional: true, node: "residentalAddress", file_Path: nil),
                UserDetailItem(title: "Residential City", value: "chennai", type: .text, options: [], is_editable: true, optional: true, node: "residentalCity", file_Path: nil),
                UserDetailItem(title: "Residential State", value: "tamilnadu", type: .text, options: [], is_editable: true, optional: true, node: "residentalState", file_Path: nil),
                UserDetailItem(title: "Residential Country", value: "india", type: .text, options: [], is_editable: true, optional: true, node: "residentalCountry", file_Path: nil),
                UserDetailItem(title: "Residential Pincode", value: "600017", type: .number, options: [], is_editable: true, optional: true, node: "residentalPincode", file_Path: nil),
                UserDetailItem(title: "Permanent Address", value: "t.nagar,\nchennai", type: .address, options: [], is_editable: true, optional: true, node: "permanentAddress", file_Path: nil),
                UserDetailItem(title: "Permanent City", value: "chennai", type: .text, options: [], is_editable: true, optional: true, node: "permanentCity", file_Path: nil),
                UserDetailItem(title: "Permanent State", value: "tamilnadu", type: .text, options: [], is_editable: true, optional: true, node: "permanentState", file_Path: nil),
                UserDetailItem(title: "Permanent Country", value: "india", type: .text, options: [], is_editable: true, optional: true, node: "permanentCountry", file_Path: nil),
                UserDetailItem(title: "Permanent Pincode", value: "600017", type: .number, options: [], is_editable: true, optional: true, node: "permanentPincode", file_Path: nil)
            ],
            Physical: [
                UserDetailItem(title: "Height", value: "", type: .text, options: [], is_editable: true, optional: true, node: "height", file_Path: nil),
                UserDetailItem(title: "Weight", value: "", type: .text, options: [], is_editable: true, optional: true, node: "weight", file_Path: nil),
                UserDetailItem(title: "Blood Group", value: "B -ve", type: .dropdown, options: ["A +ve","A -ve","A1 +ve","A1 -ve","A2 +ve","A2 -ve","B +ve","B -ve","O +ve","O -ve","AB +ve","AB -ve","A1B +ve","A1B -ve"], is_editable: true, optional: true, node: "bloodGroup", file_Path: nil)
            ],
            Identifiers: [
                UserDetailItem(title: "Student Aadhaar Number", value: "344444444444", type: .text, options: [], is_editable: false, optional: true, node: "studentAdhaarNumber", file_Path: nil)
            ],
            Community: [
                UserDetailItem(title: "Community", value: "", type: .dropdown, options: ["OC","BC","MBC","DNC","SC","ST","REFUGEE","OTHERS","OBC","MOBC","BCM"], is_editable: true, optional: true, node: "community", file_Path: nil),
                UserDetailItem(title: "Caste", value: "test caste", type: .text, options: [], is_editable: true, optional: true, node: "caste", file_Path: nil),
                UserDetailItem(title: "Sub Caste", value: "", type: .text, options: [], is_editable: true, optional: true, node: "subCaste", file_Path: nil),
                UserDetailItem(title: "Religion", value: "", type: .text, options: [], is_editable: true, optional: true, node: "religion", file_Path: nil)
            ],
            BankDetails: [
                UserDetailItem(title: "Bank Name", value: "Indian Bank", type: .text, options: [], is_editable: false, optional: true, node: "bankName", file_Path: nil),
                UserDetailItem(title: "Bank Account Number", value: "53435433242342423", type: .text, options: [], is_editable: false, optional: true, node: "bankAccountNumber", file_Path: nil),
                UserDetailItem(title: "IFSC Code", value: "", type: .text, options: [], is_editable: false, optional: true, node: "ifscCode", file_Path: nil)
            ],
            Documents: [
                UserDetailItem(title: "Documents", value: "", type: .doc, options: [], is_editable: false, optional: true, node: "documents", file_Path: [
                    FilePath(url: "uploads/studentDocument/Doc_1756901782207.pdf", type: "pdf"),
                    FilePath(url: "uploads/studentDocument/Doc_1756901963773.png", type: "image")
                ])
            ],
            TransportDetails: [
                UserDetailItem(title: "Route", value: "Kodampakkam", type: .text, options: [], is_editable: false, optional: true, node: "routeMasterDetails", file_Path: nil),
                UserDetailItem(title: "Stopping Point", value: "T.nagar", type: .text, options: [], is_editable: false, optional: true, node: "busStopsDetails", file_Path: nil)
            ]
        )

        // Initialize attachments from document files
        let documentSection = section.Documents ?? []
        for item in documentSection {
            if let files = item.file_Path {
                let newAttachments = files.map { file in
                    let url = file.url ?? ""
                    let type = file.type?.lowercased() ?? "unknown"
                    if type == "image" {
                        return AttachmentItem(image: nil, imageURL: url, fileType: "image")
                    } else if type == "video" {
                        return AttachmentItem(image: UIImage(systemName: "video"), imageURL: url, fileType: "video", VideoURl: URL(string: url))
                    } else {
                        return AttachmentItem(image: nil, imageURL: url, fileType: type)
                    }
                }
                attachments.append(contentsOf: newAttachments)
            }
        }

        let dummyData: [ProfileList] = [
            ProfileList(title: "General", value: section.General ?? []),
            ProfileList(title: "Father Details", value: section.FatherDetails ?? []),
            ProfileList(title: "Mother Details", value: section.MotherDetails ?? []),
            ProfileList(title: "Communication", value: section.Communication ?? []),
            ProfileList(title: "Address", value: section.Address ?? []),
            ProfileList(title: "Physical", value: section.Physical ?? []),
            ProfileList(title: "Identifiers", value: section.Identifiers ?? []),
            ProfileList(title: "Community", value: section.Community ?? []),
            ProfileList(title: "Bank Details", value: section.BankDetails ?? []),
            ProfileList(title: "Documents", value: section.Documents ?? []),
            ProfileList(title: "Transport Details", value: section.TransportDetails ?? [])
        ]

        self.userDetails = dummyData
        self.detailTable.reloadData()
    }

    private func generateDummyProfileList() -> [ProfileList] {
        // Since UserDetailsSection.sample() doesn't exist, we'll use the same data structure as loadDummyData()
        let section = UserDetailsSection(
            General: [
                UserDetailItem(title: "Student Name", value: "M BHARATH", type: .text, options: [], is_editable: true, optional: false, node: "studentName", file_Path: nil),
                UserDetailItem(title: "Admission No", value: "SS-18", type: .text, options: [], is_editable: false, optional: false, node: "admissionNo", file_Path: nil),
                UserDetailItem(title: "Roll No", value: "343434", type: .number, options: [], is_editable: false, optional: false, node: "rollNo", file_Path: nil),
                UserDetailItem(title: "Class", value: "VI", type: .text, options: [], is_editable: false, optional: false, node: "class", file_Path: nil),
                UserDetailItem(title: "Section", value: "B", type: .text, options: [], is_editable: false, optional: false, node: "section", file_Path: nil),
                UserDetailItem(title: "Date of Birth", value: "05-12-2002", type: .calendar, options: [], is_editable: true, optional: false, node: "dob", file_Path: nil),
                UserDetailItem(title: "Gender", value: "male", type: .radioButton, options: ["male", "female", "others"], is_editable: true, optional: false, node: "gender", file_Path: nil)
            ],
            FatherDetails: [
                UserDetailItem(title: "Father Name", value: "Sample Father", type: .text, options: [], is_editable: true, optional: true, node: "fatherName", file_Path: nil)
            ],
            MotherDetails: [
                UserDetailItem(title: "Mother Name", value: "Sample Mother", type: .text, options: [], is_editable: true, optional: true, node: "motherName", file_Path: nil)
            ],
            Communication: [
                UserDetailItem(title: "Primary Mobile", value: "9345443519", type: .text, options: [], is_editable: true, optional: false, node: "primaryMobile", file_Path: nil)
            ],
            Address: [
                UserDetailItem(title: "Residential Address", value: "Sample Address", type: .address, options: [], is_editable: true, optional: true, node: "residentalAddress", file_Path: nil)
            ],
            Physical: [
                UserDetailItem(title: "Blood Group", value: "B -ve", type: .dropdown, options: ["A +ve","A -ve","B +ve","B -ve","O +ve","O -ve"], is_editable: true, optional: true, node: "bloodGroup", file_Path: nil)
            ],
            Identifiers: [
                UserDetailItem(title: "Student Aadhaar Number", value: "344444444444", type: .text, options: [], is_editable: false, optional: true, node: "studentAdhaarNumber", file_Path: nil)
            ],
            Community: [
                UserDetailItem(title: "Community", value: "", type: .dropdown, options: ["OC","BC","MBC","SC","ST"], is_editable: true, optional: true, node: "community", file_Path: nil)
            ],
            BankDetails: [
                UserDetailItem(title: "Bank Name", value: "Sample Bank", type: .text, options: [], is_editable: false, optional: true, node: "bankName", file_Path: nil)
            ],
            Documents: [
                UserDetailItem(title: "Documents", value: "", type: .document, options: [], is_editable: false, optional: true, node: "documents", file_Path: nil)
            ],
            TransportDetails: [
                UserDetailItem(title: "Route", value: "Sample Route", type: .text, options: [], is_editable: false, optional: true, node: "routeMasterDetails", file_Path: nil)
            ]
        )
        
        return [
            ProfileList(title: "General", value: section.General ?? []),
            ProfileList(title: "Father Details", value: section.FatherDetails ?? []),
            ProfileList(title: "Mother Details", value: section.MotherDetails ?? []),
            ProfileList(title: "Communication", value: section.Communication ?? []),
            ProfileList(title: "Address", value: section.Address ?? []),
            ProfileList(title: "Physical", value: section.Physical ?? []),
            ProfileList(title: "Identifiers", value: section.Identifiers ?? []),
            ProfileList(title: "Community", value: section.Community ?? []),
            ProfileList(title: "Bank Details", value: section.BankDetails ?? []),
            ProfileList(title: "Documents", value: section.Documents ?? []),
            ProfileList(title: "Transport Details", value: section.TransportDetails ?? [])
        ]
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

@available(iOS 14.0, *)
extension UpdateProfileVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return userDetails.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == userDetails.count - 1 {
            return userDetails[section].value.count + 1
        }
        return userDetails[section].value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailsTVC", for: indexPath) as? UserDetailsTVC else {
            return UITableViewCell()
        }

        let section = userDetails[indexPath.section]
        let isLastSection = indexPath.section == userDetails.count - 1
        let isLastRow = indexPath.row == section.value.count

        if isLastSection && isLastRow {
            cell.configure(with: nil)
            cell.updateBtn.addTarget(self, action: #selector(updateButtonTapped(_:)), for: .touchUpInside)
        } else {
            let item = section.value[indexPath.row]
            cell.configure(with: item)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground

        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.label
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)

        label.text = userDetails[section].title

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        return headerView
    }
    private func showAlert(message: String) {
        let alert = CustomAlert()
        alert.showAlert(title: "", message: message, on: self)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    // MARK: - Update Button Action

    @objc func updateButtonTapped(_ sender: UIButton) {
        var params: [String: Any] = [:]

        for sectionIndex in 0..<userDetails.count {
            let section = userDetails[sectionIndex]

            for rowIndex in 0..<section.value.count {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)

                if let cell = detailTable.cellForRow(at: indexPath) as? UserDetailsTVC,
                   let updatedValue = cell.getUpdatedValue(),
                   let node = section.value[rowIndex].node {
                    params[node] = updatedValue
                }
            }
        }

        print("Final Params to update:", params)
        // Implement your API call here using the params
        callUpdateAPI(with: params)
    }
    
    private func callUpdateAPI(with params: [String: Any]) {
        // Add your API implementation here
        // Example:
        // APIService.shared.updateProfile(parameters: params) { result in
        //     // Handle result
        // }
    }
}
// MARK: - UIImagePickerController Delegate
@available(iOS 14.0, *)
extension UpdateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            profileImg.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Supporting Models

struct ProfileList {
    let title: String
    let value: [UserDetailItem]
}
