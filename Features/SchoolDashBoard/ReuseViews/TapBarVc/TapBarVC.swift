//
//  TapBarVC.swift
//  VsSchoolChimes
//
//  Created by admin on 30/10/24.
//
import UIKit

protocol ProfileSwitchDelegate {
    func switchProfile()
}

@available(iOS 14.0, *)
class TapBarVC: UIViewController, UITabBarDelegate, BaktoHome, ProfileSwitchDelegate, backNavigation {
    func backtohome(type: String) {
        setupTabBar()
        setupContainerView()
        if login_astype == 1 {
            selectViewController(firstVCNav)
        } else if login_astype == 2 {
            selectViewController(parentVCNav)
        }
    }
    
    
    func back(logout: Bool, _ viewController: UIViewController) {
        if logout {
            UserDefaults.standard.set(true, forKey: "Logout")
            let vc = LogoutViewController()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false)
            return
        }
        if viewController is CustomDashboard || viewController is CustomParentDashboardVC {
            tabBar.selectedItem = tabBar.items?[0]
            handleHomeTabSelection()
            return

        } else if viewController is HolidayVC {
            tabBar.selectedItem = tabBar.items?[1]
            selectViewController(secondVCNav)
            return

        } else if viewController is SettingsViewController {
            tabBar.selectedItem = tabBar.items?[2]
            selectViewController(thirdVCNav)
            return

        } else if viewController is UpdateProfileVC {
            tabBar.selectedItem = tabBar.items?[3]
            selectViewController(fourthVCNav)
            return
        }
        if type(of: viewController) == UIViewController.self {
            if let presentedVC = presentedViewController {
                presentedVC.dismiss(animated: false) { [weak self] in
                    self?.presentPriorityVC()
                }
            } else {
                presentPriorityVC()
            }
        }
    }

    private func presentPriorityVC() {
        let vc = PriorityVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    func switchProfile() {
        selectViewController(fourthVCNav)
        tabBar.selectedItem = tabBar.items?[3]
    }
    
    
    private let tabBar = UITabBar()
    private var containerView = UIView()
    var languages: String!
    var login_astype: Int?
    var languageCode: String!
    var comfromNotification : Bool = false
    var messageId : String?
    var menuId : String?
    var profile: Bool = false
    // MARK: - Navigation Wrapped Controllers
    private lazy var firstVCNav = UINavigationController(
        rootViewController: CustomDashboard(
            comefromNotification: comfromNotification,
            menuId: menuId ?? "",
            messageId: messageId ?? ""
        )
    )
    private lazy var parentVCNav = UINavigationController(
        rootViewController: CustomParentDashboardVC(
            comefromNotification: comfromNotification,
            menuId: menuId ?? "", messageId: messageId ?? ""
        )
    )
    //private lazy var secondVCNav = UINavigationController(rootViewController: HelpVc())
    private lazy var secondVCNav = UINavigationController(rootViewController: HolidayVC())
    private lazy var thirdVCNav = UINavigationController(rootViewController: SettingsViewController())
    private lazy var fourthVCNav = UINavigationController(rootViewController: UpdateProfileVC(isStudent: login_astype == 2))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupInitialViewController()
    }
    
    private func setupUI() {
        setupTabBar()
        setupContainerView()
    }
    
 
    
    private func setupInitialViewController() {
        if login_astype == 2 {
            selectViewController(parentVCNav)
            
            tabBar.selectedItem = tabBar.items?[0]
        } else if login_astype == 1 {
            selectViewController(firstVCNav)
            tabBar.selectedItem = tabBar.items?[0]
        }
    }
    
   
    
    private func setupTabBar() {
        let firstItem = UITabBarItem(
            title: StringsName.Home.translated(),
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        let secondItem = UITabBarItem(
            title: AttendanceString.holidays.translated(),
            image: UIImage(systemName: "calendar"),
            tag: 1
        )
        let thirdItem = UITabBarItem(
            title: StringsName.Settings.translated(),
            image: UIImage(systemName: "gearshape.fill"),
            tag: 2
        )
        let fourthItem = UITabBarItem(
            title: StringsName.Profile.translated(),
            image: UIImage(systemName: "person.crop.circle"),
            tag: 3
        )
        
        tabBar.items = [firstItem, secondItem, thirdItem, fourthItem]
        tabBar.delegate = self
        tabBar.selectedItem = firstItem
        view.addSubview(tabBar)
        configureTabBarAppearance()
        setupTabBarConstraints()
    }
    
    private func configureTabBarAppearance() {
        tabBar.tintColor = UIColor.backGroundClr
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.backGroundClr
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.backGroundClr]
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        let font = UIFont.systemFont(ofSize: 14)
        UITabBarItem.appearance().setTitleTextAttributes([.font: font], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font: font], for: .selected)
    }
    
    
    private func setupTabBarConstraints() {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
    }
    
    private func selectViewController(_ navController: UINavigationController) {
        removeAllChildViewControllers()
        configureTopViewController(navController)
        addChildViewController(navController)
    }
    
    private func removeAllChildViewControllers() {
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    private func configureTopViewController(_ navController: UINavigationController) {
        guard let topVC = navController.viewControllers.first else { return }
        
        if let settingsVC = topVC as? SettingsViewController{
            settingsVC.delegate = self
            settingsVC.hideBack = true
            settingsVC.passVale = login_astype ?? 0
        } else if let profileVC = topVC as? CustomParentDashboardVC, login_astype == 2 {
            profileVC.loginAsType = login_astype
            profileVC.delegate = self
        } else if let dashboardVC = topVC as? CustomDashboard {
            dashboardVC.delegate = self
            dashboardVC.loginAsType = login_astype
        } else if let holidayVC = topVC as? HolidayVC {
            holidayVC.passValue = login_astype ?? 0
        } else if let schoolVC = topVC as? UpdateProfileVC {
            schoolVC.hideBack = true
        }else if let help = topVC as? HelpVc{
            help.hideBack = true
        }
    }
    
    private func addChildViewController(_ navController: UINavigationController) {
        addChild(navController)
        navController.view.frame = containerView.bounds
        navController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(navController.view)
        navController.didMove(toParent: self)
    }
    
    // MARK: - UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            handleHomeTabSelection()
        case 1:
            selectViewController(secondVCNav)
        case 2:
            selectViewController(thirdVCNav)
        case 3:
            selectViewController(fourthVCNav)
        default:
            break
        }
    }
    
    private func handleHomeTabSelection() {
        if login_astype == 1 {
            selectViewController(firstVCNav)
        } else if login_astype == 2 {
            selectViewController(parentVCNav)
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

