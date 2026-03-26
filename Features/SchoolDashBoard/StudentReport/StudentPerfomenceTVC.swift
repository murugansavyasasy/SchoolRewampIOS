//
//  StudentPerfomenceTVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/03/26.
//

import UIKit

class StudentPerfomenceTVC: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var gradView: UIView!
    @IBOutlet weak var gradeLbl: UILabel!
    @IBOutlet weak var overallMakPersantageLbl: UILabel!
    @IBOutlet weak var gpaLbl: UILabel!
    @IBOutlet weak var attandanceLbl: UILabel!
    @IBOutlet weak var personiconBtn: UIButton!
    @IBOutlet weak var totalStudentLbl: UILabel!
    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var rankView: UIView!
    @IBOutlet weak var overallpercentageView: UIView!
    @IBOutlet weak var gpaView: UIView!
    @IBOutlet weak var attandanceView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        applyGradient()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradView.layer.sublayers?.first?.frame = gradView.bounds
    }
    func configure(data: AcademicPerformance?) {
        
        guard let data = data else { return }
        
        let overall = data.overallPercentage ?? 0
        let grade = data.grade ?? "-"
        let gpa = data.gpa ?? 0
        let attendance = data.attendancePercentage ?? 0
        let rank = data.classRank ?? 0
        let totalStudents = data.totalStudents ?? 0
        
        overallMakPersantageLbl.text = "\(Int(overall))%"
        gradeLbl.text = " Grade: \(grade)"
        gpaLbl.text = String(format: "%.1f", gpa)
        attandanceLbl.text = "\(Int(attendance))%"
        rankLbl.text = "#\(rank)"
        totalStudentLbl.text = "Out of \(totalStudents)"
        
        applyPerformanceColor(overall: overall)
    }
    private func setupUI() {
        outerView.setShadow()
        gradView.layer.cornerRadius = 20
        personiconBtn.layer.cornerRadius = personiconBtn.frame.height/2
        gradView.clipsToBounds = true
        
        [rankView, overallpercentageView, gpaView, attandanceView].forEach {
            $0?.backgroundColor = .white
            $0?.setShadow(cornerRadius: 12)
        }
    }
    private func applyGradient() {
        
        let gradient = CAGradientLayer()
        gradient.frame = gradView.bounds
        gradient.cornerRadius = personiconBtn.frame.height/2
        gradient.colors = [
            UIColor.systemIndigo.cgColor,
            UIColor.systemBlue.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradView.layer.insertSublayer(gradient, at: 0)
    }
    private func applyPerformanceColor(overall: Double) {
        overallMakPersantageLbl.textColor = .blue.withAlphaComponent(0.75)
        rankView.backgroundColor = .yellow.withAlphaComponent(0.15)
    }
    
}
