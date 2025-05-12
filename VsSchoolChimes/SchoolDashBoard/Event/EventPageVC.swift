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
    @IBOutlet weak var outerView: UIStackView!
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var createEvent: UIButton!
    @IBOutlet weak var presentView: UIView! // Container view to embed the page view controller
    
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
//        pages = [page1, page2]
        loadPages([page1, page2])
        disableSwipeGesture()
        gradientcolours(button: createEvent,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        createEvent.setTitleColor(.white, for:.normal)
        gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        historyBtn.setTitleColor(.black, for:.normal)
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
      
        outerView.layer.cornerRadius = 20
        historyBtn.layer.cornerRadius = 20
        createEvent.layer.cornerRadius = 20
        BackBtn.setTitle(titleLbl, for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        createEvent.setTitleFont(style: .body, size: FontSize.BodySize)
        historyBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        historyBtn.setTitle(button2, for: .normal)
        createEvent.setTitle(button1, for: .normal)
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
        
        if sender.tag == 0{
            gradientcolours(button: createEvent,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
            createEvent.setTitleColor(.white, for:.normal)
            gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            historyBtn.setTitleColor(.black, for:.normal)
        }else{
            gradientcolours(button: createEvent,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            createEvent.setTitleColor(.black, for:.normal)
            gradientcolours(button: historyBtn,colours:[UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
            historyBtn.setTitleColor(.white, for:.normal)
        }
        
        guard sender.tag >= 0 && sender.tag < pages.count else {
            print("Index out of bounds")
            return
        }
        
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = sender.tag > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[sender.tag]], direction: direction, animated: true, completion: nil)
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
//        if let page1 = pages[0] as? SenderNoticeBoardVC {
////            page1.selectedImages = Img
//            page1.Title = Title
//            page1.desript = Description
//            print(Description)
//            guard 1 >= 0 else {
//                print("Index out of bounds")
//                return
//            }
//            gradientcolours(button: createEvent,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
//            createEvent.setTitleColor(.white, for:.normal)
//            gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
//            historyBtn.setTitleColor(.black, for:.normal)
//            let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
//            let direction: UIPageViewController.NavigationDirection = 1 > currentIndex ? .forward : .reverse
//
//            pageViewController.setViewControllers([pages[0]], direction: direction, animated: true, completion: nil)
//         }
    }
}
