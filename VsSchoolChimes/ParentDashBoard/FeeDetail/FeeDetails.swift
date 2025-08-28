//
//  FeeDetails.swift
//  School Chimes
//
//  Created by Chandhru on 24/05/25.
//

import UIKit
import WebKit

class FeeDetails: UIViewController {
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var reportsLb: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var tableOuterView: UIView!
    @IBOutlet weak var webOuterView: UIView!
    @IBOutlet weak var feeDetailTableView: UITableView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backBtn: UIButton!
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var feeDetailsList: [FeeDetailModel] = []
    var isWebViewLoaded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn.configureAsBackButton(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        tableOuterView.isHidden = true
        if let pdfURL = URL(string: "https://profile.schoolchimes.com/#/online-fee-payment/13601818/6063") {
            let request = URLRequest(url: pdfURL)
            webView.load(request)
        } else {
            print("Invalid URL")
        }

        // Register custom cell
        feeDetailTableView.register(UINib(nibName: "FeedetailTVC", bundle: nil), forCellReuseIdentifier: "FeedetailTVC")
        feeDetailTableView.delegate = self
        feeDetailTableView.dataSource = self
        loadDummyData()
    }

    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func switchController(_ sender: UIButton) {
        let selectedIndex = sender.tag
        updateTabUI(for: selectedIndex)
        DispatchQueue.main.async { [self] in
            UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: { [self] in
                   switch selectedIndex {
                   case 0:
                       self.webOuterView.isHidden = false
                       self.tableOuterView.isHidden = true
                       
                   case 1:
                       self.webOuterView.isHidden = true
                       self.tableOuterView.isHidden = false
                       self.feeDetailTableView.reloadData()
                       
                   default:
                       break
                   }
               })
           }
    }
    func updateTabUI(for index: Int) {
        UIView.animate(withDuration: 0.25) {
//            self.searcchBtn.isHidden = index == 0
            self.createLbl.backgroundColor = index == 0 ? UIColor.parentClr : .clear
            self.reportsLb.backgroundColor = index == 0 ? .clear : UIColor.parentClr
            self.reportsBtn.tintColor = index == 0 ? .black : UIColor.parentClr
            self.createBtn.tintColor = index == 1 ? .black : UIColor.parentClr
        }
    }
    func loadDummyData() {
        feeDetailsList = [
            FeeDetailModel(invoiceNumber: "INV001", invoiceDate: "01-05-2025", invoiceAmount: "₹1200", pdfURL: "https://schoolchimes-fee-receipts.s3.ap-south-1.amazonaws.com/undefined/fee_receipt/PDF_1748065242703.pdf", generatedTime: "10:45 AM", fileSize: "234 KB"),
            FeeDetailModel(invoiceNumber: "INV002", invoiceDate: "02-05-2025", invoiceAmount: "₹1500", pdfURL: "https://schoolchimes-fee-receipts.s3.ap-south-1.amazonaws.com/undefined/fee_receipt/PDF_1748065242703.pdf", generatedTime: "11:00 AM", fileSize: "187 KB"),
            FeeDetailModel(invoiceNumber: "INV003", invoiceDate: "03-05-2025", invoiceAmount: "₹1800", pdfURL: "https://schoolchimes-fee-receipts.s3.ap-south-1.amazonaws.com/undefined/fee_receipt/PDF_1748065242703.pdf", generatedTime: "09:20 AM", fileSize: "210 KB"),
            FeeDetailModel(invoiceNumber: "INV004", invoiceDate: "04-05-2025", invoiceAmount: "₹2000", pdfURL: "https://schoolchimes-fee-receipts.s3.ap-south-1.amazonaws.com/undefined/fee_receipt/PDF_1748065242703.pdf", generatedTime: "08:30 AM", fileSize: "199 KB"),
            FeeDetailModel(invoiceNumber: "INV005", invoiceDate: "05-05-2025", invoiceAmount: "₹1750", pdfURL: "https://schoolchimes-fee-receipts.s3.ap-south-1.amazonaws.com/undefined/fee_receipt/PDF_1748065242703.pdf", generatedTime: "12:10 PM", fileSize: "220 KB")
        ]
    }

}

extension FeeDetails: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeDetailsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feeDetailTableView.dequeueReusableCell(withIdentifier: "FeedetailTVC", for: indexPath) as! FeedetailTVC
        let feeDetail = feeDetailsList[indexPath.row]

        cell.invoceNo.text = "InvoiceNo: \(feeDetail.invoiceNumber)"
        cell.invoceDate.text = "Invoice Date: \(feeDetail.invoiceDate)"
        cell.invoceAmount.text = "Invoice Amount: \(feeDetail.invoiceAmount)"
        cell.timeLbl.text = feeDetail.generatedTime
        cell.sizeLbl.text = feeDetail.fileSize

        let fileURL = URL(fileURLWithPath: feeDetail.pdfURL)
        let iconName = getFileIconName(for: fileURL)
        let iconImage = UIImage(named: iconName)
        cell.document.image = iconImage

        return cell
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feeDetail = feeDetailsList[indexPath.row]
        let fileURL = URL(fileURLWithPath: feeDetail.pdfURL)
        let ViewPaymentVC = ViewPaymentVC(nibName: nil, bundle: nil)
        ViewPaymentVC.documentURL = fileURL
        ViewPaymentVC.modalPresentationStyle = .fullScreen
        present(ViewPaymentVC, animated: true)
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

