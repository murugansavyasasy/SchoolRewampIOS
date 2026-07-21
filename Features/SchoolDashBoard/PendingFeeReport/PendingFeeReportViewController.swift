//
//  PendingFeeReportViewController.swift
//  VoicesnapSchoolApp
//
//  Created by chandhru on 22/04/25.

import UIKit


@available(iOS 15.0, *)
class PendingFeeReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var pendingStack: UIStackView!
    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var totalfeeLbl: UILabel!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var reportsLb: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noRecordsView: UIImageView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var acodemicdropView: UIView!
    @IBOutlet weak var acodomicYearLbl: UILabel!

    let dropDown = DropDown()
    let acidamicdrops = DropDown()
    var DropDownStr: [String] = []
    var accadimYr: [String] = []
    var AcadimicYearDatas: [AcadimicYearData] = []

    var url_time: String!
    var url_hours: String!
    var url_minutes: String!
    var display_date: String!
    var url_date: String!
    var indexList: Int!
    var ClickId = "1"
    var academicId: Int?
    var SchoolId = String()
    var type: Int!
    var PendingReports: [PendingDetail]?
    var classWiseReport: [PendingDetail]?
    var feeSections: [PendingDetail] = []
    var selectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        DropDownStr = ["2012 - 2013", "2014 - 2015", "2016 - 2017", "2018 - 2019"]
        nodataLbl.isHidden = true
        noRecordsView.isHidden = true

        tv.register(UINib(nibName: CellConfingName.FeePendingTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.FeePendingTVC)
        tv.delegate = self
        tv.dataSource = self
        tv.estimatedRowHeight = 100
        tv.rowHeight = UITableView.automaticDimension
        acodemicdropView.layer.cornerRadius = 8
        acodemicdropView.layer.borderWidth = 1
        acodemicdropView.layer.borderColor = UIColor.white.cgColor
        getacadmicYr()
    }

    func getacadmicYr() {
        showActivityLoader()
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [self] (result: Result<get_academic_yearSuc, Error>) in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    AcadimicYearDatas = response.data ?? []
                    nodata(true)
                    for year in AcadimicYearDatas where year.current_academic_year == true {
                        acodomicYearLbl.text = year.year
                        academicId = year.id
                        getPendingReportAPI(academicId ?? 0)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                nodata(false)
            }
            hideActivityLoader()
        }
    }

    func getPendingReportAPI(_ academic_year_id: Int) {
        showActivityLoader()
        APIService.shared.makeApi(
            url: ServiceUrl.api_fee_report_detailed_pending_report,
            parameters: ["academic_year_id": academic_year_id,"country_id":  UserDefaultFileManager.getCountryDetails()?.id ?? ""],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [self] (result: Result<PendingReportsResponse, Error>) in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    PendingReports = response.data?.first?.pending_details
                    totalfeeLbl.text = response.data?.first?.total_pending
                    nodata(!(response.data?.isEmpty ?? true))
                    pendingStack.isHidden = response.data?.count == 0
                    titleStack.isHidden = response.data?.count == 0
                    tv.isHidden = response.data?.count == 0
                    nodataLbl.text = response.message
                    tv.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                nodata(false)
            }
            hideActivityLoader()
        }
    }

    func classPendingReportAPI(_ academic_year_id: Int) {
        showActivityLoader()
        APIService.shared.makeApi(
            url: ServiceUrl.api_fee_report_detailed_class_wise_pending_report,
            parameters: ["academic_year_id": academic_year_id,"country_id" : UserDefaultFileManager.getCountryDetails()?.id ?? "" ],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [self] (result: Result<PendingReportsResponse, Error>) in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    PendingReports = response.data?.first?.pending_details
                    totalfeeLbl.text = response.data?.first?.total_pending
                    nodata(!(response.data?.isEmpty ?? true))
                    pendingStack.isHidden = response.data?.count == 0
                    titleStack.isHidden = response.data?.count == 0
                    tv.isHidden = response.data?.count == 0
                    nodataLbl.text = response.message
                    tv.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                nodata(false)
            }
            hideActivityLoader()
        }
    }

    func nodata(_ hide: Bool) {
        nodataLbl.isHidden = hide
        noRecordsView.isHidden = hide
    }

    @IBAction func selectAcodemic(_ sender: UIButton) {
        accadimYr = AcadimicYearDatas.compactMap { $0.year }
        acidamicdrops.anchorView = acodemicdropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodemicdropView.bounds.height)
        acidamicdrops.show()

        acidamicdrops.selectionAction = { [self] (index: Int, item: String) in
            acodomicYearLbl.text = item
            academicId = AcadimicYearDatas[index].id
            selectedIndex == 0 ?
                getPendingReportAPI(academicId ?? 0) :classPendingReportAPI(academicId ?? 0)
        }
    }
    @IBAction func switchController(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateTabUI(for: selectedIndex)
        selectedIndex == 0 ?
            getPendingReportAPI(academicId ?? 0) :
            classPendingReportAPI(academicId ?? 0)
    }

    func updateTabUI(for index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.createLbl.backgroundColor = index == 0 ? UIColor.parentClr : .clear
            self.reportsLb.backgroundColor = index == 0 ? .clear : UIColor.parentClr
            self.reportsBtn.tintColor = index == 0 ? .black : UIColor.parentClr
            self.createBtn.tintColor = index == 1 ? .black : UIColor.parentClr
        }
    }
    @IBAction func backAct() {
        dismiss(animated: true)
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PendingReports?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.FeePendingTVC, for: indexPath) as! FeePendingTVC
        let data = PendingReports?[indexPath.row]
        cell.keyNameLbl.text = data?.category
        cell.valueLbl.text = data?.total
        cell.pendingFee = true
        cell.configure(with: data?.pending_data ?? [])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
