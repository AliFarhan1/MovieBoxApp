import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // إنشاء النافذة الرئيسية
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        // تعيين ViewController كشاشة البداية
        let viewController = ViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        self.window = window
        return true
    }
}
