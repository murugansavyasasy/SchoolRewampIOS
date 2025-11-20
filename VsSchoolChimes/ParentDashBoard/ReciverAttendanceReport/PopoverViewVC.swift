//
// PopoverViewVC.swift
// School Chimes
//
// Created by Chandhru on 30/10/25.
//

import UIKit

class PopoverViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var listTable: UITableView!
    
    enum PopoverType { case badge, symbol }
    
    private var configData: [(symbol: String, title: String, color: UIColor)]?
    private var configType: PopoverType?
    
    var itemCount: Int { configData?.count ?? 0 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 17.4, *) {
               view.backgroundColor = .clear
               self.popoverPresentationController?.backgroundColor = .white
           }
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        listTable.showsHorizontalScrollIndicator = false
        listTable.showsVerticalScrollIndicator = false
        listTable.register(UINib(nibName: "PopoverTVC", bundle: nil), forCellReuseIdentifier: "PopoverTVC")
        listTable.delegate = self
        listTable.dataSource = self
    }
    
    // MARK: - Configure From Parent VC
    func configureButtons(
        with data: [(symbol: String, title: String, color: UIColor)],
        type: PopoverType
    ) {
        self.configData = data
        self.configType = type
        
        if isViewLoaded {
            listTable.reloadData()
        }
    }
    
    // MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PopoverTVC",
            for: indexPath
        ) as! PopoverTVC
        
        guard let item = configData?[indexPath.row],
              let type = configType else { return cell }
        
        cell.tittleLbl.text = item.title
        
        switch type {
        case .badge:
            cell.iconImg.isHidden = true
            cell.iconBtn.isHidden = item.symbol.isEmpty
            cell.iconBtn.setTitle(item.symbol, for: .normal)
            cell.iconBtn.titleLabel?.font = .boldSystemFont(ofSize: 13)
            cell.iconBtn.backgroundColor = item.color
            cell.iconBtn.layer.cornerRadius = 8
            cell.iconBtn.clipsToBounds = true
            
        case .symbol:
            cell.iconBtn.isHidden = true
            cell.iconImg.isHidden = false
            
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            
            if let sysImg = UIImage(systemName: item.symbol, withConfiguration: config) {
                cell.iconImg.image = sysImg
                cell.iconImg.tintColor = item.color
            } else if let assetImg = UIImage(named: item.symbol) {
                cell.iconImg.image = assetImg
                cell.iconImg.tintColor = nil
            }
        }
        
        return cell
    }
    
    // MARK: - Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
    }
}
