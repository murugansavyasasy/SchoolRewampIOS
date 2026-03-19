import UIKit

protocol Attendence{
    func statusUpdate(status:Bool,index:Int)
}

protocol studentAttenance: AnyObject{
    
    func didTapPresentAbsent(for id: String)
    func didTapLate(for id: String)
    func didToggleOD(for id: String, isOn: Bool)
}

protocol viewLeaveApplied: AnyObject{
    func didTapViewAppliedLeave(index: Index)
}
class AttendenceTVC: UITableViewCell, Attendence {
    func statusUpdate(status: Bool, index: Int) {
        ""
    } 
    @IBOutlet weak var LeaveAppliedFullView: UIView!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var ToDateLbl: UILabel!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var todateView: UIView!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var fromdateAndTodateStack: UIStackView!
    @IBOutlet weak var admissionlbl: UILabel!
    @IBOutlet weak var phnBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var customSwitchContainer: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var presentLbl: UILabel!
    @IBOutlet weak var absentLbl: UILabel!
    @IBOutlet weak var ODSwitch: UISwitch!
    @IBOutlet weak var AttendanceBtn: UIButton!
    @IBOutlet weak var OnLateBtn: UIButton!
    @IBOutlet weak var attendanceStack: UIStackView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var onDutyDefLbl: UILabel!
    @IBOutlet weak var leaveAppliedHeightConst: NSLayoutConstraint!
    @IBAction func LeaveApliedBtnAct(_ sender: UIButton) {
        leaveApplied?.didTapViewAppliedLeave(index: sender.tag)
    }
    
    @IBOutlet weak var LeaveAppliedBtnName: UIButton!
    var custSwitch: CustomSwitch1!
    var studentId: String?
    weak var delegate: studentAttenance?
    weak var leaveApplied : viewLeaveApplied?
    override func awakeFromNib() {
        super.awakeFromNib()
        fromDateView.layer.cornerRadius = 10
        reasonView.layer.cornerRadius = 10
        todateView.layer.cornerRadius = 10
        AttendanceBtn.layer.cornerRadius = AttendanceBtn.frame.width / 2
        ODSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        custSwitch = CustomSwitch1()
        custSwitch.delegate = self
        outerView.layer.cornerRadius = 10
        nameLbl.setFont(style: .body, size: FontSize.BodySize)
        admissionlbl.setFont(style: .body, size: FontSize.BodySize)
        rollNoLbl.setFont(style: .body, size: FontSize.BodySize)
        onDutyDefLbl.setFont(style: .body, size: 10)
        presentLbl.setFont(style: .body, size: FontSize.BodySize)
        absentLbl.setFont(style: .body, size: FontSize.BodySize)
        phnBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        absentLbl.text = CommonStringFile.Absent.translated()
        presentLbl.text = CommonStringFile.Present.translated()
        presentLbl.textColor = Colornames.AprovedClr
        absentLbl.textColor = .red
        customSwitchContainer.addSubview(custSwitch)
    }
    
    func hideLbl(isAbsent:Bool){
        absentLbl.isHidden = isAbsent
        presentLbl.isHidden = !isAbsent
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        custSwitch.frame = customSwitchContainer.bounds
    }
    
    @IBAction func presentButtonTapped(_ sender: UIButton) {
        if let id = studentId {
            delegate?.didTapPresentAbsent(for: id)
        }
    }
    
    @IBAction func lateButtonTapped(_ sender: UIButton) {
        if let id = studentId {
            delegate?.didTapLate(for: id)
        }
    }
    
    @IBAction func OdSwitchAct(_ sender: UISwitch) {
        if let id = studentId {
            delegate?.didToggleOD(for: id, isOn: sender.isOn)
        }
    }
    
    @IBAction func phnBtn(_ sender: UIButton) {
        let phoneNumber = sender.titleLabel?.text ?? "1234567890" // Replace with
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
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
        backgroundView.layer.cornerRadius = 20
        addSubview(backgroundView)
        thumbView.backgroundColor = isOn ? UIColor(ciColor: CIColor(red: 73/255, green: 149/255, blue: 76/255,alpha: 1)) : .red
        thumbView.layer.cornerRadius = 15
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOpacity = 0.3
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(thumbView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSwitch))
        self.addGestureRecognizer(tapGesture)
        updateSwitchAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    func updateLayout() {
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2
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
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = isOn ? UIColor(ciColor: CIColor(red: 73/255, green: 149/255, blue: 76/255,alpha: 1)).cgColor : UIColor.red.cgColor
        UIView.animate(withDuration: 0.25) {
            self.updateLayout()
        }
    }
    
}
