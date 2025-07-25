//
//  ReciverEventTVC.swift
//  School Chimes
//
//  Created by Chandhru on 22/07/25.
//

import UIKit
import EventKit

class ReciverEventTVC: UITableViewCell {
    @IBOutlet weak var attacmentView: UIView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var reminderBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgCount: UIButton!
    @IBOutlet weak var selectBtn: UIButton!

    var date: String?
    var time: String?

    let alert = CustomAlert()
    let eventStore = EKEventStore()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Hide all initially
        img1.isHidden = true
        img2.isHidden = true
        img3.isHidden = true
        imgCount.isHidden = true
        [img1, img2, img3].forEach {
            setBorderAndCornerRadius(for: $0!, cornerRadius:($0?.frame.width ?? 0)/2)
        }
        attacmentView.setShadow(cornerRadius: 20)
        setBorderAndCornerRadius(for: imgCount, cornerRadius: imgCount.frame.width/2)
        setBorderAndCornerRadius(for: selectBtn)
        setBorderAndCornerRadius(for: outerView)
    }

    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }


    @IBAction func reminder(_ sender: UIButton) {
        eventStore.requestAccess(to: .reminder) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.addReminderToReminderApp()
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

    func addReminderToReminderApp() {
        guard let dateString = date, let timeString = time else {
            print("Date or time is nil")
            return
        }

        let fullString = "\(dateString) \(timeString)"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy hh:mm a" // adjust if needed

        guard let reminderDate = formatter.date(from: fullString) else {
            print("Invalid date/time format")
            return
        }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = titleLbl.text ?? "Event Reminder"
        reminder.notes = "Location: \(placeLbl.text ?? "Unknown Location")"
        reminder.calendar = eventStore.defaultCalendarForNewReminders()

        let alarm = EKAlarm(absoluteDate: reminderDate)
        reminder.addAlarm(alarm)

        do {
            try eventStore.save(reminder, commit: true)
            if let topVC = getCurrentViewController() {
                alert.showAlert(title: "Reminder Saved", message: "Saved to Reminder app for \(formatter.string(from: reminderDate))", on: topVC)
            }
            print("Reminder saved at \(reminderDate)")
        } catch {
            print("Error saving reminder: \(error.localizedDescription)")
            if let topVC = getCurrentViewController() {
                alert.showAlert(title: "Error", message: "Failed to save reminder.", on: topVC)
            }
        }
    }

    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
}
