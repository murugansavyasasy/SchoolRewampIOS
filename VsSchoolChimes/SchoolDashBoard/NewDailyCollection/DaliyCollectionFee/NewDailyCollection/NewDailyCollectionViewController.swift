
import UIKit
import DropDown

@available(iOS 15.0, *)
class NewDailyCollectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, Datepicker {
   
    func date(date: String) {
        if dateSelection == true{
            fromLbl.text = date
            daily_collectionApi(type: String(segmentName.selectedSegmentIndex+1))
        }else{
            todateLbl.text = date
            daily_collectionApi(type: String(segmentName.selectedSegmentIndex+1))
        }
    }
    
    @IBOutlet weak var totalCollectionView: UIView!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var Backbtn: UIButton!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var todateLbl: UILabel!
    @IBOutlet weak var TodateView: UIView!
    @IBOutlet weak var norecordLbl: UILabel!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var fromLbl: UILabel!
    
    var url_time : String!
    var url_hours : String!
    var url_minutes : String!
    var display_date : String!
    var url_date : String!
    let dropDown = DropDown()
    var indexList : Int!
    var ClickId = "1"
    let currentDateTime = Date()
    var currentdate : String!
    var SchoolId : String!
    var type : Int!
    var DropDownStr : [String] = []
    var dateSelection = false
    private var gradientLayer: CAGradientLayer?
    var dailyCollectionData: [DailyCollectionData] = [
        DailyCollectionData(
            category: "Current Year - First Term - School",
            total: "₹25000.00",
            fee_data: [
                FeeData(type_name: "School Fee", amount: "₹25000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Second Term - School",
            total: "₹15000.00",
            fee_data: [
                FeeData(type_name: "Book Fee", amount: "₹15000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Third Term - School",
            total: "₹18000.00",
            fee_data: [
                FeeData(type_name: "Exam Fee", amount: "₹18000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Hostel",
            total: "₹22000.00",
            fee_data: [
                FeeData(type_name: "Room Rent", amount: "₹12000.00"),
                FeeData(type_name: "Food", amount: "₹10000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Transport",
            total: "₹8000.00",
            fee_data: [
                FeeData(type_name: "Bus Fee", amount: "₹8000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Library",
            total: "₹3000.00",
            fee_data: [
                FeeData(type_name: "Library Fine", amount: "₹1000.00"),
                FeeData(type_name: "Membership", amount: "₹2000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Activities",
            total: "₹6000.00",
            fee_data: [
                FeeData(type_name: "Sports", amount: "₹4000.00"),
                FeeData(type_name: "Cultural", amount: "₹2000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Donation",
            total: "₹12000.00",
            fee_data: [
                FeeData(type_name: "Alumni Fund", amount: "₹5000.00"),
                FeeData(type_name: "Infrastructure", amount: "₹7000.00")
            ]
        ),
        DailyCollectionData(
            category: "Current Year - Extra Curricular",
            total: "₹4000.00",
            fee_data: [
                FeeData(type_name: "Dance", amount: "₹2500.00"),
                FeeData(type_name: "Music", amount: "₹1500.00")
            ]
        )
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadowAndCornerRadius(to: calendarView,cornerRadius: 6)
        Backbtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        Backbtn.configureAsBackButton(firstLine: MenuStringFile.DailyCollection, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        applyShadowAndCornerRadius(to: TodateView,cornerRadius: 6)
        Backbtn.applyBackButton()
        norecordLbl.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        currentdate = formattedDateTime
        fromLbl.text = formattedDateTime
        todateLbl.text = formattedDateTime
        tv.register(UINib(nibName: CellConfingName.FeePendingTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.FeePendingTVC)
//        tv.register(UINib(nibName: CellConfingName.PaymentHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.PaymentHeaderView)
//        tv.register(UINib(nibName: CellConfingName.PaymentTypeTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.PaymentTypeTVC)
        let fromdateTap = UITapGestureRecognizer(target: self, action: #selector(SelectFromDate))
        calendarView.addGestureRecognizer(fromdateTap)
        
        let todateTap = UITapGestureRecognizer(target: self, action: #selector(SelectToDate))
        TodateView.addGestureRecognizer(todateTap)
        tv.dataSource = self
        tv.delegate = self
        daily_collectionApi(type: "1")
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        totalCollectionView.layer.cornerRadius = 16
        totalCollectionView.layer.masksToBounds = false
        totalCollectionView.layer.shadowColor = UIColor.black.cgColor
        totalCollectionView.layer.shadowOpacity = 0.1
        totalCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        totalCollectionView.layer.shadowRadius = 8
        
    }

    
    
    @IBAction func segmentActBtn(_ sender: Any) {
        
        daily_collectionApi(type: String(segmentName.selectedSegmentIndex+1))
        
    }
    
    //MARK: Date Picker
    
    @IBAction func SelectFromDate(){
        dateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectToDate(){
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyCollectionData.count
    }

   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.FeePendingTVC, for: indexPath) as! FeePendingTVC
        
        let data = dailyCollectionData[indexPath.row]
        cell.keyNameLbl.text = data.category
        cell.valueLbl.text = data.total
        cell.configure(with: data.fee_data ?? [])
        
        applyShadowAndCornerRadius(to: cell.outerView,backgroundColor:.systemGray6)
        tv.layoutIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func daily_collectionApi(type:String){
        
        let fromdate = ConvertDateStringSmart(fromLbl.text)
        let todate = ConvertDateStringSmart(todateLbl.text)
        APIService.shared
            .makeApi(url: ServiceUrl.api_fee_report_daily_collection , parameters: [
                
                Daily_collectionStringFile.from_date : fromdate,
                Daily_collectionStringFile.to_date : todate,
                Daily_collectionStringFile.type : type
                
            ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <DailyCollectionResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            tv.isHidden = false
                            norecordLbl.isHidden = true
                            dailyCollectionData = successMessage.data?.first?.pending_details ?? []
                           
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            totalAmountLbl.text = ""
                            tv.isHidden = true
                            norecordLbl.isHidden = false
                            norecordLbl.text = successMessage.message
//                            dailyCollectionData = successMessage.data ?? []
                            tv.reloadData()
                        }
                       
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        tv.isHidden = true
                        totalAmountLbl.text = ""
                        norecordLbl.isHidden = false
                        norecordLbl.text = error.localizedDescription
                        print(error.localizedDescription)
                    }
                }
            }
    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude // returns minimal height ≈ 0
//    }

    
}


import UIKit

extension UIButton {
    func configureAsBackButton(firstLine: String, secondLine: String) {
        let fullTitle = "\(firstLine)\n\(secondLine)"

        // Set the back arrow image
        let image = UIImage(systemName: "chevron.left")
        self.setImage(image, for: .normal)

        // Configure paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 3

        // Create attributed title
        let attributedTitle = NSMutableAttributedString(
            string: fullTitle,
            attributes: [
                .font: UIFont(name: "Poppins-Bold", size: 15),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
        )

        // Apply style to second line
        let secondLineRange = (fullTitle as NSString).range(of: secondLine)
        if secondLineRange.location != NSNotFound {
            attributedTitle.addAttributes([
                .font: UIFont(name: "Poppins-Bold", size: 11),
                .foregroundColor: UIColor.black.withAlphaComponent(0.6)
            ], range: secondLineRange)
        }

        // Configure title label
        self.titleLabel?.numberOfLines = 3
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.textAlignment = .left

        // Apply attributed title
        self.setAttributedTitle(attributedTitle, for: .normal)

        // Adjust content and insets
        self.contentHorizontalAlignment = .left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
