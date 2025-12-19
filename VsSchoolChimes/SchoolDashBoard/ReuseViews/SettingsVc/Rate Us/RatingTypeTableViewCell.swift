//
//  RatingTypeTableViewCell.swift
//  VsSchoolChimes
//  Created by Chandhru Veeramalai on 05/11/24.
//

import UIKit

protocol RatingTypeCellDelegate: AnyObject {
    func didUpdateHeight()
}

class RatingTypeTableViewCell: UITableViewCell,
                               UICollectionViewDelegate,
                               UICollectionViewDataSource,
                               UICollectionViewDelegateFlowLayout,
                               UITextViewDelegate {
    
    @IBOutlet weak var AnySuggestionsLbl: UILabel!
    @IBOutlet weak var collectionviewheight: NSLayoutConstraint!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var suggestContetTxtView: UITextView!
    @IBOutlet weak var suggestLbl: UILabel!
    @IBOutlet weak var SubmitBtn: UIButton!
    
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
        AnySuggestionsLbl.setFont(style: .body, size: FontSize.BodySize)
        SubmitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        textview.delegate = self
        collectionview.delegate = self
        collectionview.dataSource = self
        
        textview.layer.cornerRadius = Colornames.CORadius10
        textview.layer.borderWidth = 1
        textview.layer.borderColor = UIColor.lightGray.cgColor
        textview.addDoneButton()
        
        setAttributedText(for: suggestLbl,
                          with: CommonStringFile.any_other_suggestions.translated(),
                          firstString: CommonStringFile.Add_attachment.translated(),
                          secondString: CommonStringFile.Optional.translated(),
                          color1: .black,
                          color2: .lightGray)
        
        SubmitBtn.layer.cornerRadius = SubmitBtn.frame.height / 2
        
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
        
        AnySuggestionsLbl.text = names?.name ?? ""
        AnySuggestionsLbl.isHidden = self.names.isEmpty
        
        collectionview.reloadData()
        collectionview.layoutIfNeeded()
        
        updateCollectionViewHeight()
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
        
        names.sort { ($0.selected ?? false) && !($1.selected ?? false) }
        SelectedCategory?.category = names
        
        collectionView.reloadData()
        updateCollectionViewHeight()
    }
    
    // MARK: - Update Height
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeight()
    }
    
    func updateCollectionViewHeight() {
        collectionview.layoutIfNeeded()
        let height = collectionview.collectionViewLayout.collectionViewContentSize.height
        collectionviewheight.constant = height
        
        heightDelegate?.didUpdateHeight()
    }
    
    // MARK: - Submit
    @IBAction func submit(_ sender: Any) {
        if let ctegory = SelectedCategory {
            ratingDelegate?.Submit(ctegory, suggessions: suggestContetTxtView.text)
        }
    }
}
