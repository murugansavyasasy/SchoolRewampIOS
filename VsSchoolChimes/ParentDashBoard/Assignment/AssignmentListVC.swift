import UIKit

class AssignmentListVC: UIViewController,UISearchBarDelegate, DidSelectDelegate, SumitionDelegate{
    func sumition(index: Int) {
        if #available(iOS 14.0, *) {
            let vc = submitVC(nibName: nil, bundle: nil)
           // vc.modalPresentationStyle = .overCurrentContext
            vc.modalPresentationStyle = .fullScreen
           // vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.present(vc, animated: false)
        }
       
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var searchview: UISearchBar!
    var didSelectDelegate : DidSelectDelegate?
    let data = [Assigment(tittle: "Assigment1", subject: "English", dueDate: "19-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment2", subject: "Tamil nsdvhs dhs hgsdhsgv dchgv cgvdh hdgc sdvhd gcg", dueDate: "21-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment3", subject: "Science", dueDate: "22-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment4", subject: "Maths", dueDate: "24-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment5", subject: "Physics", dueDate: "26-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment6", subject: "Computer Science", dueDate: "28-11-2024", sendeBy: "vs2020sdfsdfghfhftvhdwxcvydywdscv vdy", sumissionCount: "1", date: "Nov 19 2025")]
    var filteredData :[Assigment]?
    
    var fileUrl : [FilePath] = [FilePath(url:"https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/Documents//sample.pdf" , type: "pdf"),FilePath(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/Documents//long-doc.txt", type: "txt"),FilePath(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/Documents//file-sample_500kB.docx", type: "docx")]
    
   
    var tapGesture: UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        backBtn.setTitle(ReceiverMenuItems.Assignment.translated(), for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        filteredData = data
        searchview.placeholder = CommonStringFile.Search.translated()
        searchview.delegate = self
        searchview.layer.borderWidth = 0
        searchview.backgroundImage = UIImage()
        searchview.addDoneButton()
       
        register()
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    func register(){
        listTable.register(UINib(nibName: CellConfingName.AssignmentListCTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AssignmentListCTVC)
    }
    func isDueDatePassed(dueDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        guard let dueDateObject = dateFormatter.date(from: dueDate) else {
            print("Invalid date format")
            return false
        }
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        // Compare dueDate with currentDate
        return dueDateObject < currentDate
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Automatically show the keyboard when search bar is clicked
        searchBar.becomeFirstResponder()
    }
    
}

// Table view delegate and data source
extension AssignmentListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0 // Adjust this based on your data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: CellConfingName.AssignmentListCTVC, for: indexPath) as! AssignmentListCTVC
        cell.tittleLbl.text = filteredData?[indexPath.row].tittle
        // Compare dueDate with current date
        if !isDueDatePassed(dueDate: filteredData?[indexPath.row].dueDate ?? "") {
            cell.dueDateLbl.textColor = .black
        } else {
            cell.dueDateLbl.textColor = .red
        }
        cell.FilesUrl = fileUrl
        cell.dueDateLbl.text = filteredData?[indexPath.row].dueDate
        cell.CreaterdDate.text = filteredData?[indexPath.row].date
       
      //  cell.didSelectDelegate = self
       // let viewTap = UITapGestureRecognizer(target: self, action: #selector(ViewAct))
       
        cell.Delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func ViewAct(_ sender: Any){
        
        let index = (sender as AnyObject).tag
        
        let vc = ImageShowVc(nibName: nil, bundle: nil)
        vc.FileURL = fileUrl
        vc.type = 0
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func select(index: Int, value: String?, Img: [String], Pdf: String?, text: String?, type: String) {
        didSelectDelegate?.select(index: index, value: value,Img:Img,Pdf:Pdf,text:text,type:type)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data
        if searchText.isEmpty {
            filteredData = data
        } else {
            filteredData = data.filter {
                $0.tittle.lowercased().contains(searchText.lowercased()) ||
                $0.subject.lowercased().contains(searchText.lowercased()) ||
                $0.dueDate.lowercased().contains(searchText.lowercased()) ||
                $0.sendeBy.lowercased().contains(searchText.lowercased()) ||
                $0.sumissionCount.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Reload the table view
        listTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredData = data
        listTable.reloadData()
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
}
struct Assigment{
    let tittle:String
    let subject:String
    let dueDate:String
    let sendeBy:String
    let sumissionCount:String
    let date:String
}
