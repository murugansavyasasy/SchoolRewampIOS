//
//  EventPageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 04/12/24.
//
import UIKit
protocol HistorySelectDelegate{
    func select(Title:String,Description:String,Images:[UIImage],pdf:String)
}
@available(iOS 14.0, *)
class EventPageVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, HistorySelectDelegate{

    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var presentView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = UIViewController()
    var page2 = UIViewController() 
    var titleLbl = ""
    var button1 = "Create".translated()
    var button2 = "History".translated()
    override func viewDidLoad() {
        super.viewDidLoad()
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
     BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
     BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
     BackBtn.imageView?.applyRTLFlip(Language == "ar")
        uiConficration()
        setupPageViewController()
        loadPages([page1, page2])
        disableSwipeGesture()
        // Set the initial page
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    func uiConficration(){
        BackBtn.setTitle(titleLbl, for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        let segmentItems = [button1, button2]
        segmentController.removeAllSegments()
        for (index, item) in segmentItems.enumerated() {
            segmentController.insertSegment(withTitle: item, at: index, animated: false)
            }

        segmentController.selectedSegmentIndex = 0
    }
    private func setupPageViewController() {
        // Initialize the page view controller
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self

        // Embed the page view controller in the container view (presentView)
        addChild(pageViewController)
        presentView.addSubview(pageViewController.view)
        
        // Constrain the page view controller to fill the container view
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: presentView.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: presentView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: presentView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: presentView.bottomAnchor)
        ])
        
        pageViewController.didMove(toParent: self)
    }
//    func gradientcolours(button : UIButton,colours : [CGColor]){
//        
//        
//        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
//               
//               // Create and configure the gradient layer
//               let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = colours
//               gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
//               gradientLayer.frame = button.bounds
//               gradientLayer.cornerRadius = button.layer.cornerRadius
//               
//               // Insert the gradient layer into the button's layer
//               button.layer.insertSublayer(gradientLayer, at: 0)
//        
//    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func switchController(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex

            guard selectedIndex >= 0 && selectedIndex < pages.count else {
                print("Index out of bounds")
                return
            }

            let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
            let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse

            pageViewController.setViewControllers([pages[selectedIndex]], direction: direction, animated: true, completion: nil)
    }
    
    func loadPages(_ CV:[UIViewController]) {
        // Initialize view controllers for pages

        if let page2 = CV[1] as? NoticeBoardVc {
            page2.delegate = self
         }
            pages = CV

    }

    // MARK: - SelectedDelegate Method
    func SelectedVC(index: Int) {
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }
        
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }

    // MARK: - UIPageViewController Data Source Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }
    
    // MARK: - Page Indicator (Optional)
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    private func disableSwipeGesture() {
         for view in pageViewController.view.subviews {
             if let scrollView = view as? UIScrollView {
                 scrollView.isScrollEnabled = false // Disable swipe gestures
             }
         }
     }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return 0
        }
        return currentIndex
    }
    func select(Title:String,Description:String,Images:[UIImage],pdf:String) {
        if let page1 = pages[0] as? SenderNoticeBoardVC {
//            page1.selectedImages = Img
            page1.Title = Title
            page1.desript = Description
            print(Description)
            guard 1 >= 0 else {
                print("Index out of bounds")
                return
            }
            let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
            let direction: UIPageViewController.NavigationDirection = 1 > currentIndex ? .forward : .reverse

            pageViewController.setViewControllers([pages[0]], direction: direction, animated: true, completion: nil)
         }
    }
}
