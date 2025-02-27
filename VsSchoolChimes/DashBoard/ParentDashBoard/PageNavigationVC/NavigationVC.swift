//
//  NavigationVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
protocol navigateDelegate{
    func navigate(index:Int,leaveRequest:LeaveRequest)
}
class NavigationVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, navigateDelegate{
  
    
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var outerView: UIStackView!
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var createEvent: UIButton!
    @IBOutlet weak var presentView: UIView! // Container view to embed the page view controller
    @IBOutlet weak var TitleHederLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    
    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = UIViewController()
    var page2 = UIViewController()
    var titleLbl = ""
    var button1 = "Create".translated()
    var button2 = "History".translated()
    var LeaveRequest:LeaveRequest?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiConficration()
        setupPageViewController()
        loadPages([page1, page2])
        disableSwipeGesture()
        
        configureButton(
            createEvent,
            title: button1,
            imageName: nil,
            gradientColors:[UIColor.green,UIColor.blue],
            opacity: 0.8, // 70% opacity
            lightenFactor: 0.6// 40% lighter
        )

        createEvent.setTitleColor(.black, for:.normal)
        gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        historyBtn.setTitleColor(.black, for:.normal)
        // Set the initial page
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
        TitleHederLbl.setFont(style: .header, size: FontSize.HeaderSize)
        outerView.layer.cornerRadius = 20
        historyBtn.layer.cornerRadius = 20
        createEvent.layer.cornerRadius = 20
        createEvent.setTitleFont(style: .body, size: FontSize.BodySize)
        historyBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        historyBtn.setTitle(button2, for: .normal)
        createEvent.setTitle(button1, for: .normal)
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
        
        if sender.tag == 0{
            configureButton(
                createEvent,
                title: button1,
                imageName: nil,
                gradientColors:[UIColor.green,UIColor.blue],
                opacity: 0.8, // 70% opacity
                lightenFactor: 0.6// 40% lighter
            )

            createEvent.setTitleColor(.black, for:.normal)
            gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            historyBtn.setTitleColor(.black, for:.normal)
        }else{
            gradientcolours(button: createEvent,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
            createEvent.setTitleColor(.black, for:.normal)
            configureButton(
                historyBtn,
                title: button2,
                imageName: nil,
                gradientColors:[UIColor.green,UIColor.blue],
                opacity: 0.8, // 70% opacity
                lightenFactor: 0.6// 40% lighter
            )
            historyBtn.setTitleColor(.black, for:.normal)
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
        if let page2 = CV[1] as? LeveHistoryVC {
            page2.navigatedelegate = self
         }
       
            pages = CV

    }
    func navigate(index: Int,leaveRequest:LeaveRequest) {
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }
        if #available(iOS 14.0, *) {
            if let page1 = pages[0] as? LeveCreateVC {
                backBtn.setTitle("Edit Leave Request", for: .normal)
                page1.LeaveRequest = leaveRequest
            }
        } 
        gradientcolours(button: createEvent,colours: [UIColor.parentClr.cgColor,UIColor.priority.cgColor])
        createEvent.setTitleColor(.white, for:.normal)
        gradientcolours(button: historyBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        historyBtn.setTitleColor(.black, for:.normal)
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
    
    func configureButton(
        _ button: UIButton,
        title: String,
        imageName: UIImage?,
        gradientColors: [UIColor],
        cornerRadius: CGFloat = 20,
        imageSize: CGSize = CGSize(width: 40, height: 40),
        spacing: CGFloat = 8.0,
        opacity: CGFloat = 0.5, // Opacity for the gradient
        lightenFactor: CGFloat = 0.3 // Factor to lighten colors (0 = no change, 1 = full white)
    ) {
        // Set corner radius
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        
        // Adjust colors for lightening and opacity
        let adjustedColors = gradientColors.map { color in
            color.blendedWithWhite(factor: lightenFactor).withAlphaComponent(opacity)
        }
        
        // Apply gradient
        button.applyGradient(
            colors: adjustedColors,
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        button.setTitleFont(style: .body, size: FontSize.BodySize)
        
        // Set title and image
        button.setTitle(title, for: .normal)
        if let image = imageName {
            let resizedImage = UIGraphicsImageRenderer(size: imageSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: imageSize))
            }
            button.setImage(resizedImage, for: .normal)
        }
        
        // Align image and title
        button.contentHorizontalAlignment = .center  // Ensure horizontal alignment
        if let imageSize = button.imageView?.frame.size,
           let titleSize = button.titleLabel?.intrinsicContentSize {
            let totalHeight = imageSize.height + titleSize.height + spacing
            
            button.imageEdgeInsets = UIEdgeInsets(
                top: -(totalHeight - imageSize.height),  // Move image to the top
                left: 0,
                bottom: 0,
                right: -titleSize.width // Center align horizontally
            )
            
            button.titleEdgeInsets = UIEdgeInsets(
                top: 0,  // No padding at the top
                left: -imageSize.width,  // Center align horizontally
                bottom: -(totalHeight - titleSize.height),  // Move title below the image
                right: 0
            )
            
            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: spacing,
                right: 0
            )
        }
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
