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

        onBoardingCV.register(UINib(nibName: "OnboardingCVC", bundle: nil),
                              forCellWithReuseIdentifier: "OnboardingCVC")

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
                token: ""
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

    /// Updates button visibility & title
    private func updateUI() {
        pageControl.currentPage = currentPage
        onBoardingCV.scrollToItem(at: IndexPath(item: currentPage, section: 0),
                                  at: .centeredHorizontally,
                                  animated: true)

        let isLastPage = currentPage == dataResponse.count - 1
        skipBtn.isHidden = isLastPage
        nextBtn.setTitle(isLastPage ? "Let's Go" : "Next", for: .normal)
    }

}

// MARK: - CollectionView Delegates
extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataResponse.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "OnboardingCVC",
            for: indexPath) as? OnboardingCVC else {

            return UICollectionViewCell()
        }

        let item = dataResponse[indexPath.item]
        cell.headingLbl.text = item.title
        if indexPath.item == 0 {
            cell.descriptionLbl.text = "•Developed a comprehensive healthcare app, implementing user registration, password management, profile editing, and notifications. •Designed intuitive interfaces for Home, Profile, Appointment, and Resources screens. •Enhanced patient management with secure authentication, real-time appointment tracking, multi-medium communication, and digital note-taking. •Integrated appointment management, patient status, letter generation, digital signatures, and payment processing. •Created a platform for medical professionals with features for appointment management, patient progress tracking, medication prescribing, and secure communication. •Ensured robust security and user-friendly navigation. •Individual Contribution: Patient App, Doctor's App & Front Office iPad App frontend design and Connectivity Happy Testing | Secure Digital Exam Software •Developed a platform for educational institutions to manage the creation, delivery, and evaluation of examinations. •Supported both objective and subjective questions with features such as instant exam delivery, question banks, multiple question papers, and multi-level evaluation. •Integrated test history and analytics to enhance examination management. •Individual Contribution: Student App and Teacher App"
        }else{
            cell.descriptionLbl.text = item.description
        }
        if let urlString = item.file_path?.first?.url,
           let url = URL(string: urlString) {
            cell.imgView.sd_setImage(with: url)
        }

        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        updateUI()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }
}
