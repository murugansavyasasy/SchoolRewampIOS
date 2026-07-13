import UIKit
protocol refrech : AnyObject{
    func refreshClick(index:Int)
}
class PaymentHistoryCell: UITableViewCell {

    @IBOutlet weak var refreshDefaultLbl: UILabel!
    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIconImageView: UIImageView!
    @IBOutlet weak var statusContainerView: UIView!
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var studentIdLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    
    @IBOutlet weak var paymentCompletedContainer: UIView!
  
    @IBOutlet weak var refreshBtnName: UIButton!
    
    weak var refreshbtn : refrech?
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.backgroundColor = .clear
        
        shadowContainerView.backgroundColor = .clear
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.08
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowContainerView.layer.shadowRadius = 8
        
        mainContainerView.layer.cornerRadius = 16
        mainContainerView.clipsToBounds = true
        mainContainerView.backgroundColor = .white
        
        refreshDefaultLbl.text = "Refresh".translated()
        
//        topBackgroundView.backgroundColor = UIColor(red: 45/255, green: 120/255, blue: 255/255, alpha: 1.0)
        
        statusContainerView.layer.cornerRadius = 14
        
        refreshBtnName.layer.cornerRadius = 18
        refreshBtnName.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
    }

    @IBAction func refreshBtnAct(_ sender: UIButton) {
        refreshbtn?.refreshClick(index: sender.tag)
        
    }
    func configure(with record: transactionData) {
        amountLabel.text = record.total_amount
        orderIdLabel.text = record.order_id
        studentIdLabel.text = record.order_status_update_on
        createdOnLabel.text = record.created_on
        
        statusLabel.text = record.order_status
        if record.order_status == "PAID" {

            // SUCCESS - GREEN
            statusContainerView.backgroundColor = UIColor(
                red: 220/255,
                green: 255/255,
                blue: 230/255,
                alpha: 1.0
            )

            statusLabel.textColor = UIColor(
                red: 0/255,
                green: 140/255,
                blue: 70/255,
                alpha: 1.0
            )

            statusIconImageView.image = UIImage(systemName: "checkmark.circle.fill")

            statusIconImageView.tintColor = UIColor(
                red: 0/255,
                green: 140/255,
                blue: 70/255,
                alpha: 1.0
            )

            paymentCompletedContainer.isHidden = false
            refreshBtnName.isHidden = true
            refreshDefaultLbl.isHidden = true

        } else {

            // FAILED / PENDING - RED
            
            statusContainerView.backgroundColor = UIColor(
                red: 255/255,
                green: 230/255,
                blue: 230/255,
                alpha: 1.0
            )

            statusLabel.textColor = UIColor(
                red: 220/255,
                green: 40/255,
                blue: 40/255,
                alpha: 1.0
            )

            statusIconImageView.image = UIImage(systemName: "xmark.circle.fill")

            statusIconImageView.tintColor = UIColor(
                red: 220/255,
                green: 40/255,
                blue: 40/255,
                alpha: 1.0
            )

            paymentCompletedContainer.isHidden = true
            refreshBtnName.isHidden = false
            refreshDefaultLbl.isHidden = false
        }
    }
}
