//
//  ReportStudentListVC.swift
//  VsSchoolChimes
//
//  Created by admin on 09/12/24.
//

import UIKit
import DropDown

class ReportStudentListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var classView: UIView!
    @IBOutlet weak var reportTable: UITableView!
    
    @IBOutlet weak var sectionBtn: UIButton!
    @IBOutlet weak var clsBtn: UIButton!
     var sectionDropdown = DropDown()
     var classDropdown = DropDown()
    @IBOutlet weak var sectionSelection: UIStackView!
    @IBOutlet weak var classSelection: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reportTable.register(UINib(nibName: "ReportStudentTVC", bundle: nil), forCellReuseIdentifier: "ReportStudentTVC")
        sectionView.layer.cornerRadius = 10
        sectionView.layer.shadowColor = UIColor.black.cgColor
        sectionView.layer.shadowOffset = CGSize(width: 4, height: 4)
        sectionView.layer.shadowOpacity = 0.5
        sectionView.layer.shadowRadius = 4
        classView.layer.cornerRadius = 10
        classView.layer.shadowColor = UIColor.black.cgColor
        classView.layer.shadowOffset = CGSize(width: 4, height: 4)
        classView.layer.shadowOpacity = 0.5
        classView.layer.shadowRadius = 4
        
    }
    @IBAction func section(_ sender: UIButton) {
        sectionDropdown.dataSource = ["RollNo DESC","RollNo ASC","Name ASC","Name DESC", "Apsent", "Present"]
        sectionDropdown.bottomOffset = CGPoint(x: -90, y: (sectionBtn.bounds.height - 110))
        
        sectionDropdown.direction = .bottom
        
        sectionDropdown.show()
        sectionDropdown.selectionAction = { [self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.sectionBtn.setTitle(item, for: .normal)
           
            // Update the label inside the UIView
            if let label = self.sectionDropdown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.sectionBtn.setTitle(item.translated(), for: .normal)
                
                sectionBtn.setImage(UIImage(systemName: "square"), for: .normal)
                
            }
        }
    }
    @IBAction func classSelection(_ sender: UIButton) {
        
        sectionDropdown.dataSource = ["RollNo DESC","RollNo ASC","Name ASC","Name DESC", "Apsent", "Present"]
        sectionDropdown.bottomOffset = CGPoint(x: -90, y: (sectionBtn.bounds.height - 110))
        
        sectionDropdown.direction = .bottom
        
        sectionDropdown.show()
        sectionDropdown.selectionAction = { [self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.sectionBtn.setTitle(item, for: .normal)
           
            // Update the label inside the UIView
            if let label = self.sectionDropdown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.sectionBtn.setTitle(item.translated(), for: .normal)
                
                sectionBtn.setImage(UIImage(systemName: "square"), for: .normal)
                
            }
        }
//        
    }
    
    @IBAction func filter(_ sender: UIButton) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportTable.dequeueReusableCell(withIdentifier: "ReportStudentTVC", for: indexPath) as! ReportStudentTVC
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


}


class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [
            UIColor(red: 147/255, green: 112/255, blue: 219/255, alpha: 1.0).cgColor, // Purple
            UIColor.white.cgColor // White
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // Bottom-center
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 10 // Add corner radius to gradient layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = self.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = self.bounds // Ensure gradient resizes with view
            gradientLayer.cornerRadius = 10 // Reapply corner radius on resize
        }
        self.layer.cornerRadius = 10 // Add corner radius to the view itself
        self.clipsToBounds = true // Ensure corners are clipped
    }
}
