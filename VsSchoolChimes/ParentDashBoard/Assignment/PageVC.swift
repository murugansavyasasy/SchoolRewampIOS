//
//  PageVC.swift
//  VsSchoolChimes
//
//  Created by chandhru on 21/11/24.
//
import UIKit

protocol DidSelectDelegate: AnyObject {
    func select(index: Int, value: String?, Img: [String], Pdf: String?, text: String?, type: String)
}

class PageVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    // MARK: - IBOutlets
    @IBOutlet weak var presentView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    // MARK: - Properties
    private var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.text = studentDetails?.name
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        if let first = pages.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: true)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view
            .applyGradient(
                colors: [Colornames.gradientgreen,Colornames.gradientBlue],
                startPoint: CGPoint(x: 1, y: 0.2),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
    }
    // MARK: - Setup Page View Controller
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self

        // Disable swipe
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
        for gesture in pageViewController.gestureRecognizers {
            gesture.isEnabled = false
        }

        // Add as child
        addChild(pageViewController)
        pageViewController.view.frame = presentView.bounds
        presentView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }

    // MARK: - Public Configure
    func configure(with viewControllers: [UIViewController]) {
        self.pages = viewControllers
    }

    // MARK: - Segment Control
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard index >= 0 && index < pages.count else { return }

        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true)
    }

    // MARK: - Back Action
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation Helpers
    func goToPage(index: Int) {
        guard index >= 0 && index < pages.count else { return }

        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true)
    }

    func backtohome() {
        goToPage(index: 0)
    }

    // MARK: - Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }

    // HIDE Page Indicator (dot control)
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 0 // Set to 0 to HIDE dot indicators
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

