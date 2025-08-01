//
//  ReciverEventTVC.swift
//  School Chimes
//
//  Created by Chandhru on 23/07/25.
//
import UIKit
import EventKit

class NoticeCVC: UICollectionViewCell, UIPopoverPresentationControllerDelegate, TimePicker, SelectedId {
    func selectId(id: String?,edit:Bool?) {
        delegate?.selectId(id: id, edit: edit)
    }
    
    func timepicker(dateTime: String?) {
        let formatter = DateFormatter()
           formatter.dateFormat = "dd-MM-yyyy hh:mm a"
           formatter.locale = Locale(identifier: "en_US_POSIX")
           
           if let reminderDate = formatter.date(from: dateTime ?? "") {
               saveReminder(date: reminderDate)
           } else {
               print("Invalid date format")
           }
    }
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var readStatusView: UIButton!
    @IBOutlet weak var reminderBtn: UIButton!
    @IBOutlet weak var timeBtn: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgCount: UIButton!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UITextView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    // MARK: - Properties
    let eventStore = EKEventStore()
    let alert = CustomAlert()
    var date:String?
    var edit:Bool?
    var delete:Bool?
    var delegate:SelectedId?
    var selectedId:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [img1, img2, img3, imgCount].forEach { $0?.isHidden = true }
        [img1, img2, img3, imgCount].forEach {
            if let view = $0 {
                setBorderAndCornerRadius(for: view, cornerRadius: view.frame.width / 2)
            }
        }
        iconBtn.layer.cornerRadius = iconBtn.frame.width / 2
        readStatusView.layer.cornerRadius = readStatusView.frame.width / 2
    }
    @IBAction func edit(_ sender: UIButton) {
        
        let popoverContentVC = PopupVC(nibName: nil, bundle: nil)
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.delegate = self
        popoverContentVC.edit = edit
        popoverContentVC.delete = delete
        popoverContentVC.selectedId = selectedId
        
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: 90)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .right
            popoverController.delegate = self
        }
        
        // For iPhones: Present as a pop-up instead of full-screen
        if UIDevice.current.userInterfaceIdiom == .phone {
            popoverContentVC.modalPresentationStyle = .overFullScreen
            popoverContentVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3) // Optional dim effect
        }
        if let topVC = getCurrentViewController() {
            topVC.present(popoverContentVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Reminder Button Action
    @IBAction func reminder(_ sender: UIButton) {
        eventStore.requestAccess(to: .reminder) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    if let topVC = self.getCurrentViewController() {
                        self.showTimePickerAndCreateReminder(from: topVC.view)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if let topVC = self.getCurrentViewController() {
                        self.alert.showAlert(title: "Permission Denied", message: "Please allow access to Reminders in Settings.", on: topVC)
                    }
                }
            }
        }
    }
    func showTimePickerAndCreateReminder(from sourceView: UIView) {
        let popoverContentVC = RiminderTimePicker(nibName: nil, bundle: nil)
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.modalPresentationStyle = .popover
        popoverContentVC.preferredContentSize = CGSize(width: 300, height: 300)
        popoverContentVC.maximumDate = "31-07-2025"
        popoverContentVC.delegate = self
        if let popoverPresentationController = popoverContentVC.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = []
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView.bounds
            popoverPresentationController.delegate = self
            popoverPresentationController.backgroundColor = .white
        }

        if UIDevice.current.userInterfaceIdiom == .phone {
            // On iPhone, present modally with dimmed background
            popoverContentVC.modalPresentationStyle = .overFullScreen
            popoverContentVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        }

        if let topVC = getCurrentViewController() {
            topVC.present(popoverContentVC, animated: true, completion: nil)
        }
    }


    func saveReminder(date: Date) {
        eventStore.requestAccess(to: .reminder) { [weak self] granted, error in
            guard let self = self else { return }

            if granted {
                let reminder = EKReminder(eventStore: self.eventStore)
                reminder.title = self.titleLbl.text ?? "Reminder"
                reminder.notes = ""
                reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                reminder.addAlarm(EKAlarm(absoluteDate: date))
                
                do {
                    try self.eventStore.save(reminder, commit: true)
                    
                    // Only dispatch to main if UI alert needs to be shown
                    if let topVC = self.getCurrentViewController() {
                        if #available(iOS 15.0, *) {
                            DispatchQueue.main.async {
                                self.alert.showAlert(
                                    title: "Reminder Saved",
                                    message: "Reminder set for \(date.formatted(date: .abbreviated, time: .shortened))",
                                    on: topVC
                                )
                            }
                        }
                    }
                } catch {
                    print("Failed to save reminder: \(error.localizedDescription)")
                }
            } else {
                if let topVC = self.getCurrentViewController() {
                    DispatchQueue.main.async {
                        self.alert.showAlert(
                            title: "Permission Denied",
                            message: "Please enable Reminder access in Settings",
                            on: topVC
                        )
                    }
                }
            }
        }
    }

//    private func addReminderToReminderApp() {
//        guard let dateString = date else {
//            print("Date or time is nil")
//            return
//        }
//
//        let fullString = "\(dateString)"
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM dd h:mm a" // Match formatted label format
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//
//        guard let reminderDate = formatter.date(from: fullString) else {
//            print("Invalid date/time format")
//            return
//        }
//
//        let reminder = EKReminder(eventStore: eventStore)
//        reminder.title = titleLbl.text ?? "Event Reminder"
//        reminder.notes = ""
//        reminder.calendar = eventStore.defaultCalendarForNewReminders()
//        reminder.addAlarm(EKAlarm(absoluteDate: reminderDate))
//
//        do {
//            try eventStore.save(reminder, commit: true)
//            if let topVC = getCurrentViewController() {
//                alert.showAlert(title: "Reminder Saved", message: "Saved to Reminder app for \(formatter.string(from: reminderDate))", on: topVC)
//            }
//        } catch {
//            print("Error saving reminder: \(error.localizedDescription)")
//            if let topVC = getCurrentViewController() {
//                alert.showAlert(title: "Error", message: "Failed to save reminder.", on: topVC)
//            }
//        }
//    }

    private func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }

    // MARK: - Setup
    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }

    // MARK: - Configure Cell
    func configure(with notice: Notice) {
        titleLbl.text = notice.title
        descriptionLbl.text = notice.description
        dateLbl.text = formattedDate(from: notice.created_on)
        timeBtn.text = formattedTime(from: notice.created_on)
        date = notice.visible_from
        // Show/hide reminder button based on future date
        if isFutureDateTime(notice.visible_to) {
//            reminderBtn.isHidden = false
            reminderBtn.isEnabled = true
            reminderBtn.alpha = 1.0
        } else {
//            reminderBtn.isHidden = true // Or disable instead of hiding
             reminderBtn.isEnabled = false
             reminderBtn.alpha = 0.5
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Date Formatting
    private func formattedDate(from raw: String?) -> String {
        guard let raw = raw else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: raw) else {
            return raw
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM dd" // e.g., Jul 13
            return displayFormatter.string(from: date)
        }
    }

    private func formattedTime(from raw: String?) -> String {
        guard let raw = raw else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: raw) else {
            return ""
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        return timeFormatter.string(from: date)
    }

    private func isFutureDateTime(_ raw: String?) -> Bool {
        guard let raw = raw else { return false }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: raw) else {
            return false
        }

        return date > Date()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        [img1, img2, img3].forEach { $0?.isHidden = true }
        imgCount.isHidden = true
        titleLbl.text = nil
        descriptionLbl.text = nil
        dateLbl.text = nil
        timeBtn.text = nil
        reminderBtn.isHidden = true
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
}
