//
//  ViewDetailsVc.swift
//  School Chimes
//
//  Created by apple on 21/07/26.
//

import UIKit

class ViewDetailsVc: UIViewController {



    @IBOutlet public weak var btnBack: UIButton!
   
    @IBOutlet public weak var tableView: UITableView!
    
    public var examResponse: NewExamResponseSuc?
    public var currentSubject: NewSubject?
    public var activities: [NewActivity] = []
    var subjects: [NewSubject]?
    override public func viewDidLoad() {
        super.viewDidLoad()
       
        setupTableView()
        loadData()
    }
    
  
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
//        let nib = UINib(nibName: "ActivityTableViewCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: "ActivityTableViewCell")
//        
        let nib = UINib(nibName: "SubjectCardTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SubjectCardTableViewCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 350
    }
    
    private func loadData() {

        self.tableView.reloadData()
    }
    
    @IBAction public func didTapBack(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

//extension ViewDetailsVc: UITableViewDelegate, UITableViewDataSource {
//
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        return subjects?.count ?? 0
//    }
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return subjects?[section].activities?.count ?? 0
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as? ActivityTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        guard let activity = subjects?[indexPath.section].activities?[indexPath.row] else {
//            return cell
//        }
//        cell.configure(with: activity, delegate: self)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let containerView = UIView()
//        containerView.backgroundColor = .clear
//
//        let bgView = UIView()
//
//        bgView.backgroundColor = UIColor(red: 227/255, green: 239/255, blue: 252/255, alpha: 1)
//        bgView.layer.shadowColor = UIColor.black.cgColor
//        bgView.layer.shadowOpacity = 0.08
//        bgView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        bgView.layer.shadowRadius = 8
//        bgView.layer.masksToBounds = false
//        bgView.layer.cornerRadius = 5
//        bgView.translatesAutoresizingMaskIntoConstraints = false
//
//        containerView.addSubview(bgView)
//
//      
//
//        // Subject Name
//        let titleLabel = UILabel()
//        titleLabel.text = subjects?[section].subjectName ?? "ENGLISH"
//        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
//        titleLabel.textColor = .primery
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        // Total Marks
//        let markLabel = UILabel()
//        markLabel.text = "TotalMarks : \(subjects?[section].total_mark ?? "100")"
//        markLabel.font = .systemFont(ofSize: 11, weight: .medium)
//        markLabel.textColor = .darkGray
//        markLabel.translatesAutoresizingMaskIntoConstraints = false
//
//
//        bgView.addSubview(titleLabel)
//        bgView.addSubview(markLabel)
//
//
//        NSLayoutConstraint.activate([
//            bgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            bgView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            bgView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
//            bgView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
//
//            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 20),
//            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
//
//            markLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            markLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
//            markLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12)
//        ])
//
//        return containerView
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//           return UITableView.automaticDimension
//       }
//       
//}


extension ViewDetailsVc: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCardTableViewCell", for: indexPath) as? SubjectCardTableViewCell else {
            return UITableViewCell()
        }
        
       guard let subject = subjects?[indexPath.row] else { return cell }
        cell.configure(with: subject, delegate: self)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

// MARK: - ActivityCellDelegate

extension ViewDetailsVc: NewActivityCellDelegate {
    public func didSelectRubric(_ rubric: Rubric) {
        let detailVC = RubricDetailViewController(nibName: "RubricDetailViewController", bundle: nil)
        detailVC.rubric = rubric
        present(detailVC, animated: true)
    }
    
    public func didSelectActivity(_ activity: NewActivity) {
        let detailVC = RubricDetailViewController(nibName: "RubricDetailViewController", bundle: nil)
        detailVC.activity = activity
        present(detailVC, animated: true)
    }
}
