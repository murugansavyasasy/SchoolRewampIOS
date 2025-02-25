//
//  MonthlyFeesVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 09/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class MonthlyFeesVC: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var MonthlyFeesTableView: UITableView!
    var MonthlyFeeArray : NSArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        navTitle()
        MonthlyFeesTableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return MonthlyFeeArray.count
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            height =  175
            
        }else{
            height =  168
            
        }
        return height
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonthlyFeeTVCell", for: indexPath) as! MonthlyFeeTVCell
        cell.backgroundColor = UIColor.clear
        let Dict:NSDictionary = MonthlyFeeArray[indexPath.row] as! NSDictionary
        cell.FeeNameLbl.text = ": " + String(describing: Dict["FeeName"]!)
        
        let TotalFee = Double(String(describing: Dict["TotalMonthly"]!))
        
        cell.TotalLbl.text = ": " + String(format: "%.2f", TotalFee!)
        
        let TotalMonthlyFee = Double(String(describing: Dict["Monthly"]!))
        
        cell.MonthlyFeeLbl.text = ": " + String(format: "%.2f", TotalMonthlyFee!)
        
        
        
        let MonthlyFee = Double(String(describing: Dict["PendingAmount"]!))
        
        let strMonthlyFee =  ": " + String(format: "%.2f", MonthlyFee!)
        let strFromMonth =  " From " + String(describing: Dict["StartMonthName"]!) + " To " + String(describing: Dict["EndMonthName"]!)
        cell.PendingAmountLbl.text = strMonthlyFee + strFromMonth
        
        
        
        
        
        return cell
        
        
    }
    
    
    func navTitle()
    {
        
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        //titleLabel.textColor = UIColor (red:128.0/255.0, green:205.0/255.0, blue: 244.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord = "Monthly Pending "
        let thirdWord   = "fees"
        let comboWord = secondWord + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord)
        attributedText.addAttributes(attrs, range: range)
        
        titleLabel.attributedText = attributedText
        self.navigationItem.titleView = titleLabel
    }
    
    @IBAction func actionMakePayment(_ sender: UIButton) {
        self.performSegue(withIdentifier: "PaymentViewSegue", sender: self)
        
    }
    
}
