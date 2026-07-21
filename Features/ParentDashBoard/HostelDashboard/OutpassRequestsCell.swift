import UIKit
protocol newRequestScreen: AnyObject {
    func newOutpassVc ()
}
class OutpassRequestsCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var Tv: SelfSizingTableView!
    @IBOutlet weak var seeMoreBtn: UIButton!
    var newRequestdelegate : newRequestScreen?
    var  outPassData: [OutPassRequest]?
    var onSeeMore: (() -> Void)?
    var onViewDetails: ((OutPassRequest) -> Void)?
    
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
        seeMoreBtn.isHidden = (outPassData?.count ?? 0) <= 3 ? true : false
        Tv.delegate = self
        Tv.dataSource = self
        Tv.reloadData()
    }
    
    @IBAction func NewOutpassBtnName(_ sender: UIButton) {
        newRequestdelegate?.newOutpassVc()
    }
    
    @IBAction func seeMoreBtnAct(_ sender: Any) {
        onSeeMore?()
    }
    
}
extension OutpassRequestsCell : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (outPassData?.count ?? 0) > 3 {
            return 3
        }else{
            return outPassData?.count ?? 0
        }
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
        
        if data?.status?.lowercased() == "pending"{
            cell.statusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            cell.statusLbl.textColor = .systemOrange
            cell.viewMoreStack.isHidden = true
           
        }else if data?.status?.lowercased() == "approved"{
            cell.statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            cell.statusLbl.textColor = .systemGreen
            cell.viewMoreStack.isHidden = false
        }else{
            cell.statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            cell.statusLbl.textColor = .systemRed
            cell.viewMoreStack.isHidden = true
        }
        
        cell.onViewDetails = { [weak self] in
            guard let self = self,
                  let selectedData = self.outPassData?[indexPath.row] else { return }
            
            self.onViewDetails?(selectedData)
        }
        
        return cell
    }
    
    func formatFromToDate(_ input: String) -> String {
        
        let parts = input.components(separatedBy: " - ")
        guard parts.count == 2 else { return input }
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = LocaleManager.shared.apiLocale
        inputFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = LocaleManager.shared.apiLocale
        outputFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
        
        let fromDate = inputFormatter.date(from: parts[0])
        let toDate = inputFormatter.date(from: parts[1])
        
        let fromString = fromDate != nil ? outputFormatter.string(from: fromDate!) : parts[0]
        let toString = toDate != nil ? outputFormatter.string(from: toDate!) : parts[1]
        
        return "\(fromString) - \(toString)"
    }
    
    
    
}
