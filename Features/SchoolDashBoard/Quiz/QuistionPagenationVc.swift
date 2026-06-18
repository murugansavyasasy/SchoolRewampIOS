//
//  QuistionPagenationVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 24/08/25.
//

import UIKit

class QuistionPagenationVc: UIViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate,SelectNotice, ReportsQuizDelegate {
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var reportsLb: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var presentView: UIView!
    @IBOutlet weak var toolbarTitle: UILabel!
    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = UIViewController()
    var page2 = UIViewController()
    var titleLbl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbarTitle.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName,secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
//        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
//        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft : .forceLeftToRight
//        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right : .left
//        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        setupPageViewController()
        loadPages([page1, page2])
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = false  // disable swipe
            }
            if let pageControl = view as? UIPageControl {
                pageControl.isHidden = true  // hide dots
            }}
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
    
    @IBAction func segment(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }
        updateTabUI(for: index)
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        if index == 0 && currentIndex != 0 {
            if let senderVC = pages.first as? SenderQuizVc {
                senderVC.editQuiz = nil
                senderVC.isReset = true
            }
        }else if index == 1{
            createBtn.setTitle("Create".translated(), for: .normal)
        }
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
    
    func updateTabUI(for index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.createLbl.backgroundColor = index == 0 ? .backGroundClr : .systemGray5
            self.reportsLb.backgroundColor = index == 0 ? .systemGray5 : .backGroundClr
            self.reportsBtn.tintColor = index == 0 ? .black : .backGroundClr
            self.createBtn.tintColor = index == 1 ? .black : .backGroundClr
        }
    }
    func loadPages(_ CV: [UIViewController]) {
        if #available(iOS 14.0, *) {
            if let page2 = CV[1] as? ReportsQuizVc {
                page2.selectNotice = self
                page2.delegate = self
            }
        }
        pages = CV
    }
    
    func didSelectQuizForEdit(quiz: EditQuiz) {
        createBtn.setTitle("Edit".translated(), for: .normal)
        updateTabUI(for: 0)
        if let senderVC = pages.first as? SenderQuizVc {
            senderVC.editQuiz = quiz
            let currentIndex = pageViewController.viewControllers?.first.flatMap{pages.firstIndex(of: $0)} ?? 0
            let direction: UIPageViewController.NavigationDirection = 0 > currentIndex ? .forward : .reverse
            pageViewController.setViewControllers([senderVC],direction: direction,animated: true)
        }
    }
    
    
    func SelectedVC(index: Int) {
        guard index >= 0 && index < pages.count else {
            return
        }
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
    
    // MARK: - UIPageViewController Data Source
    @objc(pageViewController:viewControllerBeforeViewController:) func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    @objc(pageViewController:viewControllerAfterViewController:) func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
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
    func didTapButton(
        title: String,
        content: String,
        items: [FilePath],
        editId editID:String
    ) {
        if #available(iOS 14.0, *) {
            if let page1 = pages.first as? SenderQuizVc{
                updateTabUI(for: 0)
                let currentIndex =  pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
                let direction: UIPageViewController.NavigationDirection = 0 > currentIndex ? .forward : .reverse
                pageViewController.setViewControllers([page1], direction: direction, animated: true, completion: nil)
            }
        }
    }
}
