//
//  WhatsNewVc.swift
//  School Chimes
//
//  Created by Chandhru on 14/10/25.
//

import UIKit
import AVKit
import AVFoundation
import Kingfisher

class WhatsNewVc: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var skipNextBtn: UIButton!
    @IBOutlet weak var skipPreviousBtn: UIButton!
    @IBOutlet weak var NextIconBtn: UIButton!
    @IBOutlet weak var PreviousIconBtn: UIButton!

    @IBOutlet weak var pageViewController: UIPageControl!
    @IBOutlet weak var tryItnowBtn: UIButton!

    // MARK: - Properties
    var data: [UpdateItem]?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var currentIndex = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        whatsNew_Api()
    }

    private func setupUI() {
        // CollectionView
        collectionView.register(UINib(nibName: "WhatsNewCVC", bundle: nil), forCellWithReuseIdentifier: "WhatsNewCVC")
        collectionView.delegate = self
        collectionView.dataSource = self

        // Header View
        headerView.layer.cornerRadius = 20
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.15
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        headerView.layer.shadowRadius = 8
        headerView.layer.masksToBounds = false
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        // Buttons
        tryItnowBtn.layer.cornerRadius = tryItnowBtn.layer.frame.height / 2
        setupButtonGradient(tryItnowBtn)

        // Default Image
        imageView.kf.setImage(with: URL(string: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//F5CB9561-8D48-492A-BEED-445BD479F5C6.jpg"))
        imageView.layer.cornerRadius = 10

        // Initial visibility for buttons
        skipPreviousBtn.isHidden = true
        PreviousIconBtn.isHidden = true
        skipNextBtn.isHidden = true
        NextIconBtn.isHidden = true
    }

    private func setupButtonGradient(_ button: UIButton) {
        // Remove old gradient if exists
        button.layer.sublayers?.forEach {
            if $0.name == "buttonGradientLayer" {
                $0.removeFromSuperlayer()
            }
        }

        let hexColors = ["#FFA500", "#FF3B30"] // Orange to red
        let cgColors = hexColors.map { UIColor(hex: $0).cgColor }

        let gradient = CAGradientLayer()
        gradient.colors = cgColors
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = button.bounds
        gradient.cornerRadius = button.layer.cornerRadius
        gradient.name = "buttonGradientLayer"
        button.layer.insertSublayer(gradient, at: 0)

        // Border
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        button.tintColor = .white
    }

    // MARK: - Actions
    @IBAction func exploreBtn(_ sender: UIButton) {
        guard let item = data?[currentIndex],
              let urlString = item.app_redirect_link,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func skipNext(_ sender: UIButton) {
        guard let total = data?.count, currentIndex < total - 1 else { return }
        currentIndex += 1

        let offsetX = CGFloat(currentIndex) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        pageViewController.currentPage = currentIndex

        // Update button visibility
        skipNextBtn.isHidden = (currentIndex == total - 1)
        NextIconBtn.isHidden = (currentIndex == total - 1)
        skipPreviousBtn.isHidden = false
        PreviousIconBtn.isHidden = false

        playVideoInVisibleCell()
    }


    @IBAction func skipPrevious(_ sender: UIButton) {
        guard currentIndex > 0 else { return }
        currentIndex -= 1

        let offsetX = CGFloat(currentIndex) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        pageViewController.currentPage = currentIndex

        // Update button visibility
        skipPreviousBtn.isHidden = (currentIndex == 0)
        PreviousIconBtn.isHidden = (currentIndex == 0)
        skipNextBtn.isHidden = false
        NextIconBtn.isHidden = false
        playVideoInVisibleCell()
    }


    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - API
    func whatsNew_Api() {
        if #available(iOS 15.0, *) { showActivityLoader() }

        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_dashboard_new_updates,
            parameters: ["role_type": staffDetails?.priority_level ?? ""],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<UpdateResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if #available(iOS 15.0, *) { self.hideActivityLoader() }

                switch result {
                case .success(let success):
                    if success.status ?? false {
                        self.data = success.data
                        self.pageViewController.numberOfPages = self.data?.count ?? 0
                        self.skipNextBtn.isHidden = (self.data?.count ?? 0) <= 1
                        self.NextIconBtn.isHidden = (self.data?.count ?? 0) <= 1
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - CollectionView Delegates
extension WhatsNewVc: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhatsNewCVC", for: indexPath) as? WhatsNewCVC else {
            return UICollectionViewCell()
        }
        if let item = data?[indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentIndex = page
        pageViewController.currentPage = page

        skipPreviousBtn.isHidden = (currentIndex == 0)
        PreviousIconBtn.isHidden = (currentIndex == 0)
        skipNextBtn.isHidden = (currentIndex == (data?.count ?? 0) - 1)
        NextIconBtn.isHidden = (currentIndex == (data?.count ?? 0) - 1)

        playVideoInVisibleCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    private func playVideoInVisibleCell() {
        guard let visibleIndexPath = collectionView.indexPathsForVisibleItems.first,
              let cell = collectionView.cellForItem(at: visibleIndexPath) as? WhatsNewCVC,
              let item = data?[visibleIndexPath.row] else { return }

        if let videoLink = item.video_link, !videoLink.isEmpty {
            cell.playVideo()
        } else {
            cell.stopVideo()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? WhatsNewCVC {
            cell.stopVideo()
        }
    }
}
