import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var purchaseActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var restoreActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var subscription_DetailLabel: UILabel!
    
    private var purchaseManager = PurchaseManager()
    
    private let productIds = ["com.Jay.Calculendar.Premium.Yearly", "com.Jay.Calculendar.AdRemoval"]
    
    private var productPremiunYearly: Product? = nil
    private var productAdRemoval: Product? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                try await purchaseManager.loadProducts()
            } catch {
                print(error)
            }
            
            for product in purchaseManager.products {
                if product.id.contains("Premium.Yearly") {
                    productPremiunYearly = product
                } else if product.id.contains("AdRemoval") {
                    productAdRemoval = product
                }
                purchaseManager.printProductInfo(product)
            }
        }
        
        
        setMask()
        
        let subscription_Price = remoteConfig.configValue(forKey: RemoteConfigKeys.subscription_Price).stringValue ?? ""
        purchaseButton.setTitle(subscription_Price, for: .normal)
        
        let subscription_Detail = remoteConfig.configValue(forKey: RemoteConfigKeys.subscription_Detail).stringValue ?? ""
        subscription_DetailLabel.text = subscription_Detail
    }
    
    
    @IBAction func purchaseButtonAction(_ sender: Any) {
        print("구독 버튼 selected")
        purchaseActivityIndicatorView.startAnimating()
        Task {
            if productPremiunYearly != nil {
                do {
                    try await purchaseManager.purchase(productPremiunYearly!)
//                    self.navigationController?.popViewController(animated: true)
                } catch {
                    print(error)
                }
            }
            purchaseActivityIndicatorView.stopAnimating()
            purchaseFinished()
        }
        
    }
    
    func purchaseFinished() {
        if !UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) {
            let alert = UIAlertController(title: "구매가 완료되지 않았습니다", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                //  OK 버튼 누를시 실행될 내용
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            print("구매가 완료되지 않았습니다")
        } else {
            let alert = UIAlertController(title: "구매 완료", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                //  OK 버튼 누를시 실행될 내용
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            print("구매 완료")
            
        }
    }
    
    
    @IBAction func restoreButtonAction(_ sender: Any) {
        print("구매 내역 복원 selected")
        restoreActivityIndicatorView.startAnimating()
        Task {
            do {
                try await AppStore.sync()
                //  AppStore.sync() will be placed on the paywall under the list of available products to purchase. In the unusual case where the user has purchased a product, but the paywall is still showing, AppStore.sync() will update the transactions, the paywall will disappear, and the purchased in-app content will be available for the user to use.
                await purchaseManager.updatePurchasedProducts()
            } catch {
                print(error)
            }
            restoreActivityIndicatorView.stopAnimating()
            restoreFinished()
        }
        
    }
    
    func restoreFinished() {
        if !UserDefaults.standard.bool(forKey: SettingsKeys.AdRemoval) {
            let alert = UIAlertController(title: "구매 내역이 없습니다", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                //  OK 버튼 누를시 실행될 내용
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            print("구매 내역이 없습니다")
        } else {
            let alert = UIAlertController(title: "복원 되었습니다", message: "", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                //  OK 버튼 누를시 실행될 내용
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            print("복원 되었습니다")
            
        }
    }
    
    func setMask() {
        //  버튼 테두리 둥글게
        purchaseButton.layer.cornerRadius = 8
        purchaseButton.layer.masksToBounds = true
        restoreButton.layer.cornerRadius = 8
        restoreButton.layer.masksToBounds = true
    }
}
