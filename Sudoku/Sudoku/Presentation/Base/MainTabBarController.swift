//
//  MainTabBarController.swift
//  Sudoku
//
//  Created by Natalia Pashkova on 26.04.2023.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupTabBar()
    }
    
    func setupTabBar() {
        let mainViewController = createNavigationController(vc: MainViewController(), titleName: "Main".localized(), imageName: "house")
        let dailyChallengesViewController = createNavigationController(vc: DailyChallengesViewController(), titleName: "Daily Challenge".localized(), imageName: "calendar")
        let statisticsViewController = createNavigationController(vc: StatisticsViewController(), titleName: "Statistics".localized(), imageName: "chart.bar")
        viewControllers = [mainViewController, dailyChallengesViewController, statisticsViewController]
    }
    
    func createNavigationController(vc: UIViewController, titleName: String, imageName: String) -> UINavigationController{
        let item = UITabBarItem(title: titleName,
                                image: UIImage(systemName: imageName)?.withAlignmentRectInsets(.zero),
                                tag: 0)
        item.titlePositionAdjustment = .zero
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        return navController
    }

}
