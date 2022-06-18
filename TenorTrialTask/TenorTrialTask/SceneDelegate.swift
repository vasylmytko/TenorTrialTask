//
//  SceneDelegate.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        
        let viewModel = DefaultGIFsCollectionViewModel()
        let gifsCollectionController = GIFsCollectionViewController(viewModel: viewModel)

        let favouriteController = ViewController()
        favouriteController.view.backgroundColor = .green
        
        let gifsNavigationController = UINavigationController(rootViewController: gifsCollectionController)
        gifsNavigationController.tabBarItem = .init(title: "GIFs", image: nil, tag: 0)
        let favouriteNavigationController = UINavigationController(rootViewController: favouriteController)
        favouriteNavigationController.tabBarItem = .init(title: "Favourites", image: nil, tag: 0)
        
        tabBarController.setViewControllers([gifsNavigationController, favouriteNavigationController], animated: false)
        tabBarController.tabBar.backgroundColor = #colorLiteral(red: 0.1862384677, green: 0.5898670554, blue: 0.9156925678, alpha: 1)
        tabBarController.tabBar.tintColor = .white
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

