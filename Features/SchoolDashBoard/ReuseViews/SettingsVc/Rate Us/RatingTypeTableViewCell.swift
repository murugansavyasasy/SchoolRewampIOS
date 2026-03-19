//
//  RatingTypeTableViewCell.swift
//  VsSchoolChimes
//  Created by Chandhru Veeramalai on 05/11/24.
//

import UIKit

protocol RatingTypeCellDelegate: AnyObject {
    func didUpdateHeight(_ set:Bool)
}

class RatingTypeTableViewCell: UITableViewCell,
                               UICollectionViewDelegate,
                               UICollectionViewDataSource,
                               UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var collectionviewheight: NSLayoutConstraint!
    @IBOutlet weak var collectionview: UICollectionView!
   
    
    var ratingDelegate: RatingDelegate?
    weak var heightDelegate: RatingTypeCellDelegate?

    var names: [Categories] = []
    var SelectedCategory : CategoriesSection?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        names = []
        collectionview.reloadData()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        
        
        collectionview.delegate = self
        collectionview.dataSource = self
        
        // Register Cell
        collectionview.register(
            UINib(nibName: CellConfingName.SuggestionsCollectionViewCell, bundle: nil),
            forCellWithReuseIdentifier: CellConfingName.SuggestionsCollectionViewCell
        )
        
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5)
        collectionview.collectionViewLayout = layout
    }
    
    // MARK: - Configure
    func configure(names: CategoriesSection?, rating: Int) {
        SelectedCategory = names
        self.names = names?.category ?? []
        collectionview.reloadData()
        
        DispatchQueue.main.async {
            self.updateCollectionViewHeight()
        }
    }
    // MARK: - CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return names.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.SuggestionsCollectionViewCell,
            for: indexPath
        ) as! SuggestionsCollectionViewCell
        
        let isSelected = names[indexPath.row].selected ?? false
        
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 1
        
        let selectedColor = UIColor.orange
        let normalColor = UIColor(red: 216/255, green: 220/255, blue: 238/255, alpha: 1)
        
        cell.backgroundColor = isSelected ? selectedColor.withAlphaComponent(0.2) : normalColor
        cell.layer.borderColor = (isSelected ? selectedColor : normalColor).cgColor
        
        cell.name.text = names[indexPath.item].name
        cell.name.textColor = .black
        
        return cell
    }

    // Dynamic cell width
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let title = names[indexPath.item].name ?? ""
        let font = UIFont.systemFont(ofSize: 13)
        let width = title.size(withAttributes: [.font: font]).width
        
        return CGSize(width: width + 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let newValue = !(names[indexPath.item].selected ?? false)
        names[indexPath.item].selected = newValue
        
        if SelectedCategory?.category != nil {
            SelectedCategory?.category?[indexPath.item].selected = newValue
        }
        
//        names.sort { ($0.selected ?? false) && !($1.selected ?? false) }
        SelectedCategory?.category = names
        if let ctegory = SelectedCategory {
            ratingDelegate?.Submit(ctegory)
        }
        collectionView.reloadData()
    }

    func updateCollectionViewHeight() {
        collectionview.collectionViewLayout.invalidateLayout()
        collectionview.layoutIfNeeded()
        
        let height = collectionview.collectionViewLayout.collectionViewContentSize.height
        
        if collectionviewheight.constant != height {
            collectionviewheight.constant = height
            heightDelegate?.didUpdateHeight(true)
        }
    }
}
