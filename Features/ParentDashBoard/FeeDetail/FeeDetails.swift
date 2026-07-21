//
//  FeeDetails.swift
//  School Chimes
//
//  Created by Chandhru on 24/05/25.
//

import UIKit
import WebKit

class FeeDetails: UIViewController,WKNavigationDelegate, WKUIDelegate, refrech {
    func refreshClick(index: Int) {
        Refresh(id: transData[index].id ?? "")
    }
    
    @IBOutlet weak var transLabel: UILabel!
    @IBOutlet weak var transBtnName: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var reportsLb: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var tableOuterView: UIView!
    @IBOutlet weak var webOuterView: UIView!
    @IBOutlet weak var feeDetailTableView: UITableView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var LoadingLbl: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var menuNameLbl: UILabel!
    @IBOutlet weak var refreshBtn: UIButton!
    
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var global = UserDefaultFileManager.get_globalSelection()
    var feeDetailsList: [InvoiceItem] = []
    var isWebViewLoaded = false
    var receipt_url: [String] = []
    var popupWebViews: [WKWebView]  = []
    var transData: [transactionData] = [

//        transactionData(
//            id: "71967",
//            student_id: "52265468",
//            total_amount: "₹2",
//            order_status: "FAILED",
//            order_status_log: [:],
//            order_id: "Invoicemnx6xb4p",
//            created_on: "13-04-2026 06:20 PM",
//            order_status_update_on: "13-04-2026 06:20 PM"
//        ),
//
//        transactionData(
//            id: "71968",
//            student_id: "52265468",
//            total_amount: "₹800",
//            order_status: "PAID",
//            order_status_log: [:],
//            order_id: "Invoicemnx6t1cp",
//            created_on: "13-04-2026 06:17 PM",
//            order_status_update_on: "13-04-2026 06:17 PM"
//        )
    ]
    var alert = CustomAlert()
    var isreceptSelect : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        studentNameLbl.configureAsBackTitle(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        
        refreshBtn.layer.cornerRadius = 10
        
        createBtn.setTitle("Payment".translated(), for: .normal)
        refreshBtn.setTitle("Refresh".translated(), for: .normal)
        reportsBtn.setTitle("Receipt".translated(), for: .normal)
        transBtnName.setTitle("All Transactions".translated(), for: .normal)
        
        feeDetailTableView.register(
            UINib(nibName: CellConfingName.FeedetailTVC, bundle: nil),
            forCellReuseIdentifier: CellConfingName.FeedetailTVC
        )
        let nib = UINib(nibName: "PaymentHistoryCell", bundle: nil)
        feeDetailTableView.register(nib, forCellReuseIdentifier: "PaymentHistoryCell")
        feeDetailTableView.delegate = self
        feeDetailTableView.dataSource = self
        menuNameLbl.text = MenuStringFile.selectedMenuName
        tableOuterView.isHidden = true
        NodataImage.isHidden = true
        NoDataLbl.isHidden = true
        popupWebViews = []
        setupWebView()
        loadFeeURL()
    }


    func setupWebView() {

               webView.navigationDelegate = self
               webView.uiDelegate = self

               webView.configuration.preferences.javaScriptEnabled = true
               webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

               webView.scrollView.bounces = false
           }

           // MARK: - Load URL
           func loadFeeURL() {

               let baseURL = global?.fees_url ?? ""
               let studentId = studentDetails?.child_id ?? ""
               let schoolId = studentDetails?.school_id ?? ""

               let cleanedBase = baseURL.replacingOccurrences(of: ":student_id/:school_id", with: "")
               let finalURL = cleanedBase + "\(studentId)/\(schoolId)"

               print("Final Fee URL:", finalURL)

               if let url = URL(string: finalURL) {
                   webView.load(URLRequest(url: url))
               }
           }

    
    func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {

               if navigationAction.targetFrame == nil {

                   let newWebView = WKWebView(frame: webOuterView.bounds, configuration: configuration)
                   newWebView.navigationDelegate = self
                   newWebView.uiDelegate = self

                   webOuterView.addSubview(newWebView)

                   popupWebViews.append(newWebView)

                   return newWebView
               }
               return nil
           }

           // MARK: - CLOSE POPUP
           func webViewDidClose(_ webView: WKWebView) {

               if let index = popupWebViews.firstIndex(of: webView) {
                   let closingWebView = popupWebViews[index]
                   closingWebView.removeFromSuperview()
                   popupWebViews.remove(at: index)
               }
           }
 
   
    @IBAction func backBtn(_ sender: UIButton) {
        if !handleBack(){
            dismiss(animated: true)
        }
    }
    
    
    @IBAction func refreshBtnAct(_ sender: Any) {
        webView.stopLoading()
        webView.reload()
    }
    
    @IBAction func switchController(_ sender: UIButton) {
        let selectedIndex = sender.tag
        updateTabUI(for: selectedIndex)
        DispatchQueue.main.async { [self] in
            switch selectedIndex {
            case 0:
                isreceptSelect = false
                self.refreshBtn.isHidden = false
                self.webOuterView.isHidden = false
                self.tableOuterView.isHidden = true
            case 1:
                isreceptSelect = true
                self.refreshBtn.isHidden = true
                self.webOuterView.isHidden = true
                self.tableOuterView.isHidden = false
                LoadingView.isHidden = true
                ActivityIndicator.stopAnimating()
                Get_Fee_Invoice_Api()
            case 2:
                isreceptSelect = false
                self.refreshBtn.isHidden = true
                self.webOuterView.isHidden = true
                self.tableOuterView.isHidden = false
                LoadingView.isHidden = true
                ActivityIndicator.stopAnimating()
                //                       feeDetailTableView.reloadData()
                Get_transDetails()
            default:
                break
            }
           }
    }
    func updateTabUI(for index: Int) {

        createLbl.backgroundColor = index == 0 ? UIColor.parentClr : .clear
        reportsLb.backgroundColor = index == 1 ? UIColor.parentClr : .clear
        transLabel.backgroundColor = index == 2 ? UIColor.parentClr : .clear

        createBtn.tintColor = .black
        reportsBtn.tintColor = .black
        transBtnName.tintColor = .black
    }
    
    func Get_Fee_Invoice_Api(){
        showActivityLoader()
        APIService.shared.makeApi(url: ServiceUrl.fee_api_fee_details_student_invoice, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "", isBaseUrl: false) {[weak self] (result: Result<InvoiceDetailsResponse,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.feeDetailsList = success.data ?? []
                    self.NodataImage.isHidden = success.status ?? true
                    self.NoDataLbl.isHidden = success.status ?? true
                    self.NoDataLbl.text = success.message ?? ""
                    self.feeDetailTableView.reloadData()
                case .failure(let failure):
                    self.NodataImage.isHidden = false
                    self.NoDataLbl.isHidden = false
                    self.NoDataLbl.text = failure.localizedDescription
                    print("Error:", failure.localizedDescription)
                }
            }
        }
        
       hideActivityLoader()
    }
    
    func Get_transDetails(){
        
        APIService.shared.makeApi(url: ServiceUrl.online_payment_details_for_student, parameters: ["country_id" : UserDefaultFileManager.getCountryDetails()?.id ?? ""], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "", isBaseUrl: false) {[weak self] (result: Result<transactionDataSuc,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.transData = success.data ?? []
                    self.NodataImage.isHidden = success.status ?? true
                    self.NoDataLbl.isHidden = success.status ?? true
                    self.NoDataLbl.text = success.message ?? ""
                    self.feeDetailTableView.reloadData()
                        self.hideActivityLoader()
                case .failure(let failure):
                    self.NodataImage.isHidden = false
                    self.NoDataLbl.isHidden = false
                    self.NoDataLbl.text = failure.localizedDescription
                    print("Error:", failure.localizedDescription)
                    self.hideActivityLoader()
                }
            }
        }
    }
    
    func Get_Invoice_Receipt_Api(invoiceId: String){
        APIService.shared.makeApi(url: ServiceUrl.fee_api_fee_details_invoice_details, parameters: ["invoice_id": invoiceId], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "", isBaseUrl: false) {[weak self] (result: Result<CommonApiSuc,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true{
                        self.receipt_url = success.data ?? []
                        self.privewVc(url: self.receipt_url.first ?? "")
                    }else{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
            }
        }
    }
    
    func Refresh(id: String){
        self.showActivityLoader()
        APIService.shared.makeApi(url: ServiceUrl.update_unreceived_for_student, parameters: ["id": id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "", isBaseUrl: true) {[weak self] (result: Result<SecondCommonApiSuc,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let success):
                    if success.status == true{
                        self.Get_transDetails()
                    }else{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                        self.hideActivityLoader()
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                    self.hideActivityLoader()
                }
            }
        }
    }
}

extension FeeDetails: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isreceptSelect{
            return feeDetailsList.count
        }else{
            return transData.count
        }
       
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isreceptSelect{
            let cell = feeDetailTableView.dequeueReusableCell(withIdentifier: CellConfingName.FeedetailTVC, for: indexPath) as! FeedetailTVC
            let feeDetail = feeDetailsList[indexPath.row]
            let receiptText  = "Receipt No:".translated()
            cell.invoceNo.text = "\(receiptText) \(feeDetail.invoice_no ?? "")"
            let result = extractDateAndTime(from: feeDetail.invoice_date ?? "")
            cell.invoceDate.text = "\(result.date ?? "") \(result.time ?? "")"
            cell.timeLbl.text = result.time
            let paidAmountText  = "Paid Amount:".translated()
            cell.invoceAmount.text = "\(paidAmountText) \(feeDetail.invoice_amount ?? "")"
            let iconImage = UIImage(named: "pdf (1)")
            cell.document.image = iconImage
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryCell", for: indexPath) as! PaymentHistoryCell
            cell.configure(with: transData[indexPath.row])
            cell.refreshBtnName.tag = indexPath.row
            cell.refreshbtn = self
            return cell
        }
       
       
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isreceptSelect{
            let id = feeDetailsList[indexPath.row].id ?? ""
            Get_Invoice_Receipt_Api(invoiceId: id)
        }
    }
    
    func privewVc(url:String){
        var fileURL: [FilePath] = []
        fileURL.removeAll()
        fileURL.append(FilePath(url: url, type: ""))
        let vc = ImageShowVc()
        vc.fileURL = fileURL
        vc.subjectName = "Fee Receipt".translated()
        vc.isPaymentReceipt = true
        vc.index = 0
        vc.scrollIndex = IndexPath(row: 0, section: 0)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }

    func extractDateAndTime(from input: String) -> (date: String?, time: String?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent parsing

        guard let dateObject = formatter.date(from: input) else {
            return (nil, nil) // Return nils if parsing fails
        }

        // Format date
        formatter.dateFormat = "dd MMM yyyy"
        let dateString = formatter.string(from: dateObject)

        // Format time
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: dateObject)

        return (dateString, timeString)
    }

    
    
    // MARK: - WKNavigationDelegate Methods

       // Show loading animation when page starts loading
       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           LoadingView.isHidden = false
           ActivityIndicator.startAnimating()
       }

       // Hide loading animation when page finishes loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Stop loader
        LoadingView.isHidden = true
        ActivityIndicator.stopAnimating()
        guard let urlString = webView.url?.absoluteString else { return }
        print("callbackURL:", urlString)
        // Handle payment result
        if urlString.contains("/#/paymentsucccess/success") {
            
            alert.showAlert(
                title: "Payment Done".translated(),
                message: "Payment successful. You can download receipt in receipt tab.".translated(), on: self
            )
            
        } else if urlString.contains("/#/paymentsucccess/failed") {
            
            alert.showAlert(
                title: "Payment Failed".translated(),
                message: "Please try again later.".translated(), on: self
            )
        }
    }
 
    
    func webView(_ webView: WKWebView,
                        didFail navigation: WKNavigation!,
                        withError error: Error) {

               LoadingView.isHidden = true
               ActivityIndicator.stopAnimating()
               print("Error:", error.localizedDescription)
           }

           // MARK: - BACK HANDLING (Same as Android stack)
           func handleBack() -> Bool {

               if let lastPopup = popupWebViews.last {
                   lastPopup.removeFromSuperview()
                   popupWebViews.removeLast()
                   return true

               } else if webView.canGoBack {
                   webView.goBack()
                   return true
               }

               return false
           }
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        print("URL:", url.absoluteString)

        let scheme = url.scheme?.lowercased()

        let upiSchemes = ["upi", "tez", "phonepe", "paytmmp", "credpay","gpay"]

        if let scheme = scheme, upiSchemes.contains(scheme) {

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("❌ App not installed or scheme not allowed:", scheme)
            }

            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
    
    
                        
}


struct FeeDetailModel {
    var invoiceNumber: String
    var invoiceDate: String
    var invoiceAmount: String
    var pdfURL: String
    var generatedTime: String
    var fileSize: String
}

