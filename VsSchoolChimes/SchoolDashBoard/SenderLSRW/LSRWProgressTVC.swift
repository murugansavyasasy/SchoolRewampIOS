//
//  LSRWProgressTVC.swift
//  School Chimes
//
//  Created by Chandhru on 13/08/25.
//

import UIKit

class LSRWProgressTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var progressCV: UICollectionView!
    
    private var progressDataArray: [Overview]?
    private var filterArray = [
        "All",
        "Listening",
        "Speaking",
        "Reading",
        "Writing",
        "Completed",
        "Pending"
    ]
    
    var delegate: FilterDelegate?
    private var isFilterMode = false
    private var selection = false
    private var selectedIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    private func setupCollectionView() {
        progressCV.register(UINib(nibName: "LSRWProgressCVC", bundle: nil), forCellWithReuseIdentifier: "LSRWProgressCVC")
        progressCV.register(UINib(nibName: "FiltersCvCell", bundle: nil), forCellWithReuseIdentifier: "FiltersCvCell")
        
        progressCV.delegate = self
        progressCV.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        progressCV.collectionViewLayout = layout
        progressCV.showsHorizontalScrollIndicator = false
        progressCV.backgroundColor = .clear
    }
    
    // MARK: - Public Method
    func configure(with data: Any?, selectedIndex: Int = 0,selection:Bool? = false) {
        self.progressDataArray = data as? [Overview]
        self.isFilterMode = data == nil
        self.selection = selection ?? false
        self.selectedIndex = selectedIndex
        progressCV.reloadData()
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = progressDataArray, !data.isEmpty {
            return data.count
        } else {
            return filterArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let data = progressDataArray, !data.isEmpty {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LSRWProgressCVC", for: indexPath) as? LSRWProgressCVC else {
                return UICollectionViewCell()
            }
            let isSelected = indexPath.item == selectedIndex
            if selection{
                // Shadow and border for selected cell
                if isSelected {
                    cell.outerView.setShadow(shadowColor: .blue, shadowOpacity: 0.6, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8)
                    cell.outerView.layer.borderColor = UIColor.systemBlue.cgColor
                    cell.outerView.layer.borderWidth = 2
                } else {
                    cell.outerView.setShadow(shadowOpacity: 0)
                    cell.outerView.layer.borderColor = UIColor.clear.cgColor
                    cell.outerView.layer.borderWidth = 0
                }
            }
            cell.configure(with: data[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltersCvCell", for: indexPath) as? FiltersCvCell else {
                return UICollectionViewCell()
            }
            cell.FilterLbl.text = filterArray[indexPath.row]
            cell.cellView.backgroundColor = (selectedIndex == indexPath.item) ? UIColor.blue.withAlphaComponent(0.6) : .systemGray5
            cell.FilterLbl.textColor = (selectedIndex == indexPath.item) ? .white : .black
            cell.CheckboxImg.isHidden = true
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let data = progressDataArray, !data.isEmpty {
            let numberOfItemsPerRow: CGFloat = 2.5
            let spacingBetweenCells: CGFloat = 4
            let totalSpacing = (2 * 4) + ((numberOfItemsPerRow - 1) * spacingBetweenCells)
            
            let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
            let height: CGFloat = 120
            return CGSize(width: width, height: height)
        } else {
            let text = filterArray[indexPath.row]
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            let padding: CGFloat = 20
            let textWidth = text.size(withAttributes: [.font: font]).width
            let height: CGFloat = 40
            return CGSize(width: max(50, textWidth + padding), height: height)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFilterMode {
            delegate?.selectedIndex(index: indexPath.item)
        } else {
            selectedIndex = indexPath.item
            collectionView.reloadData()
            delegate?.navigate(index: indexPath.item)
        }
    }

    
    // MARK: - Handle Progress Item Tap (Optional Implementation)
    private func handleProgressItemTap(_ item: Overview) {
        switch item.title {
        case "Active Tasks":
            break // Implement as needed
        case "Total Students":
            break // Implement as needed
        case "Avg. Performance":
            break // Implement as needed
        case "Completed Today":
            break // Implement as needed
        default:
            break
        }
    }
}
