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
    @IBOutlet weak var nextBtn1: UIButton!
    @IBOutlet weak var nextview: UIView!
    var isRTL: Bool {
        UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft
    }
    var dataResponse: [IntroFeature] = []
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onBoardingCV.register(UINib(nibName: CellConfingName.OnboardingCVC, bundle: nil),
                              forCellWithReuseIdentifier: CellConfingName.OnboardingCVC)
        self.skipBtn.isHidden = self.dataResponse.count < 1
        self.nextview.isHidden = self.dataResponse.count < 1
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
                            if success.data?.count == 0{
                                self.navigateToLogin()
                            }else{
                                self.dataResponse = success.data ?? []
                                self.pageControl.numberOfPages = self.dataResponse.count
                                self.skipBtn.isHidden = self.dataResponse.count <= 1
                                self.nextBtn.isHidden = self.dataResponse.count <= 1
                                self.currentPage = self.isRTL ? self.dataResponse.count - 1 : 0
                                self.onBoardingCV.reloadData()
                            }
                        }else{
                            self.navigateToLogin()
                        }
                    case .failure(let error):
                        self.navigateToLogin()
                        print("Onboarding API Error:", error.localizedDescription)
                        self.navigateToLogin()
                        self.skipBtn.isHidden = self.dataResponse.count < 1
                        self.nextview.isHidden = self.dataResponse.count < 1
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        let isLastLogicalPage = currentPage >= dataResponse.count - 1
        if !isLastLogicalPage {
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
        onBoardingCV.scrollToItem(at: IndexPath(item: currentPage, section: 0),at: .centeredHorizontally,animated: true)
        
        let isLastPage = currentPage == dataResponse.count - 1
        skipBtn.isHidden = isLastPage
        nextBtn.setTitle(isLastPage ? "Let's Go" : "Next".translated(), for:.normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
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
        pageControl.currentPage = indexPath.item
        if let onboardingCell = cell as? OnboardingCVC {
            onboardingCell.animateStepByStep()
           
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let visibleRect = CGRect(origin: onBoardingCV.contentOffset,
                                 size: onBoardingCV.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX,
                                   y: visibleRect.midY)
        guard let indexPath = onBoardingCV.indexPathForItem(at: visiblePoint),
              indexPath.item < dataResponse.count else {
            return
        }

        currentPage = indexPath.item
        pageControl.currentPage = currentPage

        let isLastPage = currentPage == dataResponse.count - 1
        skipBtn.isHidden = isLastPage
        nextBtn.setTitle(isLastPage ? "Let's Go" : "Next".translated(), for: .normal)
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
