//
//  FeeInvoiceVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 19/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class FeeInvoiceVC: UIViewController,HTTPClientDelegate,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var InvoiceDetailTableView: UITableView!
    @IBOutlet weak var CustomFooterView: UIView!
    
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var PaymentModeLbl: UILabel!
    
    @IBOutlet weak var SNoLbl: UILabel!
    @IBOutlet weak var FeeNameLbl: UILabel!
    @IBOutlet weak var PaymentLbl: UILabel!
    
    @IBOutlet weak var TotalLbl: UILabel!
    @IBOutlet weak var TotalPaymentLbl: UILabel!
    var InvoiceDetail : NSArray = []
    var InvoiceDict = NSDictionary()
    
    
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var InvoiceIDString = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var ChildIDString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Fee Details"
        DesignBox()
        
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        
        InvoiceIDString  = String(describing: InvoiceDict["InvoiceId"]!)
        DateLbl.text = ": " + String(describing: InvoiceDict["CreatedOn"]!)
        PaymentModeLbl.text = ": " + String(describing: InvoiceDict["PaymentType"]!)
        
        let TotalFee = Double(String(describing: InvoiceDict["TotalPaid"]!))
        
        
        TotalPaymentLbl.text = "Rs: " + String(format: "%.2f", TotalFee!)
        TotalLbl.text = "Total"
        
        if(Util .isNetworkConnected())
        {
            self.CallGetInvoiceDetailApi()
            
        }
        else
        {
            InvoiceDetail =  Childrens.getFeeInvoice(fromDB: ChildIDString,getinvoiceId :InvoiceIDString )
            if(InvoiceDetail.count > 0)
            {
                InvoiceDetailTableView.reloadData()
            }else{
                Util .showAlert("", msg: NETWORK_ERROR)
            }
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return CustomFooterView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            height =  55
            
        }else{
            height =  40
            
        }
        return height
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return InvoiceDetail.count
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            height =  70
            
        }else{
            height =  50
            
        }
        return height
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeeInvoiceTVCell", for: indexPath) as! FeeInvoiceTVCell
        cell.backgroundColor = UIColor.clear
        let Dict:NSDictionary = InvoiceDetail[indexPath.row] as! NSDictionary
        cell.SNoLbl.text = String(describing: indexPath.row + 1)
        
        let PaidFee = Double(String(describing: Dict["PaidAmount"]!))
        
        cell.PaymentLbl.text =  "Rs: " + String(format: "%.2f", PaidFee!)
        let strFeeName =  String(describing: Dict["FeeName"]!)
        let strFeeTerm =  String(describing: Dict["FeeTerm"]!)
        cell.FeeNameLbl.text = strFeeName + "\n(" + strFeeTerm + ")"
        return cell
        
        
    }
    
    
    // MARK: API Call
    
    func CallGetInvoiceDetailApi() {
        showLoading()
        let apiRequestclient = HTTPClient.shared()
        apiRequestclient?.delegate = self
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + GET_PAIDFEE_INVOICE_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["InvoiceId" : InvoiceIDString]
        let myString = Util.convertDictionary(toString: myDict)
        apiRequestclient?.apiGetRequest(requestString, getRequestParams: myDict)
    }
    
    //MARK: API RESPONSE
    
    
    @objc func httpClientDidSucceed(withResponse responseObject: Any!) {
        hideLoading()
        if(responseObject != nil)
        {
            
            
            UtilObj.printLogKey(printKey: "responseObject", printingValue: responseObject!)
            let Dict: NSDictionary = responseObject as! NSDictionary
            
            if let CheckedArray = Dict["PaymentDetails"] as? NSArray
            {
                InvoiceDetail = CheckedArray
                if(InvoiceDetail.count > 0)
                {
                    
                    Childrens.saveFeeInvoiceDetail(InvoiceDetail as! [Any], ChildIDString)
                    
                    
                    InvoiceDetailTableView.reloadData()
                }else
                {
                    Util.showAlert("", msg: NO_RECORD_MESSAGE)
                }
                
            }else
            {
                Util.showAlert("", msg: NO_RECORD_MESSAGE)
            }
            
        }else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
        
        
        
        hideLoading()
        
    }
    
    @objc func httpClientDidFailWithError(_ error: Error!) {
        
        hideLoading()
        
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
        
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        //popupLoading.dismiss(true)
    }
    func DesignBox()
    {
        SNoLbl.layer.borderWidth = 0.5
        SNoLbl.layer.cornerRadius = 2
        SNoLbl.layer.borderColor = UIColor.black.cgColor
        
        FeeNameLbl.layer.borderWidth = 0.5
        FeeNameLbl.layer.cornerRadius = 2
        FeeNameLbl.layer.borderColor = UIColor.black.cgColor
        
        PaymentLbl.layer.borderWidth = 0.5
        PaymentLbl.layer.cornerRadius = 2
        PaymentLbl.layer.borderColor = UIColor.black.cgColor
        
        TotalLbl.layer.borderWidth = 0.5
        TotalLbl.layer.cornerRadius = 2
        TotalLbl.layer.borderColor = UIColor.black.cgColor
        
        TotalPaymentLbl.layer.borderWidth = 0.5
        TotalPaymentLbl.layer.cornerRadius = 2
        TotalPaymentLbl.layer.borderColor = UIColor.black.cgColor
    }
    
}
