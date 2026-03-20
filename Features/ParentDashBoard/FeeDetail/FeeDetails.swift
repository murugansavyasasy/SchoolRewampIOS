//
//  FeeDetails.swift
//  School Chimes
//
//  Created by Chandhru on 24/05/25.
//

import UIKit
import WebKit

class FeeDetails: UIViewController,WKNavigationDelegate, WKUIDelegate {
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
    var alert = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        studentNameLbl.configureAsBackTitle(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        
        refreshBtn.layer.cornerRadius = 10
        feeDetailTableView.register(
            UINib(nibName: CellConfingName.FeedetailTVC, bundle: nil),
            forCellReuseIdentifier: CellConfingName.FeedetailTVC
        )
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
            UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: { [self] in
                   switch selectedIndex {
                   case 0:
                       self.refreshBtn.isHidden = false
                       self.webOuterView.isHidden = false
                       self.tableOuterView.isHidden = true
                   case 1:
                       self.refreshBtn.isHidden = true
                       self.webOuterView.isHidden = true
                       self.tableOuterView.isHidden = false
                       LoadingView.isHidden = true
                       ActivityIndicator.stopAnimating()
                       Get_Fee_Invoice_Api()
                   default:
                       break
                   }
               })
           }
    }
    func updateTabUI(for index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.createLbl.backgroundColor = index == 0 ? UIColor.parentClr : .clear
            self.reportsLb.backgroundColor = index == 0 ? .clear : UIColor.parentClr
            self.reportsBtn.tintColor = index == 0 ? .black : UIColor.parentClr
            self.createBtn.tintColor = index == 1 ? .black : UIColor.parentClr
        }
    }
    
    func Get_Fee_Invoice_Api(){
        
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
}

extension FeeDetails: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeDetailsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feeDetailTableView.dequeueReusableCell(withIdentifier: CellConfingName.FeedetailTVC, for: indexPath) as! FeedetailTVC
        let feeDetail = feeDetailsList[indexPath.row]
        cell.invoceNo.text = "Receipt No: \(feeDetail.invoice_no ?? "")"
        let result = extractDateAndTime(from: feeDetail.invoice_date ?? "")
        cell.invoceDate.text = "\(result.date ?? "") \(result.time ?? "")"
        cell.timeLbl.text = result.time
        cell.invoceAmount.text = "Paid Amount: \(feeDetail.invoice_amount ?? "")"
        let iconImage = UIImage(named: "pdf (1)")
        cell.document.image = iconImage
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = feeDetailsList[indexPath.row].id ?? ""
        Get_Invoice_Receipt_Api(invoiceId: id)
    }
    
    func privewVc(url:String){
        var fileURL: [FilePath] = []
        fileURL.removeAll()
        fileURL.append(FilePath(url: url, type: ""))
        let vc = ImageShowVc()
        vc.fileURL = fileURL
        vc.subjectName = "Fee Receipt"
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
                title: "Payment Done",
                message: "Payment successful. You can download receipt in receipt tab.", on: self
            )
            
        } else if urlString.contains("/#/paymentsucccess/failed") {
            
            alert.showAlert(
                title: "Payment Failed",
                message: "Please try again later.", on: self
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

