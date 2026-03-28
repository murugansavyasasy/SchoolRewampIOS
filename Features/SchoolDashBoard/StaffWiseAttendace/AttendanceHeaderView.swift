import UIKit

class AttendanceHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateBadgeView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var fullDateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        dateBadgeView.layer.cornerRadius = 8
        
//        containerView.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0)
        dateBadgeView.backgroundColor = UIColor(red: 0.22, green: 0.52, blue: 1.0, alpha: 1.0)
    }

    func configure(dateString: String, stat: DayStat?) {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        
        if let d = df.date(from: dateString) {
            let dayFormat = DateFormatter()
            dayFormat.dateFormat = "dd"
            dayLabel.text = dayFormat.string(from: d)
            
            let wkFormat = DateFormatter()
            wkFormat.dateFormat = "E"
            dayOfWeekLabel.text = wkFormat.string(from: d)
            
            let fullFormat = DateFormatter()
            fullFormat.dateFormat = "dd MMMM yyyy"
            fullDateLabel.text = fullFormat.string(from: d)
        } else {
            dayLabel.text = "--"
            dayOfWeekLabel.text = "-"
            fullDateLabel.text = dateString
        }
        
        let present = stat?.present ?? 0
        let absent = stat?.absent ?? 0
        let notMarked = stat?.not_marked ?? 0
        summaryLabel.text = "Present: \(present) • Absent: \(absent) • Not Marked: \(notMarked)"
    }
}
