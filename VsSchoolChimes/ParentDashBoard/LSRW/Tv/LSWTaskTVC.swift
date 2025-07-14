import UIKit

class LSWTaskTVC: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    // MARK: - Data
    var tags: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DefaultCell")
    }

    // MARK: - Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
        
        // Remove old subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // Configure label
        let label = UILabel()
        label.text = tags[indexPath.item]
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 8
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.borderWidth = 1
        label.layer.masksToBounds = true
        
        // Dynamic sizing
        label.sizeToFit()
        let labelWidth = label.frame.width + 16
        label.frame = CGRect(x: 0, y: 0, width: labelWidth, height: 32)
        label.center = CGPoint(x: cell.bounds.midX, y: cell.bounds.midY)
        
        cell.contentView.addSubview(label)
        
        return cell
    }

    // MARK: - Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = tags[indexPath.item]
        let font = UIFont.systemFont(ofSize: 14)
        let width = (text as NSString).size(withAttributes: [.font: font]).width + 24
        return CGSize(width: width, height: 32)
    }
}
