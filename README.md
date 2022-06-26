# TenorTrialTask

### Structure
Project is split into three modules (folders): Domain, Data Access, Presentation. Also there is Composition Root module which is responsible for linking them all together.

#### Domain
Module contains entities, use cases that are isolated from other modules.

#### Data Access
Responsible for fetching data from endpoints and local storages.

#### Presentation
Contains all the code related to UI. The MVVM architecture is used for binding views with the view models.

#### Composition Root
All the logic related to linking modules is located in SceneDelegate because of the small number of screens in the project.

### Application
The application consists of two screens "Search" and "Favourites" which are embedded in UITabBarController. Tenor API is used for fetching gifs. Core Data is used for saving favourite gifs.

### Third party libraries

#### [CombineCocoa](https://github.com/CombineCommunity/CombineCocoa.git)
Used for binding UIKit components with Combine Publishers. 

#### [CombineExt](https://github.com/CombineCommunity/CombineExt.git)
Provides additional operators and helpers to Combine publishers that are not provide by Apple.

#### [SDWebImage](https://github.com/SDWebImage/SDWebImage.git)
Used for loading and displaying gifs.

### Tests
Project contains unit tests for PaginatedFetchGIFsUseCase component.
