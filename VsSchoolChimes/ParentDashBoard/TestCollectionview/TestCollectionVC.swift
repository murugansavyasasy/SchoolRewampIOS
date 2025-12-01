//
//  FlipkartLayout.swift
//  Custom layout for Flipkart-style grid
//

import UIKit

class FlipkartLayout: UICollectionViewLayout {
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        contentHeight = 0
        
        let totalWidth = collectionView.bounds.width
        let bigCellWidth = totalWidth * 0.55
        let gridWidth = totalWidth - bigCellWidth
        let smallCellWidth = gridWidth / 2
        let bigCellHeight = totalWidth * 0.60
        let smallCellHeight = bigCellHeight / 2
        let sectionSpacing: CGFloat = 8
        
        var yOffset: CGFloat = 0
        
        let numberOfSections = collectionView.numberOfSections
        
        for section in 0..<numberOfSections {
            let itemCount = collectionView.numberOfItems(inSection: section)
            
            if section == 0 {
                // SECTION 0: Big cell LEFT, Grid RIGHT
                
                // Big cell (item 0) - LEFT side
                let bigFrame = CGRect(x: 0, y: yOffset, width: bigCellWidth, height: bigCellHeight)
                let bigIndexPath = IndexPath(item: 0, section: section)
                let bigAttributes = UICollectionViewLayoutAttributes(forCellWith: bigIndexPath)
                bigAttributes.frame = bigFrame
                cache.append(bigAttributes)
                
                // Grid cells (items 1-4) - RIGHT side
                for item in 1..<itemCount {
                    let row = (item - 1) / 2
                    let col = (item - 1) % 2
                    
                    let x = bigCellWidth + (CGFloat(col) * smallCellWidth)
                    let y = yOffset + (CGFloat(row) * smallCellHeight)
                    
                    let frame = CGRect(x: x, y: y, width: smallCellWidth, height: smallCellHeight)
                    let indexPath = IndexPath(item: item, section: section)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    cache.append(attributes)
                }
                
            } else if section == 1 {
                // SECTION 1: Grid LEFT, Big cell RIGHT
                
                // Grid cells (items 0-3) - LEFT side
                for item in 0..<4 {
                    let row = item / 2
                    let col = item % 2
                    
                    let x = CGFloat(col) * smallCellWidth
                    let y = yOffset + (CGFloat(row) * smallCellHeight)
                    
                    let frame = CGRect(x: x, y: y, width: smallCellWidth, height: smallCellHeight)
                    let indexPath = IndexPath(item: item, section: section)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    cache.append(attributes)
                }
                
                // Big cell (item 4) - RIGHT side
                let bigFrame = CGRect(x: gridWidth, y: yOffset, width: bigCellWidth, height: bigCellHeight)
                let bigIndexPath = IndexPath(item: 4, section: section)
                let bigAttributes = UICollectionViewLayoutAttributes(forCellWith: bigIndexPath)
                bigAttributes.frame = bigFrame
                cache.append(bigAttributes)
            }
            
            yOffset += bigCellHeight + sectionSpacing
        }
        
        contentHeight = yOffset
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }
    }
}

//
//  TestCollectionVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/12/25.
//

import UIKit

class TestCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var testCV: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set custom layout
        let layout = FlipkartLayout()
        testCV.collectionViewLayout = layout
        
        testCV.delegate = self
        testCV.dataSource = self
        testCV.register(UINib(nibName: "TestCVC", bundle: nil), forCellWithReuseIdentifier: "TestCVC")
    }

    // MARK: - Sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2   // 2 sections like Flipkart
    }

    // MARK: - Items in each section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5  // Each section has 5 items (1 big + 4 small)
    }

    // MARK: - Cell creation
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCVC", for: indexPath) as! TestCVC
        
        // Configure cell appearance
        let isBigCell = (indexPath.section == 0 && indexPath.item == 0) ||
                        (indexPath.section == 1 && indexPath.item == 4)
        
        cell.backgroundColor = isBigCell ? .systemBlue : .systemGray5
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.systemGray3.cgColor
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: Section \(indexPath.section), Item \(indexPath.item)")
    }
}
