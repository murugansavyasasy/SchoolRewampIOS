//
//  UploadedProofsCardCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class UploadedProofsCardCell: UITableViewCell {

    static let reuseIdentifier = "UploadedProofsCardCell"

    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var paperclipImageView: UIImageView!

    private var proofs: [ProofUploadedItem] = []
    var onOpenProofURL: ((URL) -> Void)?
    var viewController : UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
        setupCollectionView()
    }

    private func setupCardStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardBackgroundView.backgroundColor = .white
        cardBackgroundView.layer.cornerRadius = 16.0
        cardBackgroundView.layer.borderWidth = 1.0
        cardBackgroundView.layer.borderColor = UIColor(red: 0.90, green: 0.93, blue: 0.96, alpha: 1.0).cgColor

        cardBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundView.layer.shadowOpacity = 0.04
        cardBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardBackgroundView.layer.shadowRadius = 6.0
        cardBackgroundView.layer.masksToBounds = false
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            UINib(nibName: ProofThumbnailCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: ProofThumbnailCell.reuseIdentifier
        )
    }

    func configure(with proofs: [ProofUploadedItem]) {
        self.proofs = proofs
        headerTitleLabel.text = "Proof (\(proofs.count))"
        paperclipImageView.image = UIImage(systemName: "paperclip")
        self.collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension UploadedProofsCardCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return proofs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProofThumbnailCell.reuseIdentifier,
            for: indexPath
        ) as? ProofThumbnailCell else {
            return UICollectionViewCell()
        }

        let item = proofs[indexPath.item]
        cell.configure(with: item) { [weak self] in
            if let url = URL(string: item.awsURL) {
                self?.onOpenProofURL?(url)
            }
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if proofs.count == 1 && collectionView.bounds.width > 120 {
            return CGSize(width: collectionView.bounds.width, height: 64.0)
        }
        return CGSize(width: 260.0, height: 64.0)
    }

   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = proofs[indexPath.item]
//        if let url = URL(string: item.awsURL) {
//            onOpenProofURL?(url)
//        }
    
   
        
    }
}
