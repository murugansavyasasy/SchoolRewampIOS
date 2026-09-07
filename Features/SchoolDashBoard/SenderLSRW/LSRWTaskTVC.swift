//
//  LSRWTaskTVC.swift
//  School Chimes
//
//  Created by Chandhru on 13/08/25.
//

import UIKit

class LSRWTaskTVC: UITableViewCell, SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id: id, edit: edit)
    }
    
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var submitedCountLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    var selectedId:String?
    var expiryDate: String?
    var delete: Bool?
    var delegate: SelectedId?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        
        outerView.layer.cornerRadius = 12
        outerView.layer.masksToBounds = true
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.05
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 4
        outerView.layer.masksToBounds = false
        setupButtons()
        setupLabels()
    }
    
    private func setupButtons() {
        iconBtn.layer.cornerRadius = 8
        iconBtn.isUserInteractionEnabled = false
    }
    
    private func setupLabels() {
        
        typeLbl.font = .systemFont(ofSize: 13, weight: .medium)
        typeLbl.textColor = .systemBlue
        dateLbl.font = .systemFont(ofSize: 12, weight: .medium)
        dateLbl.textColor = .systemGray
        submitedCountLbl.font = .systemFont(ofSize: 12, weight: .medium)
    }

    @IBAction func editBtn(_ sender: UIButton) {
            let popoverVC = PopoverViewVC(nibName: nil, bundle: nil)
        if delete ?? false{
            popoverVC.configureButtons(with: [
                ("trash.fill", "Delete", .systemRed),
                ("arrowshape.turn.up.right.fill", "Forward", .systemBlue)
            ], type: .symbol)
        }else{
            popoverVC.configureButtons(with: [
                ("arrowshape.turn.up.right.fill", "Forward", .systemBlue)
            ], type: .symbol)
        }
            
        popoverVC.delegate = self
        popoverVC.selectedId = selectedId
        popoverVC.preferredContentSize = CGSize(width: 120, height: !(delete ?? false) ? 90 : 50)
            popoverVC.modalPresentationStyle = .popover
            
            if let popoverController = popoverVC.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
                popoverController.permittedArrowDirections = .any
                popoverController.delegate = self
                popoverController.backgroundColor = .white
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                popoverVC.modalPresentationStyle = .overFullScreen
                popoverVC.view.backgroundColor = .white
            }
            
            getCurrentViewController()?.present(popoverVC, animated: true)

    }
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    func isDateExpired(_ dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"       // your format
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let givenDate = formatter.date(from: dateString) else {
            return false
        }

        let today = Date()
        return givenDate < today
    }

    func configure(with task: LSRWTask) {
        titleLbl.text = task.title
        typeLbl.text = task.activity_type?.displayName
        subjectLbl.text = task.subject
        selectedId = task.id
        expiryDate = task.submitted_date
        delete = task.can_delete
        editBtn.isHidden = !(task.can_delete ?? false)
        let dateText: String
        if let date = task.created_on {
            dateText = formattedDateStatus(from: date)
        } else {
            dateText = "--/--/----"
        }
        
        let calendarAttachment = NSTextAttachment()
        calendarAttachment.image = UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate)
        calendarAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
        
        let dateAttrString = NSMutableAttributedString(attachment: calendarAttachment)
        dateAttrString.append(NSAttributedString(string: " \(dateText)"))
        dateLbl.attributedText = dateAttrString
        dateLbl.textColor = .secondaryLabel
        
        let personAttachment = NSTextAttachment()
        personAttachment.image = UIImage(systemName: "person.2")?.withRenderingMode(.alwaysTemplate)
        personAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
        
        let submittedAttrString = NSMutableAttributedString(attachment: personAttachment)
        let submittedAverage = task.submitted_average ?? ""
        let text = "\(submittedAverage) \("Submitted".translated())"
        submittedAttrString.append(NSAttributedString(string: text))
        submitedCountLbl.attributedText = submittedAttrString
        submitedCountLbl.textColor = .secondaryLabel
        if let type = task.activity_type{
            let iconConfig = getIconConfiguration(for: type)
            iconBtn.setTitle(type.icon, for: .normal)
            iconBtn.backgroundColor = iconConfig.backgroundColor
            iconBtn.setTitleColor(iconConfig.textColor, for: .normal)
        }
        descriptionLbl.text = task.description
        animateConfiguration()
    }


    
    private func getIconConfiguration(for type: LSRWType) -> (backgroundColor: UIColor, textColor: UIColor) {
        switch type {
        case .listening:
            return (.systemBlue.withAlphaComponent(0.2), .systemBlue)
        case .speaking:
            return (.systemGreen.withAlphaComponent(0.2), .systemGreen)
        case .reading:
            return (.systemOrange.withAlphaComponent(0.2), .systemOrange)
        case .writing:
            return (.systemPurple.withAlphaComponent(0.2), .systemPurple)
        case .unknown(_):
            return (.systemPurple.withAlphaComponent(0.2), .systemPurple)
        }
    }
    
    private func getProgressConfiguration(for percentage: Float) -> (backgroundColor: UIColor, textColor: UIColor) {
        switch percentage {
        case 0.0..<0.5:
            return (.systemRed.withAlphaComponent(0.2), .systemRed)
        case 0.5..<0.8:
            return (.systemYellow.withAlphaComponent(0.2), .systemYellow)
        case 0.8...1.0:
            return (.systemGreen.withAlphaComponent(0.2), .systemGreen)
        default:
            return (.systemGray.withAlphaComponent(0.2), .systemGray)
        }
    }
    
    private func animateConfiguration() {
        transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            self.transform = .identity
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLbl.text = nil
        typeLbl.text = nil
        descriptionLbl.text = nil
        dateLbl.text = nil
        submitedCountLbl.text = nil
        iconBtn.setTitle(nil, for: .normal)
        iconBtn.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.transform = selected ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.alpha = highlighted ? 0.8 : 1.0
            }
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }
}
