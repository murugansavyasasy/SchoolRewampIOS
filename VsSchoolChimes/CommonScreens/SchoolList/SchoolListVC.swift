//
//  SchoolListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit

class SchoolListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var listTable: UITableView!
    var schools: [School] = [
        School(name: "ABC Public School", address: "123, Main Street, Chennai", isSelected: true),
        School(name: "XYZ International School", address: "45, Park Road, Coimbatore", isSelected: true),
        School(name: "Sunrise Academy", address: "78, MG Road, Madurai", isSelected: true),
        School(name: "Greenwood High", address: "56, Anna Nagar, Trichy", isSelected: true),
        School(name: "Bluebell School", address: "90, Gandhi Street, Salem", isSelected: true),
        School(name: "Oakridge School", address: "12, Nelson Road, Erode", isSelected: true),
        School(name: "Little Angels Academy", address: "67, Cross Road, Tirunelveli", isSelected: true),
        School(name: "Springfield High", address: "34, Lake View, Vellore", isSelected: true),
        School(name: "Elite Public School", address: "89, New Colony, Thanjavur", isSelected: true),
        School(name: "St. Joseph's Matric", address: "23, Temple Road, Kanyakumari", isSelected: true)
    ]
    var screen_type : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.register(UINib(nibName:CellConfingName.SchoolListTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SchoolListTVC)
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: CellConfingName.SchoolListTVC, for: indexPath) as! SchoolListTVC
        cell.name.text = schools[indexPath.row].name
        cell.address.text = schools[indexPath.row].address
        let img = schools[indexPath.row].isSelected ? UIImage(named: "checkedSquare") : UIImage(named: "uncheckedSquare")
        cell.selectedBtn.setImage(img, for: .normal)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        schools[indexPath.row].isSelected.toggle()
        listTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func selectedSchool(_ sender: Any) {
        
        let detailViewController = RecipientVc()
        let nav = UINavigationController(rootViewController: detailViewController)

        // 1 - Set modal presentation style
        nav.modalPresentationStyle = .pageSheet

        // 2 - Configure bottom sheet
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { _ in 470 }, .large()]
                } else {
                    // Fallback on earlier versions
                }
                sheet.prefersGrabberVisible = true // Hide grabber
                sheet.largestUndimmedDetentIdentifier = .large // REMOVE BACKGROUND DIMMING
            }
        } else {
            // Fallback on earlier versions
        }

        // 3 - Prevent dismiss on swipe down
        nav.isModalInPresentation = true

        // 4 - Add Blur Effect to Background
        if let window = UIApplication.shared.windows.first {
            let blurEffect = UIBlurEffect(style: .light) // Use .light or any other style
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = window.bounds
            window.addSubview(blurView)
            blurView.alpha = 0.5 // Adjust transparency for the blur effect
            
            // Optional: Add tap gesture to prevent interaction with the background
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBlurEffect))
            blurView.addGestureRecognizer(tapGesture)
        }

        // 5 - Present the bottom sheet
        present(nav, animated: true)

                
    }
    @objc func dismissBlurEffect() {
        // You can dismiss or handle the tap here
        print("Background tapped, but modal won't dismiss.")
    }
}
struct School {
    let name: String
    let address: String
    var isSelected: Bool
}
