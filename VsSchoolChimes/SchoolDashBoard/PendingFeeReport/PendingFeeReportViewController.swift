//
//  PendingFeeReportViewController.swift
//  VoicesnapSchoolApp
//
//  Created by chandhru on 22/04/24.

import UIKit
import DropDown

@available(iOS 15.0, *)
class PendingFeeReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pendingStack: UIStackView!
    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var totalfeeLbl: UILabel!
    @IBOutlet weak var switchReport: UISegmentedControl!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noRecordsView: UIImageView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var acodemicView: UIView!
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

    override func viewDidLoad() {
        super.viewDidLoad()

        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        DropDownStr = ["2012 - 2013", "2014 - 2015", "2016 - 2017", "2018 - 2019"]

        applyShadowAndCornerRadius(to: acodemicView)
        nodataLbl.isHidden = true
        noRecordsView.isHidden = true

        tv.register(UINib(nibName: CellConfingName.FeePendingTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.FeePendingTVC)
        tv.delegate = self
        tv.dataSource = self
        tv.estimatedRowHeight = 100
        tv.rowHeight = UITableView.automaticDimension

        getacadmicYr()
    }

    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    

    func getacadmicYr() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
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
        }
    }

    func getPendingReportAPI(_ academic_year_id: Int) {
        APIService.shared.makeApi(
            url: ServiceUrl.api_fee_report_detailed_pending_report,
            parameters: ["academic_year_id": academic_year_id],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
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
        }
    }

    func classPendingReportAPI(_ academic_year_id: Int) {
        APIService.shared.makeApi(
            url: ServiceUrl.api_fee_report_detailed_class_wise_pending_report,
            parameters: ["academic_year_id": academic_year_id],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
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
            switchReport.selectedSegmentIndex == 0 ?
                getPendingReportAPI(academicId ?? 0) :
                classPendingReportAPI(academicId ?? 0)
        }
    }

    @IBAction func switchTab(_ sender: UISegmentedControl) {
        switchReport.selectedSegmentIndex == 0 ?
            getPendingReportAPI(academicId ?? 0) :
            classPendingReportAPI(academicId ?? 0)
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
