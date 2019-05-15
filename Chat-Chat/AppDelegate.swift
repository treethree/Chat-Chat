import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let userData =  UserData()
        
        // check if all register information required (name, avatar, color) is filled
        if (userData.hasAllDataFilled) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            let navigationController:UINavigationController = UINavigationController(rootViewController: viewController);
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        return true
    }
}

