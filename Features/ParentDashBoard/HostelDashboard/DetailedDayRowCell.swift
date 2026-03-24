import UIKit

protocol DetailedDayRowCellDelegate: AnyObject {
    func detailedDayRow(_ cell: DetailedDayRowCell, didScrollTo offset: CGPoint)
}

class DetailedDayRowCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    weak var delegate: DetailedDayRowCellDelegate?
    private var statuses: [String] = []
    private var isHeader: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "SessionStatusCell", bundle: nil), forCellWithReuseIdentifier: "SessionStatusCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero
        }
    }
    
    func configure(dayLabel: String, statuses: [String], isHeader: Bool = false) {
        self.isHeader = isHeader
        self.dayLabel.text = dayLabel
        self.dayLabel.font = isHeader ? .systemFont(ofSize: 14, weight: .bold) : .systemFont(ofSize: 14, weight: .medium)
        self.dayLabel.textColor = isHeader ? .darkGray : .black
        self.backgroundColor = isHeader ? UIColor(white: 0.96, alpha: 1) : .white
        
        self.statuses = statuses
        self.collectionView.reloadData()
    }
    
    func syncScroll(to offset: CGPoint) {
        if collectionView.contentOffset != offset {
            collectionView.setContentOffset(offset, animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.detailedDayRow(self, didScrollTo: scrollView.contentOffset)
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statuses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionStatusCell", for: indexPath) as! SessionStatusCell
        if isHeader {
            cell.configureHeader(sessionName: statuses[indexPath.item])
        } else {
            cell.configure(status: statuses[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: collectionView.bounds.height)
    }
}
