//
//  ExameMarVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit

class ExameMarVC: UIViewController {
    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var tv: UITableView!
    let marks = ["85 / 100","70 / 100","75 / 100","49 / 100","93 / 100"]
    let status = [0.85,0.70,0.75,0.49,0.93]
    let subject = ["Tamil","English","Maths","Science","Social Science"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslate()
        SearchBar.addDoneButton()
        CellRegister()
        SearchBar.applyRightTxt()
        
        tv.isHidden = true
        cv.dataSource = self
        cv.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    //MARK: UI Changes
    func StyleAndTranslate(){
        
        SearchBar.placeholder = CommonStringFile.Search.translated()
    }
    
    //MARK: Cell Registration
    func CellRegister(){
        
        tv.register(UINib(nibName: CellConfingName.SettingHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)
        
        tv.register(UINib(nibName: CellConfingName.ExammarkFooterView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.ExammarkFooterView)
        
        let cvnib = UINib(nibName: CellConfingName.ExamMarkCV, bundle: nil)
        cv.register(cvnib, forCellWithReuseIdentifier: CellConfingName.ExamMarkCV)
        
        let nib1 = UINib(nibName:CellConfingName.ExamMarkTV, bundle: nil)
        tv.register(nib1, forCellReuseIdentifier: CellConfingName.ExamMarkTV)
    }
    
    @IBAction func ViewMarks(_ sender: Any) {
        
        cv.isHidden = true
        tv.isHidden = false
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
}

//MARK: Tableview Functions
extension ExameMarVC : UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier:CellConfingName.SettingHeaderView) as! SettingHeaderView
        cell.headerLabel.text = "Exam Marks"
        //        cell.headerLabel.text = sections[section].title.translated()
        cell.headerLabel.setFont(style: .title, size: FontSize.TitleSize)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //        let  cell  = tableView.dequeueReusableCell(withIdentifier: "MarkTvCell" , for: indexPath) as! MarkTvCell
        let  cell  = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ExamMarkTV , for: indexPath) as! ExamMarkTV
        cell.SubjectLbl.text = subject[indexPath.row]
        cell.MarkLbl.text = marks[indexPath.row]
        cell.progessBar.progress = Float(status[indexPath.row])
        if #available(iOS 15.0, *) {
            cell.progessBar.progressTintColor = .systemMint
        } else {
            // Fallback on earlier versions
        }
        //        cell.TheoryLbl.isHidden = true
        //        cell.PracticalLbl.isHidden = true
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tv.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.ExammarkFooterView) as! ExammarkFooterView
        cell.footerview.layer.cornerRadius = 10
        cell.TotalLbl.setFont(style: .title, size: FontSize.TitleSize)
        cell.TotalMarkLbl.setFont(style: .title, size: FontSize.TitleSize)
        cell.RankLbl.setFont(style: .title, size: FontSize.TitleSize)
        cell.RankNumLbl.setFont(style: .title, size: FontSize.TitleSize)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 150
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let cell = tv.cellForRow(at: indexPath) as! ExamMarkTV
    //        cell.TheoryLbl.isHidden = false
    //        cell.PracticalLbl.isHidden = false
    //        tv.reloadRows(at: [indexPath], with: .automatic)
    //    }
    //    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    //        let cell = tv.cellForRow(at: indexPath) as! ExamMarkTV
    //        cell.TheoryLbl.isHidden = true
    //        cell.PracticalLbl.isHidden = true
    //        tv.reloadRows(at: [indexPath], with: .automatic)
    //    }
    
    // MARK: Updated didSelectRowAt Implementation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExamMarkTV {
            // Toggle the visibility of TheoryLbl and PracticalLbl
            let shouldExpand = cell.TheoryLbl.isHidden
            cell.TheoryLbl.isHidden = !shouldExpand
            cell.PracticalLbl.isHidden = !shouldExpand
            
            if cell.TheoryLbl.isHidden == false {
                cell.ArrowImageview.image = UIImage(named: "arrow_up")
            }else{
                cell.ArrowImageview.image = UIImage(named: "arrow_down")
            }
            
            // Use beginUpdates and endUpdates to refresh the row height without reloading the cell
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    
}

//MARK: Collectionview Delegate

extension ExameMarVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: CellConfingName.ExamMarkCV, for: indexPath) as! ExamMarkCV
        
        let markTap = UITapGestureRecognizer(target: self, action: #selector(ViewMarks))
        cell.ViewMarkBtnview.addGestureRecognizer(markTap)
        cell.ViewMarkBtnview.isUserInteractionEnabled = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cv.frame.width / 2.2
        return CGSize(width: width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2 // No spacing between items
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // No spacing between rows
    }
    
}

//MARK: Searchbar Delegate
extension ExameMarVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        SearchBar.resignFirstResponder()
    }
}
