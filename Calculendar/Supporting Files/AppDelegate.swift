import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate {

    var window: UIWindow?
    var interstitial: GADInterstitialAd?  //  전면광고용 변수
    var launchScreenView: UIView?
    private var purchaseManager = PurchaseManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("\n + + + + + + + + + + + + + + + + + + + + + + willFinishLaunchingWithOptions + + + + + + + + + + + + + + + + + + + + + + ")
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        print("AdRemoval = \(UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval))")
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        
        var firstLaunchTime = UserDefaults.standard.object(forKey: SettingsKeys.firstLaunchTime) as? Date
        var lastLaunchTime = UserDefaults.standard.object(forKey: SettingsKeys.lastLaunchTime) as? Date
        
        print("firstLaunchTime = \(String(describing: firstLaunchTime))")
        print("lastLaunchTime = \(String(describing: lastLaunchTime))")
        
        if (firstLaunchTime == nil) {
            firstLaunchTime = Date()
            UserDefaults.standard.setValue(firstLaunchTime, forKey: SettingsKeys.firstLaunchTime)
            print("firstLaunchTime = \(String(describing: firstLaunchTime))")
            
            //  화폐단위 만원:0 / 천원:1 / 원:2  (첫 실행이라면 기본값 원[2]을 기본 화폐단위로 만들어줌 아랫줄 없으면 만원[0] 이 기본값 될 것)
            UserDefaults.standard.setValue(2, forKey: SettingsKeys.moneyUnit)
        }
        
        if (lastLaunchTime == nil) {
            lastLaunchTime = Date()
            UserDefaults.standard.setValue(lastLaunchTime, forKey: SettingsKeys.lastLaunchTime)
            print("lastLaunchTime = \(String(describing: lastLaunchTime))")
        }
        
        if UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval)   // || Date(timeInterval: 60 * 60 * 2, since: firstLaunchTime!) >= Date()
        {
            //  광고제거 구매했다면 광고 실행 안함
        } else {
            requestIDFA()   //  iOS15  이후 실행 안됨 (앱이 완전히 활성화된 이후 실행 가능함
            
            if Date(timeInterval: 60 * 60 * 24 * 5, since: firstLaunchTime!) > Date() ||    //  첫 실행 후 5일 이내?
                Date(timeInterval: 60 * 60 * 24 * 5, since: lastLaunchTime!) < Date() {     //  마지막 실행 후 5일 이상 경과?
                //  앱 시작 전면광고 안함
            } else {
                if UserDefaults.standard.bool(forKey: SettingsKeys.fakeLaunchScreen) {
                    fakeLaunchScreenView()
                }
                loadGADInterstitialAd()
            }
        }
        
        lastLaunchTime = Date()     //  지난 lastLaunchTime 확인 후 새로 입력
        UserDefaults.standard.setValue(lastLaunchTime, forKey: SettingsKeys.lastLaunchTime)
        
        Task {
            print("\nAPPDelegate - will - purchaseManager.updatePurchasedProducts() \n")
            await purchaseManager.updatePurchasedProducts()
            print("\nAPPDelegate - did - purchaseManager.updatePurchasedProducts() \n")
        }
        
        return true
    }
    
    func requestIDFA() {
        if #available(iOS 14, *) {
            self.printTrackingAuthorizationStatus()
            self.printIDFA("(설정 전)")
        }
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .authorized:
                    self.printTrackingAuthorizationStatus()
                    self.printIDFA("(설정 후)")
                case .denied:
                    self.printTrackingAuthorizationStatus()
                    self.printIDFA("(설정 후)")
                case .notDetermined:
                    self.printTrackingAuthorizationStatus()
                    self.printIDFA("(설정 후)")
                case .restricted:
                    self.printTrackingAuthorizationStatus()
                    self.printIDFA("(설정 후)")
                default:
                    print("default")
                }
            }
        } else {
            print("iOS 14.5 이상이 아닙니다")
        }
    }
    
    func printTrackingAuthorizationStatus() {
        if #available(iOS 14, *) {
            let state = ATTrackingManager.trackingAuthorizationStatus.rawValue
            switch state {
            case 0: print("\n.notDetermined")
            case 1: print("\n.restricted")
            case 2: print("\n.denied")
            case 3: print("\n.authorized")
            default: print("No Value \(state)")
            }
        }
    }
    
    func printIDFA(_ string : String) {
        print("IDFA\(string) : \(ASIdentifierManager.shared().advertisingIdentifier.uuidString)\n")
    }
    
    // 전면광고 로드
    func loadGADInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-5095960781666456/5144120126", request: request, completionHandler: { [self] ad, error in
            if let error = error {
                //  로드 에러 시
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                launchScreenView?.removeFromSuperview()
                return
            }
            //  로드 완료 시
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            print(" - - - - - - 전면광고 로드 완로 - - - - - - ")
            guard let viewController = window?.rootViewController else { return }
            interstitial?.present(fromRootViewController: viewController)
        })
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        launchScreenView?.removeFromSuperview()
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
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        requestIDFA()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

