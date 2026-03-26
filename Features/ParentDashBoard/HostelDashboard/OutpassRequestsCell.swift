import UIKit
protocol newRequestScreen: AnyObject {
    func newOutpassVc ()
}
class OutpassRequestsCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var Tv: SelfSizingTableView!
    var newRequestdelegate : newRequestScreen?
    var  outPassData: [OutPassRequest]?
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
        Tv.register(outpassRequestTVcell.self)
    }

  
    func configure(data : [OutPassRequest]){
        outPassData = data
        Tv.delegate = self
        Tv.dataSource = self
        Tv.reloadData()
    }
    @IBAction func NewOutpassBtnName(_ sender: UIButton) {
        newRequestdelegate?.newOutpassVc()
    }
   
}
extension OutpassRequestsCell : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return outPassData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "outpassRequestTVcell", for: indexPath) as! outpassRequestTVcell
        
        let data = outPassData?[indexPath.row]
        cell.reasonLbl.text = data?.reason
        cell.RequestTimeLbl.text = "Requested : \(data?.request_time ?? "")"
        let input = data?.fromdate_todate ?? ""
        let output = formatFromToDate(input)
        cell.outPassTimeLbl.text = output
        cell.statusLbl.text = data?.status
        return cell
    }
    
    func formatFromToDate(_ input: String) -> String {
        
        let parts = input.components(separatedBy: " - ")
        guard parts.count == 2 else { return input }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
        
        let fromDate = inputFormatter.date(from: parts[0])
        let toDate = inputFormatter.date(from: parts[1])
        
        let fromString = fromDate != nil ? outputFormatter.string(from: fromDate!) : parts[0]
        let toString = toDate != nil ? outputFormatter.string(from: toDate!) : parts[1]
        
        return "\(fromString) - \(toString)"
    }
    
    
    
}
