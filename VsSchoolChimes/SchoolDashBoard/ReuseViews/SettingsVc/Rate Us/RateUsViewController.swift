//
//  RateUsViewController.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit

protocol RatingDelegate: AnyObject {
    func rating(_ ratingcount: Int)
    func Submit(_ category: Set<String>, suggessions: String)
}

class RateUsViewController: UIViewController {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableview: UITableView!
    
    var isSelected: Bool = false
    var passValue = 1
    private var popoverOverlayView: UIView?
    weak var delegate: ViewAttachments?
    var submit :Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if passValue == 1 {
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1],
                               startPoint: CGPoint(x: 1, y: 0.5),
                               endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1],
                                    startPoint: CGPoint(x: 1, y: 0.5),
                                    endPoint: CGPoint(x: 0, y: 0.5))
        } else {
            view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                               startPoint: CGPoint(x: 1, y: 0.5),
                               endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                                    startPoint: CGPoint(x: 1, y: 0.5),
                                    endPoint: CGPoint(x: 0, y: 0.5))
        }
    }
    
    private func setupUI() {
        tableview.register(UINib(nibName: CellConfingName.BanerTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.BanerTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTypeTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTypeTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.SuccesseRatusTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SuccesseRatusTVC)
        
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100
    }
}

// MARK: - RatingCellDelegate (Maybe later button)
extension RateUsViewController: RatingCellDelegate {
    func didTapLaterButton() {
        self.dismiss(animated: true)
        delegate?.dismiss(true)
    }
}

// MARK: - UITableView
extension RateUsViewController: UITableViewDelegate, UITableViewDataSource, RatingDelegate {
    
    // User gives rating
    func rating(_ ratingcount: Int) {
        print("Rating Selected: \(ratingcount)")
        
        let shouldShowSection3 = ratingcount > 0
        let previousValue = isSelected
        isSelected = shouldShowSection3
        
        tableview.beginUpdates()
        if previousValue == false && shouldShowSection3 == true {
            tableview.insertSections(IndexSet(integer: 2), with: .fade)
        }else if previousValue == true && shouldShowSection3 == false {
            tableview.deleteSections(IndexSet(integer: 2), with: .fade)
        }
        
        tableview.endUpdates()
        delegate?.viewAttachment(sender: UIButton())
    }
    
    
    // Submit button tap from last cell
    func Submit(_ category: Set<String>, suggessions: String) {
        print(category)
        submit = true
        isSelected = false
        tableview.reloadData()
        
        delegate?.viewAttachment(sender: UIButton())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            self.dismiss(animated: true)
            self.delegate?.dismiss(true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if submit ?? false{
            return 1
        }else{
            return isSelected ? 3 : 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if submit ?? false{
            return tableview.dequeueReusableCell(withIdentifier: CellConfingName.SuccesseRatusTVC, for: indexPath)
            
        }else{
            
            switch indexPath.section {
                
            case 0:
                return tableview.dequeueReusableCell(withIdentifier: CellConfingName.BanerTableViewCell, for: indexPath)
                
            case 1:
                let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RatingTableViewCell, for: indexPath) as! RatingTableViewCell
                cell.RatingDelegate = self
                cell.delegate = self
                return cell
                
            case 2:
                let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RatingTypeTableViewCell, for: indexPath) as! RatingTypeTableViewCell
                cell.ratingDelegate = self
                return cell
                
            default:
                return UITableViewCell()
            }
        }
    }
}
