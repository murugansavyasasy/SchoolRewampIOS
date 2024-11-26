//
//  PageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

protocol DidSelectDelegate: AnyObject { // Use `AnyObject` for class-only conformance
    func select(index: Int, value: String?)
}

class PageVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, DidSelectDelegate {

    var pages: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate and data source
        self.delegate = self
        self.dataSource = self

        // Load pages
        loadPages()

        // Set the initial page
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }

    func loadPages() {
        // Initialize view controllers from nibs
        let page1 = AssignmentListVC(nibName: "AssignmentListVC", bundle: nil)
        page1.didSelectDelegate = self // Assign delegate

        let page2 = AssigmentViewVC(nibName: "AssigmentViewVC", bundle: nil)
        page2.delegate = self

        // Add pages to the array
        pages = [page1, page2]
    }

    // MARK: - DidSelectDelegate Method

//    func select(index: Int, value: String?) {
//        guard index >= 0 && index < pages.count else { return }
//
//        if let value = value, let targetVC = pages[index] as? BookopenViewController {
//            
//            targetVC.indexno = Int(value) ?? 0 // Pass the value dynamically
//        }
//
//        let direction: UIPageViewController.NavigationDirection = index > (viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0) ? .forward : .reverse
//        setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
//    }
    
    func select(index: Int, value: String?) {
        // Ensure the index is within bounds
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }

        // Check if the target view controller can accept the value
        if let value = value,
           let targetVC = pages[index] as? AssigmentViewVC {
            targetVC.indexno = Int(value) ?? 0 // Safely convert and assign the value
        }

        // Determine navigation direction based on current index
        let currentIndex = viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        // Using UIView.animate to adjust the duration of the transition
        UIView.animate(withDuration: 2.5, animations: {
            // Set the target view controller with the desired animation
            self.setViewControllers([self.pages[index]], direction: direction, animated: true, completion: nil)
        })
    }


    // MARK: - UIPageViewController Data Source Methods

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

    // Optional: Page Indicator
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return 0
        }
        return currentIndex
    }
//    func setViewControllersWithCustomDuration(
//         _ viewControllers: [UIViewController],
//         direction: NavigationDirection,
//         duration: TimeInterval,
//         completion: ((Bool) -> Void)? = nil
//     ) {
//         UIView.animate(withDuration: duration, animations: {
//             self.setViewControllers(viewControllers, direction: direction, animated: true, completion: completion)
//         })
//     }
}
