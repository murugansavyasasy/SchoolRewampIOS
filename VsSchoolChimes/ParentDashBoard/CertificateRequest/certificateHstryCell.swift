//
//  certificateHstryCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit

class certificateHstryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Outlets
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var historyLbl: UILabel!
    
    // MARK: - Properties
    let transitionDelegate = TransitioningDelegate()
    var certificate: [CertificateRequest]? = []
    var filteredCertificates: [CertificateRequest] = []
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup search bar
        searchBar.isHidden = true
        searchBar.delegate = self
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        
        // Register collection view cell
        cv.register(UINib(nibName: "certificateHstryCvCell", bundle: nil),
                    forCellWithReuseIdentifier: "certificateHstryCvCell")
        
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
    }

    // MARK: - Configuration
    func configure(with files: [CertificateRequest]?) {
        certificate = files
        historyLbl.isHidden = files?.isEmpty ?? true
        filteredCertificates = files ?? []
        cv.reloadData()
        updateCollectionViewHeight()
    }
    
    func updateCollectionViewHeight() {
        let height = cv.collectionViewLayout.collectionViewContentSize.height
        cvHeight.constant = height
    }
    
    func collectionContentHeight() -> CGFloat {
        return cv.collectionViewLayout.collectionViewContentSize.height
    }
    
    // MARK: - SearchBar Visibility Toggle
    func toggleSearchBar(_ isVisible: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.searchBar.isHidden = !isVisible
            self.layoutIfNeeded()
        }
        
        if !isVisible {
            // Reset search and reload all certificates
            searchBar.text = ""
            filteredCertificates = certificate ?? []
            cv.reloadData()
            updateCollectionViewHeight()
        }
    }
    
    // MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCertificates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "certificateHstryCvCell",
            for: indexPath
        ) as? certificateHstryCvCell else {
            return UICollectionViewCell()
        }
        
        let cert = filteredCertificates[indexPath.item]
        cell.reasonLbl.text = "Reason : \(cert.reason ?? "")"
        let reqDate = formattedDateStatus(from: cert.requested_on ?? "")
        cell.dateLbl.text = reqDate
        cell.typeLbl.text = cert.type
        
        return cell
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CertificatePreviewVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen

        let certi = filteredCertificates[indexPath.item]
        vc.certificate = certi

        getCurrentViewController()?.present(vc, animated: true)
    }
    
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width) / 2
        return CGSize(width: size, height: 130)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - UISearchBarDelegate
extension certificateHstryCell: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If user cleared the search bar, show all certificates
        if trimmed.isEmpty {
            filteredCertificates = certificate ?? []
        } else {
            filteredCertificates = certificate?.filter { cert in
                let reasonMatch = cert.reason?.localizedCaseInsensitiveContains(trimmed) ?? false
                let typeMatch = cert.type?.localizedCaseInsensitiveContains(trimmed) ?? false
                let requestedMatch = cert.requested_on?.localizedCaseInsensitiveContains(trimmed) ?? false
                let issuedMatch = cert.issued_on?.localizedCaseInsensitiveContains(trimmed) ?? false
                
                // Match any one of them
                return reasonMatch || typeMatch || requestedMatch || issuedMatch
            } ?? []
        }

        // Reload collection view after filtering
        cv.reloadData()
        
        // ---- Smooth height update trick ----
            UIView.performWithoutAnimation {
                self.cv.reloadData()
                self.cv.layoutIfNeeded()
                self.updateCollectionViewHeight()
                self.layoutIfNeeded()
            }

            // Now tell tableView to refresh layout, but without jump
            if let tableView = self.findParentTableView() {
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension UIView {
    func findParentTableView() -> UITableView? {
        var view = self.superview
        while let v = view {
            if let table = v as? UITableView {
                return table
            }
            view = v.superview
        }
        return nil
    }
}
