
import UIKit
import DropDown

@available(iOS 15.0, *)
class NewDailyCollectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, Datepicker {
    
    func date(date: String) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
//        if dateSelection {
//            fromLbl.text = date
//            if let toDateText = todateLbl.text,
//               let fromDate = formatter.date(from: date),
//               let toDate = formatter.date(from: toDateText),
//               fromDate > toDate {
//                todateLbl.text = date
//            }
//        } else {
//            todateLbl.text = date
//            if let fromDateText = fromLbl.text,
//               let fromDate = formatter.date(from: fromDateText),
//               let toDate = formatter.date(from: date),
//               fromDate > toDate {
//                todateLbl.text = fromDateText
//            }
//        }
        
        if dateSelection {
            fromLbl.text = date
            from_date = formatter.date(from: date)
            
        }else{
            todateLbl.text = date
            To_date = formatter.date(from: date)
        }
        
        daily_collectionApi(type: String(segmentName.selectedSegmentIndex + 1))
    }
    
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var norecordImg: UIImageView!
    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var totalCollectionLblTitle: UILabel!
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
    var dailyCollectionData: [DailyCollectionData] = []
    var from_date : Date?
    var To_date : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadowAndCornerRadius(to: calendarView,cornerRadius: 6)
        Backbtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        toDateLbl.setFont(style: .title, size: FontSize.BodySize)
        fromDateLbl.setFont(style: .title, size: FontSize.BodySize)
        Backbtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        applyShadowAndCornerRadius(to: TodateView,cornerRadius: 6)
        Backbtn.applyBackButton()
        norecordLbl.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyy"
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        currentdate = formattedDateTime
        fromLbl.text = formattedDateTime
        todateLbl.text = formattedDateTime
        tv.register(UINib(nibName: CellConfingName.FeePendingTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.FeePendingTVC)
        let fromdateTap = UITapGestureRecognizer(target: self, action: #selector(SelectFromDate))
        calendarView.addGestureRecognizer(fromdateTap)
        segmentName.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segmentName.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentName.selectedSegmentTintColor = .primery
        let todateTap = UITapGestureRecognizer(target: self, action: #selector(SelectToDate))
        TodateView.addGestureRecognizer(todateTap)
        tv.dataSource = self
        tv.delegate = self
        daily_collectionApi(type: "1")
    }
    override func viewDidLayoutSubviews() {
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
        vc.date = fromLbl.text
        if let maxDate = To_date{
            vc.maximumDate = maxDate
        }else{
            vc.maximumDate = Date()
        }
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectToDate(){
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = todateLbl.text
        vc.maximumDate = Date()
        if let minDate = from_date{
            vc.minimumDate = minDate
        }
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
        
//        applyShadowAndCornerRadius(to: cell.outerView,backgroundColor:.systemGray6)
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
                    DispatchQueue.main.async { [self] in
                        tv.isHidden = false
                        
                        dailyCollectionData = successMessage.data?.first?.collections ?? []
                        totalAmountLbl.text = successMessage.data?.first?.total_collection
                        totalCollectionLblTitle.isHidden = successMessage.data?.count == 0
//                        if let fromDate = parseDate(from: fromdate),
//                           let toDate = parseDate(from: todate) {
//                            totalCollectionLblTitle.text = "Total Collection \(getDateRangeLabel(from: fromDate, to: toDate))"
//                        }
//                        titleStack.isHidden = successMessage.data?.count == 0
                        tv.isHidden = successMessage.data?.count == 0
                        tv.reloadData()
                        norecordLbl.isHidden = successMessage.data?.count != 0
                        norecordLbl.text = successMessage.message
                        norecordImg.isHidden = successMessage.data?.count != 0
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
    
}


import UIKit

extension UIButton {
    
    
//        func configureAsBackButton(firstLine: String, secondLine: String) {
//            let fullTitle = "\(firstLine)\n\(secondLine)"
//            
//            // Force Plain style (iOS 15+ only)
//            if #available(iOS 15.0, *) {
//                self.configuration = .plain()
//                self.configuration?.contentInsets = .zero // remove default paddings
//            }
//            
//            // Set the back arrow image
//            let image = UIImage(systemName: "chevron.left")
//            self.setImage(image, for: .normal)
//            
//            // Configure paragraph style
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.alignment = .left
//            paragraphStyle.lineSpacing = 1
//            
//            // Create attributed title
//            let attributedTitle = NSMutableAttributedString(
//                string: fullTitle,
//                attributes: [
//                    .font: UIFont(name: "Poppins-Medium", size: 13) as Any,
//                    .paragraphStyle: paragraphStyle
//                ]
//            )
//            
//            // Apply style to second line
//            let secondLineRange = (fullTitle as NSString).range(of: secondLine)
//            if secondLineRange.location != NSNotFound {
//                attributedTitle.addAttributes([
//                    .font: UIFont(name: "Poppins-Medium", size: 12) as Any
//                ], range: secondLineRange)
//            }
//            
//            // Configure title label
//            self.titleLabel?.numberOfLines = 0
//            self.titleLabel?.lineBreakMode = .byWordWrapping
//            self.titleLabel?.textAlignment = .left
//            
//            // Apply attributed title
//            self.setAttributedTitle(attributedTitle, for: .normal)
//            
//            // Adjust content and insets
//            self.contentHorizontalAlignment = .left
//            self.contentVerticalAlignment = .center
//            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
//            self.imageEdgeInsets = .zero
//            self.contentEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
//        }
    
    func configureAsBackButton(firstLine: String, secondLine: String) {
            let fullTitle = "\(firstLine)\n\(secondLine)"
            
            // Don’t use UIButton.Configuration → gives us control
           // self.configuration = nil
            
            // Set the back arrow image
            let image = UIImage(systemName: "chevron.left")
            self.setImage(image, for: .normal)
            
            // Configure paragraph style (reduce vertical space between lines)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 1  // tighter line spacing
            
            // Create attributed title
            let attributedTitle = NSMutableAttributedString(
                string: fullTitle,
                attributes: [
                    .font: UIFont(name: "Poppins-Bold", size: 15) as Any,
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            // Apply style to second line (smaller font)
            let secondLineRange = (fullTitle as NSString).range(of: secondLine)
            if secondLineRange.location != NSNotFound {
                attributedTitle.addAttributes([
                    .font: UIFont(name: "Poppins-Bold", size: 11) as Any
                ], range: secondLineRange)
            }
            
            // Configure title label
            self.titleLabel?.numberOfLines = 0
            self.titleLabel?.lineBreakMode = .byWordWrapping
            self.titleLabel?.textAlignment = .left
            
            // Apply attributed title
            self.setAttributedTitle(attributedTitle, for: .normal)
            
            // Alignments
            self.contentHorizontalAlignment = .left
            self.contentVerticalAlignment = .center
            
            // Add more space between image and text
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            self.imageEdgeInsets = .zero
            self.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        }

//        func configureAsBackButton(firstLine: String, secondLine: String, colour: UIColor) {
//            let fullTitle = "\(firstLine)\n\(secondLine)"
//            
//            // Set the back arrow image
//            let image = UIImage(systemName: "chevron.left")
//            self.setImage(image, for: .normal)
//            
//            // Configure paragraph style
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.alignment = .left
//            paragraphStyle.lineSpacing = 3
//            paragraphStyle.lineBreakMode = .byWordWrapping
//            
//            // Create attributed title
//            let attributedTitle = NSMutableAttributedString(
//                string: fullTitle,
//                attributes: [
//                    .font: UIFont(name: "Poppins-Medium", size: 13)!,
//                    .foregroundColor: colour,
//                    .paragraphStyle: paragraphStyle
//                ]
//            )
//            
//            // Apply style to second line
//            let secondLineRange = (fullTitle as NSString).range(of: secondLine)
//            if secondLineRange.location != NSNotFound {
//                attributedTitle.addAttributes([
//                    .font: UIFont(name: "Poppins-Medium", size: 12)!,
//                    .foregroundColor: colour.withAlphaComponent(0.8),
//                    .paragraphStyle: paragraphStyle
//                ], range: secondLineRange)
//            }
//            
//            // Configure title label
//            self.titleLabel?.numberOfLines = 0              // allow multiple lines
//            self.titleLabel?.lineBreakMode = .byWordWrapping
//            self.titleLabel?.textAlignment = .left
//            
//            // Apply attributed title
//            self.setAttributedTitle(attributedTitle, for: .normal)
//            
//            // Adjust content and insets
//            self.contentHorizontalAlignment = .left
//            self.contentVerticalAlignment = .center
//            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
//            self.imageEdgeInsets = .zero
//            self.contentEdgeInsets = .zero
//            
//            // 🔑 Auto resize the button to fit multi-line text
//            self.sizeToFit()
//        }
    

}
