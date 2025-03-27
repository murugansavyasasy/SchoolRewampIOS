//
//  TapBarVC.swift
//  VsSchoolChimes
//
//  Created by admin on 30/10/24.
//

import UIKit

@available(iOS 14.0, *)
class TapBarVC: UIViewController,UITabBarDelegate, BaktoHome {
    func backtohome() {
        setupTabBar()
        setupContainerView()
        if login_astype == 1{
            
            firstVC.getValue = login_astype
            selectViewController(firstVC)
            
        }else if login_astype == 2{
            Parent.getValue = login_astype
            selectViewController(Parent)
        }
    }
    
    
    
    private let tabBar = UITabBar()
    private var containerView = UIView()
    private lazy var firstVC = SchoolDashboardVc()
    private lazy var Parent = ParentDashboardVc()
    private lazy var secondVC = HelpVc()
    private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = ProfileViewController()
    var languages : String!
    var login_astype : Int?
    var languageCode : String!
    var profile:Bool = false
    var childDetail:ChildDetails?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTabBar()
        setupContainerView()
    }
    
    private func setupTabBar() {
        
        // Configure the tab bar items
        let firstItem = UITabBarItem(title: StringsName.Home.translated(), image: UIImage(systemName: "house.fill"), tag: 0)
        let secondItem = UITabBarItem(title: StringsName.Help.translated(), image: UIImage(systemName: "questionmark.circle.fill"), tag: 1)
        let thirdItem = UITabBarItem(title : StringsName.Settings.translated(), image: UIImage(systemName: "gearshape.fill"), tag: 2)
        let fourthItem = UITabBarItem(title: StringsName.Profile.translated(), image: UIImage(systemName: "person.crop.circle"), tag: 3)
        // Create the gradient color for tab bar
     
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .black.withAlphaComponent(0.55)
        tabBar.items = [firstItem, secondItem, thirdItem, fourthItem]
        tabBar.delegate = self
        tabBar.selectedItem = firstItem
        view.addSubview(tabBar)
        
        // Set text attributes for all states
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .selected)
        
        // Layout the tab bar
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor
                                            )])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if login_astype == 2{
            Parent.getValue = login_astype
            selectViewController(Parent)
            
            applyGradientToTabBar(tabBar, colors: [Colornames.gradientBlue.blendedWithWhiteColour(factor: 0.3), Colornames.gradientgreen.blendedWithWhiteColour(factor: 0.3)])
            
        }else if login_astype == 1{
            
            firstVC.getValue = login_astype
            selectViewController(firstVC)
            
            applyGradientToTabBar(tabBar, colors: [Colornames.stafGradient, Colornames.stafGradient1])
            
            tabBar.tintColor = .white
        }
    }
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor) // Correct alignment
        ])

    }
    
    private func selectViewController(_ viewController: UIViewController) {
        // Remove all existing child view controllers
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        // Ensure `hidesBottomBarWhenPushed` is false
        viewController.hidesBottomBarWhenPushed = false

        // Apply gradient if necessary
        if let settingsVC = viewController as? SettingsViewController, login_astype == 2 {
            settingsVC.delegate = self
            settingsVC.passVale = login_astype ?? 0
            
        } else if let profileVC = viewController as? ProfileViewController, login_astype == 2 {
            profileVC.passvalue = login_astype ?? 0

        }else if let profileVC = viewController as? ParentDashboardVc, login_astype == 2 {
            profileVC.getValue = login_astype
            profileVC.ChildDetail = childDetail
            
        }else if let HelpVc = viewController as? HelpVc, login_astype == 2 {
            HelpVc.passVale = login_astype ?? 0
            
        }

        // Add the new child view controller
        addChild(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    // Handle tab bar item selection with animation
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag {
        case 0:
            if login_astype == 1{
                selectViewController(firstVC)
                firstVC.bottomCv.reloadData()
                
            }else if login_astype == 2{
                
                selectViewController(Parent)
                Parent.bottomCv.reloadData()
            }
            
        case 1:
            selectViewController(secondVC)
        case 2:
            selectViewController(thirdVC)
            
        case 3:
            selectViewController(fourthVC)
        default:
            break
        }
    }
    
    func applyGradientToTabBar(_ tabBar: UITabBar, colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        let width = UIScreen.main.bounds.width
        let height: CGFloat = 80 // Adjust based on tab bar height

        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5) // Start from the right
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)   // End at the left

        // Remove any existing gradient layers to prevent overlapping
        tabBar.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // Insert the gradient at the bottom layer to ensure it's behind other content
        tabBar.layer.insertSublayer(gradientLayer, at: 0)
    }
}
extension UIColor {
    // Convert hex string to UIColor
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
