import UIKit

protocol Attendence{
    func statusUpdate(status:Bool,index:Int)
}

class AttendenceTVC: UITableViewCell, Attendence {
    
    func statusUpdate(status: Bool, index: Int) {
        delegate?.statusUpdate(status: status, index: index)
        hideLbl(isAbsent: status)
    }
    
    @IBOutlet weak var admissionlbl: UILabel!
    @IBOutlet weak var phnBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var customSwitchContainer: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var rollNo: UIButton!
    @IBOutlet weak var presentLbl: UILabel!
    @IBOutlet weak var absentLbl: UILabel!
    var custSwitch: CustomSwitch1!
    var delegate: Attendence?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize and configure the custom switch
        custSwitch = CustomSwitch1()
        custSwitch.delegate = self
        rollNo.layer.backgroundColor = UIColor(red: 189/255, green: 230/255, blue: 254/255, alpha: 1).cgColor
        rollNo.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 18)
        nameLbl.setFont(style: .body, size: FontSize.BodySize)
        rollNo.translatesAutoresizingMaskIntoConstraints = false
        rollNo.titleLabel?.adjustsFontSizeToFitWidth = true
        rollNo.titleLabel?.minimumScaleFactor = 0.5
        rollNo.titleLabel?.numberOfLines = 1
        rollNo.titleLabel?.lineBreakMode = .byClipping
        rollNo.layer.cornerRadius = 8
        presentLbl.setFont(style: .body, size: FontSize.BodySize)
        absentLbl.setFont(style: .body, size: FontSize.BodySize)
        rollNo.setTitleFont(style: .body, size: FontSize.BodySize)
        phnBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        absentLbl.text = CommonStringFile.Absent.translated()
        presentLbl.text = CommonStringFile.Present.translated()
        presentLbl.textColor = Colornames.AprovedClr
        absentLbl.textColor = .red
        rollNo.titleLabel?.numberOfLines = 0
        rollNo.titleLabel?.textAlignment = .center

        // Add the custom switch to the container view
        customSwitchContainer.addSubview(custSwitch)
        
        
    }
    func hideLbl(isAbsent:Bool){
            absentLbl.isHidden = isAbsent
            presentLbl.isHidden = !isAbsent
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Dynamically set the frame of the custom switch to match the container view
        custSwitch.frame = customSwitchContainer.bounds
    }
    @IBAction func phnBtn(_ sender: UIButton) {
        let phoneNumber = sender.titleLabel?.text ?? "1234567890" // Replace with the phone number you want
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Phone app is not available on this device or invalid phone number.")
        }
    }
}

class CustomSwitch1: UIView {
    
    private let backgroundView = UIView()
    private let thumbView = UIView()
    var delegate: Attendence?
    var index: Int?
    var isOn: Bool = true {
        didSet {
            updateSwitchAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSwitch()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSwitch()
    }
    
    func setupSwitch() {
        // Set up the background view
        backgroundView.layer.cornerRadius = 20
        addSubview(backgroundView)
        
        // Set up the thumb view
        thumbView.backgroundColor = isOn ? UIColor(ciColor: CIColor(red: 73/255, green: 149/255, blue: 76/255,alpha: 1)) : .red
        thumbView.layer.cornerRadius = 15
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOpacity = 0.3
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(thumbView)
        
        // Add gesture recognizer for toggling
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSwitch))
        self.addGestureRecognizer(tapGesture)
        
        // Initial appearance
        updateSwitchAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    func updateLayout() {
        // Layout the background view
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2
        
        // Layout the thumb view
        let thumbSize = bounds.height * 0.7
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.frame = CGRect(
            x: isOn ? bounds.width - thumbSize - 5 : 5,
            y: (bounds.height - thumbSize) / 2,
            width: thumbSize,
            height: thumbSize
        )
        thumbView.backgroundColor = isOn ? UIColor(ciColor: CIColor(red: 73/255, green: 149/255, blue: 76/255,alpha: 1)) : .red
    }
    
    @objc private func toggleSwitch() {
        isOn.toggle()
        delegate?.statusUpdate(status: isOn, index: index ?? 0)
    }
    
    func updateSwitchAppearance() {
        // Update the background color
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = isOn ? UIColor(ciColor: CIColor(red: 73/255, green: 149/255, blue: 76/255,alpha: 1)).cgColor : UIColor.red.cgColor
        
        // Update the thumb position
        UIView.animate(withDuration: 0.25) {
            self.updateLayout()
        }
    }
  
}
