//
//  SceneDelegate.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
    
    private func makeRootViewController() -> UIViewController {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(
            [makeSearchGIFsViewContoller(), makeFavouritesViewController()],
            animated: false
        )
        tabBarController.tabBar.tintColor = .systemBlue
        tabBarController.tabBar.unselectedItemTintColor = .gray
        return tabBarController
    }

    private func makeSearchGIFsViewContoller() -> UIViewController {
        let viewModel = DefaultGIFsCollectionViewModel()
        let controller = GIFsCollectionViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = .search
        return navigationController
    }
    
    private func makeFavouritesViewController() -> UIViewController {
        let viewModel = DefaultFavouritesViewModel(fetchedResultsController: .makeGIFs())
        let controller = FavouritesViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = .favourites
        return navigationController
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
    }
}

extension UITabBarItem {
    static let favourites: UITabBarItem = .init(
        title: "Favourites",
        image: UIImage(systemName: "star.fill"),
        tag: 0
    )
    
    static let search: UITabBarItem = .init(
        title: "Search",
        image: UIImage(systemName: "magnifyingglass"),
        tag: 0
    )
}

extension NSFetchedResultsController where ResultType == GifMO {
    static func makeGIFs() -> NSFetchedResultsController<GifMO> {
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        let fetchRequest: NSFetchRequest<GifMO> = GifMO.fetchRequest()
        fetchRequest.sortDescriptors = [sortDescriptor]
        return GIFFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: DefaultCoreDataManager.shared.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
