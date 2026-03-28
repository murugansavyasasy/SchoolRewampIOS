//
//  studentPendingFeeTv.swift
//  School Chimes
//
//  Created by apple on 25/03/26.
//

import UIKit

class studentPendingFeeTv: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var tabelview: SelfSizingTableView!
    var pendingFeesList: [HostelFeeDetails] = []
    var onPaybuttonTapped : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tabelview.register(PendingFeeCell.self)
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.backgroundColor = .white
    }

    
    func config(data : [HostelFeeDetails]){
        pendingFeesList = data
        tabelview.delegate = self
        tabelview.dataSource = self
        tabelview.reloadData()
    }
}
extension studentPendingFeeTv : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingFeesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFeeCell", for: indexPath) as! PendingFeeCell
        let feeData = pendingFeesList[indexPath.row]
        cell.configure(with: feeData)
        cell.onPayButtonTapped = { [weak self] in
            self?.onPaybuttonTapped?()
        }
        return cell
    }
    
}
