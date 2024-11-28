import UIKit

class AssignmentListVC: UIViewController,UISearchBarDelegate, DidSelectDelegate{
    
    
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var searchview: UISearchBar!
    var didSelectDelegate : DidSelectDelegate?
    let data = [Assigment(tittle: "Assigment1", subject: "English", dueDate: "19-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment2", subject: "Tamil nsdvhs dhs hgsdhsgv dchgv cgvdh hdgc sdvhd gcg", dueDate: "21-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment3", subject: "Science", dueDate: "22-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment4", subject: "Maths", dueDate: "24-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment5", subject: "Physics", dueDate: "26-11-2024", sendeBy: "vs2020", sumissionCount: "1", date: "Nov 19 2025"),Assigment(tittle: "Assigment6", subject: "Computer Science", dueDate: "28-11-2024", sendeBy: "vs2020sdfsdfghfhftvhdwxcvydywdscv vdy", sumissionCount: "1", date: "Nov 19 2025")]
    var filteredData :[Assigment]?
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredData = data
        searchview.placeholder = "Search..."
        searchview.delegate = self
        searchview.layer.borderWidth = 0
        searchview.backgroundImage = UIImage()
        keyboardDionebtn()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCliboard(_:)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        register()
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
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        searchview.inputAccessoryView = toolbar
    }
    @objc func doneButtonTapped() {
        view.endEditing(true)  // Dismiss the keyboard
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Automatically show the keyboard when search bar is clicked
        searchBar.becomeFirstResponder()
    }
    
    @objc func handleCliboard(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
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
        cell.subjectLbl.text = filteredData?[indexPath.row].subject
        // Compare dueDate with current date
        if !isDueDatePassed(dueDate: filteredData?[indexPath.row].dueDate ?? "") {
            cell.dueDateLbl.textColor = .black
        } else {
            cell.dueDateLbl.textColor = .red
        }
        cell.dueDateLbl.text = filteredData?[indexPath.row].dueDate
        cell.CreaterdDate.text = filteredData?[indexPath.row].date
        cell.viewBtn.tag = indexPath.row
        cell.didSelectDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
