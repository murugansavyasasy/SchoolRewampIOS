
import UIKit

class SectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var noRecordView: UIView!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    var classNAme = ""
    
    var SectionName = ""
    var ClickID = 0
    
    var sectionId : String?
    var DateRef : String?
    
    var section_wiseData: [SectionWise]?
    var absentStudentData: [AbsentisReportStudent]?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        cv.register(UINib(nibName: CellConfingName.SectionCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.SectionCollectionViewCell)
        cv.dataSource = self
        cv.delegate = self
        noRecordView.isHidden = true
        noRecordLbl.isHidden = true
        //        let backViews = UITapGestureRecognizer(target: self, action: #selector(BackVc))
        //        backView.addGestureRecognizer(backViews)
        let rowNib = UINib(nibName: CellConfingName.SectionTvTableViewCell, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: CellConfingName.SectionTvTableViewCell)
        tv.delegate = self
        tv.dataSource = self
        
        
        guard let  sectionIds = sectionId, let DateRefs = DateRef else { return }
        
        AbsentStudent(sectionId:sectionIds,date:DateRefs)
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @IBAction func BackAct(){
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return absentStudentData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.SectionTvTableViewCell,
            for: indexPath) as? SectionTvTableViewCell else{
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.nameLbl.text = absentStudentData?[indexPath.row].student_name
        cell.mobileNumberLbl.text = absentStudentData?[indexPath.row].primary_mobile
        cell.SectionLbl.isHidden = true
        //        cell.SectionLbl.text = absentStudentData[indexPath.row].s
        cell.AddmisionLbl.text = absentStudentData?[indexPath.row].admission_no
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section_wiseData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.SectionCollectionViewCell ,
            for: indexPath) as? SectionCollectionViewCell else{
            
            return UICollectionViewCell()
        }
        
        if ClickID == indexPath.row {
            cell.sectionClick.backgroundColor = .gradient1
            cell.sectionNameLbl.textColor = .black
            cell.absentcountLbl.textColor = .black
        }
        else{
            cell.sectionClick.backgroundColor = .systemGray6
            cell.sectionNameLbl.textColor = .gray
            cell.absentcountLbl.textColor = .gray
        }
        
        
        
        return cell
    }
    
    @IBAction func SectionclikVc(ges : SectionClick){
        SectionName = ges.SectionName
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        cv.dataSource = self
        cv.delegate = self
        cv.reloadData()
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 157, height: 58)
    }
    
    
    
    
    func AbsentStudent(sectionId:String,date:String) {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(
            url: ServiceUrl.api_school_event_get_event,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:staffDetails?.access_token ?? "") { [self] (result: Result<AbsentisReportStudentResponse, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self.hideLottieProgressLoader()
                    }
                    
                    switch result {
                    case .success(let successMessage):
                        self.absentStudentData = successMessage.data
                        self.tv.reloadData()
                        if self.absentStudentData?.count == 0{
                            self.noRecordLbl.text = successMessage.message
                            self.noRecordLbl.isHidden = false
                            
                            self.tv.isHidden = true
                            
                        }else{
                            self.noRecordLbl.isHidden = true
                            self.tv.isHidden = false
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        if self.absentStudentData?.count == 0{
                            self.noRecordLbl.text = error.localizedDescription
                            self.noRecordLbl.isHidden = false
                            self.tv.isHidden = true
                        }
                        
                    }
                }
            }
    }
    
    
}
class SectionClick : UITapGestureRecognizer{
    var SectionName = ""
}




