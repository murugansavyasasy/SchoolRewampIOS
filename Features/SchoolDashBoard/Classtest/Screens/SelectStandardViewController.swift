import UIKit

public final class SelectStandardViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet public weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    public var viewModel: CreateTestViewModel?
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchMarksAndNavigate()    }
    func fetchMarksAndNavigate() {
            showActivityLoader()

            viewModel?.getMarkDetails(
                class_test_id: "3",
                section_id: "91746",
                completion: { [weak self] result in
                    
                    guard let self = self else { return }

                    DispatchQueue.main.async {
                        self.hideActivityLoader()

                        switch result {
                        case .success(let records):
                            self.navigateToEnterMark(with: records)

                        case .failure(let error):
                            print("❌ Error:", error.localizedDescription)
                        }
                    }
                }
            )
        }

        func navigateToEnterMark(with records: [StudentMark]) {
            let vc = EnterMarkVC()
            vc.studentRecords = records
            vc.allStudents = records
            vc.uploadTest = true
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register XIB
        let nib = UINib(nibName: "StandardCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "StandardCollectionViewCell")
        
        // Set layout details
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.collectionViewLayout = layout
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension SelectStandardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.standards.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardCollectionViewCell", for: indexPath) as? StandardCollectionViewCell,
              let standard = viewModel?.standards[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        let isSelected = viewModel?.selectedStandard?.id == standard.id
        cell.configure(with: standard, isSelected: isSelected)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let standard = viewModel?.standards[indexPath.item] else { return }
        viewModel?.selectStandard(standard)
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 2 + 16 * 2 // Side margins + inner inter-item spacing
        let collectionViewWidth = collectionView.bounds.width
        
        // Responsive Columns (3 columns for wider screens/iPad/Pro Max, 2 columns for smaller/iPhone SE)
        let columns: CGFloat = collectionViewWidth > 380 ? 3 : 2
        let width = (collectionViewWidth - padding) / columns
        return CGSize(width: width, height: 110)
    }
}
