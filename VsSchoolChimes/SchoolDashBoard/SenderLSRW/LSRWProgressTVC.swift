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
    var delegate:FilterDelegate?
    private var filtterArray = [
        "All",
        "Listening",
        "Speaking",
        "Reading",
        "Writing",
        "Completed",
        "Pending"
    ]
    var selectedIndex = 0
    var filter = false
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
        layout.minimumLineSpacing = 4   // Reduced from 5
        layout.minimumInteritemSpacing = 4 // Reduced from 5
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) // Reduced padding
        progressCV.collectionViewLayout = layout
        
        progressCV.showsHorizontalScrollIndicator = false
        progressCV.backgroundColor = .clear
    }
    
    // MARK: - Public Methods
    func configure(with data: Any?, selectedIndex:Int? = 0) {
        self.progressDataArray = data as? [Overview]
        self.filter = data == nil
        self.selectedIndex = selectedIndex ?? 0
        progressCV.reloadData()
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (progressDataArray?.isEmpty == false) ? progressDataArray!.count : filtterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let data = progressDataArray, !data.isEmpty {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LSRWProgressCVC", for: indexPath) as? LSRWProgressCVC else {
                return UICollectionViewCell()
            }
            cell.configure(with: data[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltersCvCell", for: indexPath) as? FiltersCvCell else {
                return UICollectionViewCell()
            }
            cell.FilterLbl.text = filtterArray[indexPath.row]
            cell.cellView.backgroundColor = selectedIndex == indexPath.item ? .blue.withAlphaComponent(0.6):.systemGray5
            cell.FilterLbl.textColor = selectedIndex == indexPath.item ? .white:.black
            cell.CheckboxImg.isHidden = true
            return cell
        }
    }
    
    // MARK: - UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let data = progressDataArray, !data.isEmpty {
            let numberOfItemsPerRow: CGFloat = 2.5
            let spacingBetweenCells: CGFloat = 4 // Reduced spacing
            let totalSpacing = (2 * 4) + ((numberOfItemsPerRow - 1) * spacingBetweenCells)
            
            let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
            let height: CGFloat = 120
            
            return CGSize(width: width, height: height)
        } else {
            let text = filtterArray[indexPath.row]
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            let padding: CGFloat = 20 // Reduced padding from 32

            let textWidth = text.size(withAttributes: [.font: font]).width
            let height: CGFloat = 40 // Slightly smaller height

            return CGSize(width: max(50, textWidth + padding), height: height)

        }
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filter == true {
            delegate?.selectedIndex(index: indexPath.item)
        }else{
            delegate?.navigate(index: indexPath.item)
        }
    }
    
    private func handleProgressItemTap(_ item: Overview) {
        switch item.title {
        case "Active Tasks": break
        case "Total Students": break
        case "Avg. Performance": break
        case "Completed Today": break
        default: break
        }
    }
}
