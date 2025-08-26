//
//  AssignmentPageVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//
import UIKit
@available(iOS 14.0, *)
class AssignmentPageVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, EditObjectDelegate {

    func editDta(edit: Any?) {
        guard !pages.isEmpty else { return }

        var buttonTitle = "Edit"
        var pageToShowIndex = 0

        if let notice = edit as? Report,
           let senderVC = pages[safe: 0] as? SenderAssignmentTextViewController {
            senderVC.fetchData(notice: notice)
        } else if edit == nil {
            buttonTitle = "Create"
            pageToShowIndex = 1
            if let senderVC = pages[safe: 1] as? AssignmentReport {
                 senderVC.getAssigment()
            }
        }

        createBtn.setTitle(buttonTitle, for: .normal)

        let schoolName = UserDefaultFileManager.get_staff_Details()?.school_name ?? ""
//        if buttonTitle == "Create" {
//            BackBtn.configureAsBackButton(firstLine: "", secondLine: schoolName)
//        } else {
//            BackBtn.configureAsBackButton(firstLine: "EditNoticeBoard", secondLine: schoolName)
//        }

        let currentIndex = pageViewController.viewControllers?.first
            .flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = (currentIndex > pageToShowIndex) ? .reverse : .forward

        updateTabUI(for: pageToShowIndex)
        pageViewController.setViewControllers([pages[pageToShowIndex]], direction: direction, animated: true)
    }

    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var reportsLb: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var presentView: UIView!
    @IBOutlet weak var searcchBtn: UIButton!

    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = SenderAssignmentTextViewController()
    var page2 = AssignmentReport()
    var titleLblText = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = language == "ar" ? .forceRightToLeft : .forceLeftToRight
        BackBtn.contentHorizontalAlignment = language == "ar" ? .right : .left
        BackBtn.imageView?.applyRTLFlip(language == "ar")

        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName,
                                      secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")

        uiConfiguration()
        setupPageViewController()
        loadPages([page1, page2])
        disableSwipeGesture()

        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true)
        }
    }



    func uiConfiguration() {
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
    }

    func updateTabUI(for index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.searcchBtn.isHidden = index == 0
            self.createLbl.backgroundColor = index == 0 ? UIColor.parentClr : .clear
            self.reportsLb.backgroundColor = index == 0 ? .clear : UIColor.parentClr
            self.reportsBtn.tintColor = index == 0 ? .black : UIColor.parentClr
            self.createBtn.tintColor = index == 1 ? .black : UIColor.parentClr
        }
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
        button.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

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

    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        if pages.indices.contains(1), let senderVC = pages[1] as? AssignmentReport {
            senderVC.searchHide(hide: sender.isSelected)
        }
    }

    @IBAction func switchController(_ sender: UIButton) {
        let selectedIndex = sender.tag
        guard pages.indices.contains(selectedIndex) else { return }

        let currentIndex = pageViewController.viewControllers?.first
            .flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse

        updateTabUI(for: selectedIndex)
        pageViewController.setViewControllers([pages[selectedIndex]], direction: direction, animated: true)
    }

    @IBAction func segment(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard pages.indices.contains(index) else { return }

        let currentIndex = pageViewController.viewControllers?.first
            .flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true)
    }

    func loadPages(_ CV: [UIViewController]) {
        pages = CV
        if let historyVC = pages[safe: 1] as? AssignmentReport {
            historyVC.delegate = self
        }
        if let historyVC = pages[safe: 0] as? SenderAssignmentTextViewController {
            historyVC.delegate = self
        }
    }

    func SelectedVC(index: Int) {
        guard pages.indices.contains(index) else { return }

        let currentIndex = pageViewController.viewControllers?.first
            .flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true)
    }

    // MARK: - Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }

    private func disableSwipeGesture() {
        pageViewController.view.subviews
            .compactMap { $0 as? UIScrollView }
            .forEach { $0.isScrollEnabled = false }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return 0
        }
        return currentIndex
    }
}
