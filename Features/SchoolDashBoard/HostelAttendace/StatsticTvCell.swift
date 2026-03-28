//
//  StatsticTvCell.swift
//  School Chimes
//
//  Created by apple on 04/03/26.
//

import UIKit
protocol DashboardStatsCellDelegate: AnyObject {
    func didTapPendingIssues()
    func didTapOutpassRequests()
    func MessMenu()
}
class StatsticTvCell: UITableViewCell {
    @IBOutlet weak var totalStudentCountLbl: UILabel!
    @IBOutlet weak var menuView: UIView!
    weak var delegate: DashboardStatsCellDelegate?
    @IBOutlet weak var outpassCountLbl: UILabel!
    @IBOutlet weak var outPassView: UIView!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var totalStudentView: UIView!
    @IBOutlet weak var totalBedView: UIView!
    @IBOutlet weak var totalRoomView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(pendingTapped))
        pendingView.isUserInteractionEnabled = true
        pendingView.addGestureRecognizer(tap)
        let outpassTap = UITapGestureRecognizer(target: self, action: #selector(outpassTapped))
        outPassView.isUserInteractionEnabled = true
        outPassView.addGestureRecognizer(outpassTap)
        
        let messMenus = UITapGestureRecognizer(target: self, action: #selector(MessMenu))
        menuView.isUserInteractionEnabled = true
        menuView.addGestureRecognizer(messMenus)
    }

    @objc func pendingTapped() {
        delegate?.didTapPendingIssues()
    }
    
    @objc func outpassTapped() {
        delegate?.didTapOutpassRequests()
    }
    @objc func MessMenu() {
        delegate?.MessMenu()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        [totalRoomView, totalBedView, totalStudentView, pendingView, outPassView,menuView].forEach { view in
            guard let view = view else { return }

            // Remove old gradient layers if they exist
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds

            if view == totalRoomView {
                // Blue gradient
                gradientLayer.colors = [
                    UIColor(red: 0.16, green: 0.44, blue: 0.98, alpha: 1.0).cgColor,
                    UIColor(red: 0.13, green: 0.35, blue: 0.96, alpha: 1.0).cgColor,
                ]
            } else if view == totalBedView {
                // Purple gradient
                gradientLayer.colors = [
                    UIColor(red: 0.65, green: 0.22, blue: 0.96, alpha: 1.0).cgColor,
                    UIColor(red: 0.55, green: 0.15, blue: 0.94, alpha: 1.0).cgColor,
                ]
            } else if view == totalStudentView {
                // Green gradient
                gradientLayer.colors = [
                    UIColor(red: 0.04, green: 0.62, blue: 0.23, alpha: 1.0).cgColor,
                    UIColor(red: 0.03, green: 0.52, blue: 0.18, alpha: 1.0).cgColor,
                ]
            } else if view == pendingView {
                // Red gradient
                gradientLayer.colors = [
                    UIColor(red: 0.93, green: 0.09, blue: 0.11, alpha: 1.0).cgColor,
                    UIColor(red: 0.81, green: 0.07, blue: 0.09, alpha: 1.0).cgColor,
                ]
            } else if view == outPassView {
                // Indigo/purple-blue gradient
                gradientLayer.colors = [
                    UIColor(red: 0.35, green: 0.29, blue: 0.93, alpha: 1.0).cgColor,
                    UIColor(red: 0.28, green: 0.20, blue: 0.91, alpha: 1.0).cgColor,
                ]
            }

            else if view == menuView {
                // Indigo/purple-blue gradient
                gradientLayer.colors = [
                    UIColor(red: 1.0, green: 0.48, blue: 0.0, alpha: 1.0).cgColor,   // #FF7A00
                    UIColor(red: 1.0, green: 0.24, blue: 0.18, alpha: 1.0).cgColor   // #FF3D2E
                ]
            }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = 16

            view.layer.insertSublayer(gradientLayer, at: 0)
            view.backgroundColor = .clear
            view.layer.cornerRadius = 16
        }
    }
}
