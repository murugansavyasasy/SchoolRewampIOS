
//  RateUs_ViewController.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit
protocol RatingDelegate{
    func rating(_ ratingcount:Int)
    func Submit(_ category:Set<String>,suggessions:String)
}
class RateUsViewController: UIViewController{
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableview: UITableView!
    var isSelected:Bool = false
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
        UiUpdate()
        
    }
    override func viewDidLayoutSubviews() {
        if passValue == 1{
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }
    }
    func UiUpdate(){
        tableview.register(UINib(nibName: CellConfingName.BanerTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.BanerTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTypeTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTypeTableViewCell)
    }
    
    //MARK: BackButton Action
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
}

extension RateUsViewController:UITableViewDelegate,UITableViewDataSource, RatingDelegate {
    func Submit(_ category:Set<String>,suggessions:String) {
        print(category)
        let vc = SubmitRatingViewController(nibName:nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func rating(_ ratingcount: Int) {
        print(ratingcount)
        isSelected = ratingcount != 0 ? true : false
        
        tableview.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.BanerTableViewCell, for: indexPath) as! BanerTableViewCell
            return cell
        }else if indexPath.section == 1{
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RatingTableViewCell, for: indexPath) as! RatingTableViewCell
            cell.RatingDelegate = self
            return cell
        }else{
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RatingTypeTableViewCell, for: indexPath) as! RatingTypeTableViewCell
            cell.ratingDelegate = self
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return isSelected == false ? 200 : 0
        }else if indexPath.section == 1{
            return UITableView.automaticDimension
        }else{
            return isSelected == true ? UITableView.automaticDimension : 0
        }
        
    }
    
    
}
