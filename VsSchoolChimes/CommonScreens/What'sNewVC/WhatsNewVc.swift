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
    @IBOutlet weak var updateLbl: UILabel!
    @IBOutlet weak var whatsnewLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backBtn: UIButton!
//    @IBOutlet weak var headerView: AnimatedGradientView!
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
    var chaildDetails = UserDefaultFileManager.get_child_Details()
    var currentIndex = 0
    var isStaff = false
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        whatsNew_Api()
    }

    private func setupUI() {
        // CollectionView Setup
        collectionView.register(UINib(nibName: "WhatsNewCVC", bundle: nil), forCellWithReuseIdentifier: "WhatsNewCVC")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Back Button Setup
        backBtn.layer.cornerRadius = backBtn.frame.width / 2
        updateLbl.layer.cornerRadius = updateLbl.frame.height / 2
            updateLbl.layer.masksToBounds = true
        // Header View Setup - Animated Gradient Banner
        headerView.layer.cornerRadius = 20
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.15
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        headerView.layer.shadowRadius = 8
        headerView.layer.masksToBounds = false
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        // Try It Now Button Setup
        tryItnowBtn.layer.cornerRadius = tryItnowBtn.layer.frame.height / 2
        setupButtonGradient(tryItnowBtn)

        // Initial visibility for navigation buttons
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
        updateNavigationButtonVisibility()
        playVideoInVisibleCell()
    }

    @IBAction func skipPrevious(_ sender: UIButton) {
        guard currentIndex > 0 else { return }
        currentIndex -= 1

        let offsetX = CGFloat(currentIndex) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        pageViewController.currentPage = currentIndex

        // Update button visibility
        updateNavigationButtonVisibility()
        playVideoInVisibleCell()
    }

    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Helper Methods
    private func updateNavigationButtonVisibility() {
        let total = data?.count ?? 0
        let isFirstPage = (currentIndex == 0)
        let isLastPage = (currentIndex == total - 1)

        skipPreviousBtn.isHidden = isFirstPage
        PreviousIconBtn.isHidden = isFirstPage
        skipNextBtn.isHidden = isLastPage
        NextIconBtn.isHidden = isLastPage
    }

    // MARK: - API
    func whatsNew_Api() {
        if #available(iOS 15.0, *) { showActivityLoader() }
        let token = isStaff ? staffDetails?.access_token ?? "" : chaildDetails?.access_token ?? ""
        let roll = isStaff ? staffDetails?.priority_level ?? "" : "parent"
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_dashboard_new_updates,
            parameters: ["role_type": roll],
            type: ApitTypeSringFile.GET,
            token: token
        ) { [weak self] (result: Result<UpdateResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if #available(iOS 15.0, *) { self.hideActivityLoader() }

                switch result {
                case .success(let success):
                    if success.status ?? false {
                        self.data = success.data
                        self.pageViewController.numberOfPages = self.data?.count ?? 0
                        let hasMultipleItems = (self.data?.count ?? 0) > 1
                        self.skipNextBtn.isHidden = !hasMultipleItems
                        self.NextIconBtn.isHidden = !hasMultipleItems
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
        
        updateNavigationButtonVisibility()
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

// MARK: - Animated Gradient View (Banner Style)
class AnimatedGradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    private var displayLink: CADisplayLink?
    private var animationProgress: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupView() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        setupGradientLayer()
        startAnimatingGradient()
    }
    
    private func setupGradientLayer() {
        // Galaxy Universe Stars banner - Deep space colors
        gradientLayer.colors = [
            UIColor(hex: "#0A0E27").cgColor,      // Deep dark blue
            UIColor(hex: "#1A0F3D").cgColor,      // Dark purple
            UIColor(hex: "#2D1B4E").cgColor,      // Royal purple
            UIColor(hex: "#1F4788").cgColor,      // Deep blue
            UIColor(hex: "#0F2B5C").cgColor,      // Navy blue
            UIColor(hex: "#1A0F3D").cgColor,      // Dark purple
            UIColor(hex: "#0A0E27").cgColor       // Back to deep blue (loop)
        ]
        
        gradientLayer.locations = [0, 0.16, 0.33, 0.5, 0.66, 0.83, 1]
        gradientLayer.startPoint = CGPoint(x: -0.5, y: -0.5)
        gradientLayer.endPoint = CGPoint(x: 1.5, y: 1.5)
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Add star particles effect
        addStarParticles()
    }
    
    private func addStarParticles() {
        // Create star emitter effect
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitterLayer.emitterShape = .circle
        emitterLayer.emitterSize = CGSize(width: 300, height: 300)
        emitterLayer.renderMode = .additive
        
        // Create star cell
        let cell = CAEmitterCell()
        cell.birthRate = 15
        cell.lifetime = 3
        cell.scale = 0.002
        cell.alphaSpeed = -0.33
        cell.velocity = 50
        cell.yAcceleration = 10
        cell.emissionRange = .pi * 2
        
        // Create star image
        if let starImage = createStarImage() {
            cell.contents = starImage.cgImage
        }
        
        emitterLayer.emitterCells = [cell]
        layer.addSublayer(emitterLayer)
    }
    
    private func createStarImage() -> UIImage? {
        let size = CGSize(width: 4, height: 4)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func startAnimatingGradient() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateGradient)
        )
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateGradient() {
        animationProgress += 0.005  // Slow, cosmic speed
        if animationProgress > 1 {
            animationProgress = 0
        }
        
        // Create cosmic swirling effect
        let rotationX = sin(animationProgress * CGFloat.pi * 2) * 0.7
        let rotationY = cos(animationProgress * CGFloat.pi * 2) * 0.7
        
        gradientLayer.startPoint = CGPoint(
            x: 0.5 + rotationX,
            y: 0.5 + rotationY
        )
        
        gradientLayer.endPoint = CGPoint(
            x: 0.5 - rotationX,
            y: 0.5 - rotationY
        )
        
        // Animate color positions for cosmic shifts
        let offset = animationProgress
        let locations: [NSNumber] = [
            NSNumber(value: offset),
            NSNumber(value: offset + 0.16),
            NSNumber(value: offset + 0.33),
            NSNumber(value: offset + 0.5),
            NSNumber(value: offset + 0.66),
            NSNumber(value: offset + 0.83),
            NSNumber(value: offset + 1)
        ]
        
        gradientLayer.locations = locations
    }
    
    func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    deinit {
        stopAnimating()
    }
}

