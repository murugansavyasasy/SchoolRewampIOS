//
//  QuizSubmissionVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 10/09/25.
//

import UIKit

class QuizSubmissionVc: UIViewController {
    
    
    @IBOutlet weak var QuizDetailsView: UIView!
    @IBOutlet weak var DescriptionBaseview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var tvHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QuizDetailsView.layer.cornerRadius = 10
        DescriptionBaseview.layer.cornerRadius = 10
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        tv.isScrollEnabled = false
        tv.register(UINib(nibName: "QuizSubmisionTvCell", bundle: nil), forCellReuseIdentifier: "QuizSubmisionTvCell")
        tv.delegate = self
        tv.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    func updateTableHeight() {
        tv.layoutIfNeeded()
        tvHeight.constant = tv.contentSize.height
    }
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}


extension QuizSubmissionVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "QuizSubmisionTvCell", for: indexPath) as! QuizSubmisionTvCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // ✅ Update height when a cell finishes laying out
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateTableHeight()
        }
    }
}
