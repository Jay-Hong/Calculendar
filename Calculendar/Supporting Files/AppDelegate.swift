import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADInterstitialDelegate {

    var window: UIWindow?
    var interstitial: GADInterstitial!  //  전면광고용 변수
    var launchScreenView: UIView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("\nwillFinishLaunchingWithOptions")
        print("firstScreenAd = \(UserDefaults.standard.bool(forKey: SettingsKeys.firstScreenAd))")
        print("AdRemoval = \(UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval))\n")
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval)
//            || UserDefaults.standard.bool(forKey: SettingsKeys.firstScreenAd)
        {
            //  앱 제거 구매 or 광고 한번 보고 닫았으면  광고 실행 안함
        } else {
            interstitial = createAndLoadInterstitial()
            fakeLaunchScreenView()
        }
        
        return true
    }
    
    // 전면광고 로드
    func createAndLoadInterstitial() -> GADInterstitial {
      interstitial = GADInterstitial(adUnitID: "ca-app-pub-5095960781666456/5144120126")
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }

    //  광고로드 완료 시
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("\ninterstitialDidReceiveAd\n")
        guard let viewController = window?.rootViewController else { return }
        interstitial.present(fromRootViewController: viewController)
    }

    //  광고 로드 에러 시
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("\ninterstitial:didFailToReceiveAdWithError: \(error.localizedDescription)\n")
        launchScreenView?.removeFromSuperview()
    }

    //  광고 닫을 시
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("\ninterstitialWillDismissScreen\n")
        launchScreenView?.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: SettingsKeys.firstScreenAd)
    }
    
    func fakeLaunchScreenView() {   // 가짜 로딩화면 뿌려주기 (로드시간 벌기)
        if let view = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()?.view {
            launchScreenView = view
            view.translatesAutoresizingMaskIntoConstraints = false
            if let rootView = window?.rootViewController?.view {
                rootView.addSubview(view)
                var constraints = [NSLayoutConstraint]()
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view])
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view])
                rootView.addConstraints(constraints)
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("\napplicationDidEnterBackground\n")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        print("\napplicationWillEnterForeground")
        print("firstScreenAd = \(UserDefaults.standard.bool(forKey: SettingsKeys.firstScreenAd))")
        print("AdRemoval = \(UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval))\n")
        
//        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval)
//            || UserDefaults.standard.bool(forKey: SettingsKeys.firstScreenAd)  {
//            //  앱 제거 구매 or 하루 중 광고 한번 보고 닫음 or 광고 실행중 이면  광고 실행 안함
//        } else {
//            interstitial = createAndLoadInterstitial()
//            fakeLaunchScreenView()
//        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

