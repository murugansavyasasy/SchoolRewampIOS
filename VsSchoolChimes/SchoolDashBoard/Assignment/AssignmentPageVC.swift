//
//  AssignmentPageVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit

@available(iOS 14.0, *)
class AssignmentPageVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var presentView: UIView!

    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = SenderAssignmentTextViewController()
    var page2 = AssignmentReport()
    var titleLbl = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft : .forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right : .left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        uiConficration()
        setupPageViewController()
        loadPages([page1, page2])
        disableSwipeGesture()

        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }

    func uiConficration() {
//        BackBtn.setTitle(titleLbl, for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self

        addChild(pageViewController)
        presentView.addSubview(pageViewController.view)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: presentView.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: presentView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: presentView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: presentView.bottomAnchor)
        ])

        pageViewController.didMove(toParent: self)
    }

    
    func gradientcolours(button: UIButton, colours: [CGColor]) {
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius

        button.layer.insertSublayer(gradientLayer, at: 0)
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func segment(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }

        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }

    func loadPages(_ CV: [UIViewController]) {

            pages = CV
    }

    func SelectedVC(index: Int) {
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }

        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }

    // MARK: - UIPageViewController Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }

    private func disableSwipeGesture() {
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return 0
        }
        return currentIndex
 
    }
   
    
}
