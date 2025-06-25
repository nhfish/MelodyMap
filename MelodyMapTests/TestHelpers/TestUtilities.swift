import Foundation
import UIKit

struct TestUtilities {
    static func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    static func setupUserDefaults(with data: [String: Any]) {
        for (key, value) in data {
            UserDefaults.standard.set(value, forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func waitForAsyncOperation(timeout: TimeInterval = 1.0, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: completion)
    }
    
    static func createMockViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.view = UIView()
        return viewController
    }
    
    static func createMockWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = createMockViewController()
        window.makeKeyAndVisible()
        return window
    }
} 