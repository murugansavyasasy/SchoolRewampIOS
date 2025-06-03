//
//  NavigationVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

class NavigationVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource{
  
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var presentView: UIView! // Container view to embed the page view controller
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    
    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = UIViewController()
    var page2 = UIViewController()
    var titleLbl = ""
    var button1 = "Create".translated()
    var button2 = "History".translated()
   // var LeaveRequest:LeaveRequest?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiConficration()
        setupPageViewController()
        loadPages([page1, page2])
        disableSwipeGesture()
        backBtn.applyBackButton()
       
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    func uiConficration(){
        backBtn.setTitle(titleLbl, for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
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
    func gradientcolours(button : UIButton,colours : [CGColor]){
        
        
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
               
               // Create and configure the gradient layer
               let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
               gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
               gradientLayer.frame = button.bounds
               gradientLayer.cornerRadius = button.layer.cornerRadius
               
               // Insert the gradient layer into the button's layer
               button.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func SelectionController(_ sender: UIButton) {
        
        
        guard sender.tag >= 0 && sender.tag < pages.count else {
            print("Index out of bounds")
            return
        }
        
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = sender.tag > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[sender.tag]], direction: direction, animated: true, completion: nil)
    }
    
    
    func loadPages(_ CV:[UIViewController]) {
        if let page2 = CV[1] as? LeveHistoryVC {
            //page2.navigatedelegate = self
         }
       
            pages = CV

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

}
