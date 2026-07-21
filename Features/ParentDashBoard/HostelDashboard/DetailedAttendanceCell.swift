import UIKit

class DetailedAttendanceCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate, DetailedDayRowCellDelegate {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var innerTableView: UITableView!
    
    private var model: AttendanceDetails?
    private var syncedOffset: CGPoint = .zero
    private var headerRowCell: DetailedDayRowCell?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
        
        // Setup Header Row Container
        if let header = Bundle.main.loadNibNamed("DetailedDayRowCell", owner: self, options: nil)?.first as? DetailedDayRowCell {
            headerRowCell = header
            header.translatesAutoresizingMaskIntoConstraints = false
            headerContainerView.addSubview(header)
            
            NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
                header.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
                header.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
                header.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor)
            ])
            
            header.delegate = self
            
            // Adjust header styling
            headerContainerView.layer.cornerRadius = 8
            headerContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            headerContainerView.clipsToBounds = true
            headerContainerView.layer.borderWidth = 1
            headerContainerView.layer.borderColor = UIColor.systemGray5.cgColor
        }
        
        innerTableView.register(UINib(nibName: "DetailedDayRowCell", bundle: nil), forCellReuseIdentifier: "DetailedDayRowCell")
        innerTableView.delegate = self
        innerTableView.dataSource = self
        innerTableView.separatorStyle = .none
        innerTableView.bounces = false
        innerTableView.layer.cornerRadius = 8
        innerTableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        innerTableView.layer.borderWidth = 1
        innerTableView.layer.borderColor = UIColor.systemGray5.cgColor
        innerTableView.clipsToBounds = true
        
        // Remove duplicate bottom border for inner headers
        innerTableView.layer.borderWidth = 1
    }

    func configure(with model: AttendanceDetails?) {
        self.model = model
        
        // Configure sticky static header
        headerRowCell?.configure(dayLabel: "Date", statuses: model?.sessions ?? [], isHeader: true)
        
        self.innerTableView.reloadData()
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.days?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedDayRowCell", for: indexPath) as! DetailedDayRowCell
        cell.delegate = self
        
        if let dayData = model?.days?[indexPath.row] {
            cell.configure(dayLabel: dayData.date_label ?? "", statuses: dayData.status ?? [], isHeader: false)
        }
        
        // Restore synced offset for horizontal collection view
        cell.syncScroll(to: syncedOffset)
        
        return cell
    }
    
    // MARK: - Delegate (Sync collection views)
    func detailedDayRow(_ cell: DetailedDayRowCell, didScrollTo offset: CGPoint) {
        syncedOffset = offset
        
        // Sync the static header if it wasn't the sender
        if cell !== headerRowCell {
            headerRowCell?.syncScroll(to: offset)
        }
        
        // Sync visible table rows
        for visibleCell in innerTableView.visibleCells {
            if let rowCell = visibleCell as? DetailedDayRowCell, rowCell !== cell {
                rowCell.syncScroll(to: offset)
            }
        }
    }
}
