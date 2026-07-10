//
//  OnboardingVC.swift
//  School Chimes
//
//  Created by Chandhru on 10/11/25.
//

import UIKit

class OnboardingVC: UIViewController {
    
    @IBOutlet weak var onBoardingCV: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var nextview: UIView!
    
    var dataResponse: [IntroFeature] = []
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onBoardingCV.register(UINib(nibName: CellConfingName.OnboardingCVC, bundle: nil),
                              forCellWithReuseIdentifier: CellConfingName.OnboardingCVC)
        
        onBoardingCV.delegate = self
        onBoardingCV.dataSource = self
        nextview.layer.cornerRadius = nextview.frame.height / 2
        onBoarding_Api()
    }
    
    // MARK: - API Call
    func onBoarding_Api() {
        if #available(iOS 15.0, *) {
            APIService.shared.makeApi(
                url: ServiceUrl.dashboard_api_dashboard_features,
                parameters: [:],
                type: ApitTypeSringFile.GET,
                token: "", isBaseUrl: true
            ) { [weak self] (result: Result<IntroResponse, Error>) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        if success.status ?? false {
                            self.dataResponse = success.data ?? []
                            self.pageControl.numberOfPages = self.dataResponse.count
                            self.skipBtn.isHidden = self.dataResponse.count <= 1
                            self.nextBtn.isHidden = self.dataResponse.count <= 1
                            self.onBoardingCV.reloadData()
                        }
                    case .failure(let error):
                        print("Onboarding API Error:", error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        if currentPage < dataResponse.count - 1 {
            currentPage += 1
            updateUI()
        } else {
            navigateToLogin()
        }
    }
    
    @IBAction func skipBtnTapped(_ sender: UIButton) {
        navigateToLogin()
    }
    
    func navigateToLogin() {
        UserDefaults.standard.set(true, forKey: "Onboarding")
        let vc = CountryListVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    // MARK: - Update UI
    private func updateUI() {
        pageControl.currentPage = currentPage
        
        onBoardingCV.scrollToItem(at: IndexPath(item: currentPage, section: 0),
                                  at: .centeredHorizontally,
                                  animated: true)
        let isLastPage = currentPage == dataResponse.count - 1
        skipBtn.isHidden = isLastPage
        nextBtn.setTitle(isLastPage ? "Let's Go" : "Next".translated(), for: .normal)
        // Trigger animation after scroll completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if let cell = self.onBoardingCV.cellForItem(at: IndexPath(item: self.currentPage, section: 0)) as? OnboardingCVC {
                cell.animateStepByStep()
            }
        }
    }
}

extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataResponse.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.OnboardingCVC,
            for: indexPath
        ) as! OnboardingCVC
        
        let item = dataResponse[indexPath.item]
        cell.headingLbl.text = item.title
        cell.descriptionLbl.text = indexPath.item == 0 ? "" : item.description
        if let urlString = item.file_path?.first?.url,
           let url = URL(string: urlString) {
            cell.imgView.sd_setImage(with: url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let onboardingCell = cell as? OnboardingCVC {
            onboardingCell.animateStepByStep()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        updateUI()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.width,
            height: collectionView.frame.height
        )
    }
}
