//
//  NoticeBoardVc.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

@available(iOS 14.0, *)
class NoticeBoardVc: UIViewController {
    @IBOutlet weak var HeadingLabel: UILabel!
    
    @IBOutlet weak var plusImgview: UIImageView!
    
    @IBOutlet weak var tableview: UITableView!
    
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    var images : [UIImage] = []
    
    var previousOffset: CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.placeholder = "Search".translated()
        searchbar.delegate = self
        addDoneButton()
        
        HeadingLabel.text = "NoticeBoard".translated()
        HeadingLabel.setFont(style: .header, size: FontSize.HeaderSize)
        tableview.delegate = self
        tableview.dataSource = self
        plusImgview.isHidden = true
        
        let nib = UINib(nibName:"NoticeBoardTvcellTableViewCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "NoticeBoardTvcellTableViewCell")
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(Plusclick))
//        plusImgview.addGestureRecognizer(tap)
        plusImgview.isUserInteractionEnabled = false
        plusImgview.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        ApiCallFunc
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.reloadData()
    }
    
    @IBAction func Plusclick(_ sender : Any){
//        let vc = SenderNoticeBoardVC(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
    
    
    
    @IBAction func BackBtnAct(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

@available(iOS 14.0, *)
extension NoticeBoardVc : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardTvcellTableViewCell", for: indexPath) as! NoticeBoardTvcellTableViewCell
        
        return cell
    }
  
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        
        // Check for scroll direction
        if contentOffsetY > previousOffset && contentOffsetY > 0 {
            // Scrolling Down
            print("Scrolling Down")
//            plusImgview.isHidden = true
        } else if contentOffsetY < previousOffset {
            // Scrolling Up
            print("Scrolling Up")
//            plusImgview.isHidden = false
        }
        
        // Update the previous offset for the next scroll event
        previousOffset = contentOffsetY
    }
    
    //scrol
}

@available(iOS 14.0, *)
extension NoticeBoardVc: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }
    
    func addDoneButton(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
            
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(DoneBtnAct))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)


        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        searchbar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        searchbar.resignFirstResponder()
    }

}


