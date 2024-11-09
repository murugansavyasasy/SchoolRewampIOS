//
//  RatingTypeTableViewCell.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit

class RatingTypeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    
    @IBOutlet weak var collectionviewheight: NSLayoutConstraint!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var suggestContetTxtView: UITextView!
    
    var ratingDelegate : RatingDelegate?
    var load = false
    var names = [Categories(name: "App UI interface", selected: false),
                 Categories(name: "Watch UI", selected: false),
                 Categories(name: "Pricing", selected: false),
                 Categories(name: "Connection Stability", selected: false),
                 Categories(name: "Paring Experience", selected: false),
                 Categories(name: "Watch faces", selected: false),
                 Categories(name: "Watch Hardware", selected: false),
                 Categories(name: "Alumni Assistance", selected: false),
                 Categories(name: "User Login", selected: false),
                 Categories(name: "Registration", selected: false)]
    var SelectedCategory = Set<String>()
    override func awakeFromNib() {
        super.awakeFromNib()
        Uiupdate()
        collectionview.delegate = self
        collectionview.dataSource = self
        // Initialization code
        textview.layer.cornerRadius = 10
        textview.layer.borderWidth = 1
        textview.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    func Uiupdate(){
        collectionview.register(UINib(nibName: "SuggestionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SuggestionsCollectionViewCell")
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10 // Customize spacing between items
        layout.minimumLineSpacing = 10 // Customize line spacing
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
        collectionview.collectionViewLayout = layout
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return names.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "SuggestionsCollectionViewCell", for: indexPath) as! SuggestionsCollectionViewCell
        cell.layer.cornerRadius = 20
        
        
        cell.backgroundColor = names[indexPath.row].selected ?? false ?  .blue :UIColor(red: 216/255, green: 220/255, blue: 238/255, alpha: 1)
        
        cell.name.text = names[indexPath.item].name
        cell.name.textColor = names[indexPath.item].selected ?? false ?  .white :.black
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleString = names[indexPath.item].name
        let font = UIFont.systemFont(ofSize: 14) // Customize as needed
        let titleWidth = titleString?.size(withAttributes: [NSAttributedString.Key.font: font]).width ?? 0
        return CGSize(width: titleWidth + 40, height: 40) // Add padding if needed
        //        return CGSize(width: 100, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        names[indexPath.item].selected?.toggle()
        
        // Add or remove the category name from SelectedCategory based on its selection state
        if names[indexPath.item].selected == true {
            // Add the category name to SelectedCategory
            SelectedCategory.insert(names[indexPath.item].name ?? "")
        } else {
            // Remove the category name from SelectedCategory
            if let name = names[indexPath.item].name {
                if let index = SelectedCategory.firstIndex(of: name) {
                    SelectedCategory.remove(at: index)
                }
            }
        }
        
        collectionview.reloadData()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeight()
    }
    
    // Height update method for accurate collection view height
    func updateCollectionViewHeight() {
        collectionview.layoutIfNeeded()
        let collectionViewContentHeight = collectionview.collectionViewLayout.collectionViewContentSize.height
        collectionviewheight.constant = collectionViewContentHeight
        print("Collection View Content Height:", collectionViewContentHeight)
    }
    
    
    @IBAction func submit(_ sender: Any) {
        if SelectedCategory.count != 0{
            ratingDelegate?.Submit(SelectedCategory, suggessions: suggestContetTxtView.text)
        }
    }
    
    
}
class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
    }
}
struct Categories{
    let name:String?
    var selected : Bool?
}
