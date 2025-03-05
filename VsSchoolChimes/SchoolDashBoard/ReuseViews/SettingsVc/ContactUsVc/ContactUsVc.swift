//
//  ContactUsVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class ContactUsVc: UIViewController {

    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tv: UITableView!
    
    var content = ["Our 24*7 Customer Service.","Write us at."]
    var contact = ["9786543210","saranraj@savyasasy.com"]
    var icon  = [ImageName.Phone,ImageName.mail]
    
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
       
        BackBtn.setTitle(MenuTapbar.Contact_Us.translated(), for: .normal)
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
        
        tv.dataSource = self
        tv.delegate = self
        let nib = UINib(nibName: CellConfingName.ContactUsTVCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.ContactUsTVCell)

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

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
  
}

extension ContactUsVc : UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ContactUsTVCell, for: indexPath) as! ContactUsTVCell
        
        cell.contentLabel.text = content[indexPath.row]
        cell.mailOrPhoneLabel.text = contact[indexPath.row]
        cell.iconImg.image = icon[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 100
        
    }
    
}
