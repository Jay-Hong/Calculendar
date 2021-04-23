import UIKit
import StoreKit
//import GoogleMobileAds

class AdRemovalViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var purchaseActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var restoreActivityIndicatorView: UIActivityIndicatorView!
    
    var myProduct: SKProduct?       // IAP
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchProducts()
        
        //  버튼 테두리 둥글게
        purchaseButton.layer.cornerRadius = 8
        purchaseButton.layer.masksToBounds = true
        restoreButton.layer.cornerRadius = 8
        restoreButton.layer.masksToBounds = true
    }
    
    
    @IBAction func purchaseButtonAction(_ sender: Any) {
        print("모든 광고 제거 selected")
        purchaseActivityIndicatorView.startAnimating()
        guard let myProduct = myProduct else {
            purchaseActivityIndicatorView.stopAnimating()
            return
        }
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: myProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    
    @IBAction func restoreButtonAction(_ sender: Any) {
        print("구매 내역 복원 selected")
        restoreActivityIndicatorView.startAnimating()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //MARK:  - IAP
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["com.Jay.Calculendar.AdRemoval"])
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            myProduct = product
            print(product.productIdentifier)
            print(product.priceLocale)
            print(product.price)
            print(product.localizedTitle)
            print(product.localizedDescription)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
          switch transaction.transactionState {
          case .purchased:
            print("Purchase Transaction Successful")
            UserDefaults.standard.set(true, forKey: SettingsKeys.AdRemoval)
            NotificationCenter.default.post(name: .didPurchaseAdRemoval, object: nil)
            SKPaymentQueue.default().finishTransaction(transaction)
            SKPaymentQueue.default().remove(self)
            purchaseActivityIndicatorView.stopAnimating()
            self.navigationController?.popViewController(animated: true)
            break
            case .restored:
            print("Restored")
            UserDefaults.standard.set(true, forKey: SettingsKeys.AdRemoval)
            NotificationCenter.default.post(name: .didPurchaseAdRemoval, object: nil)
            SKPaymentQueue.default().finishTransaction(transaction)
            SKPaymentQueue.default().remove(self)
            //  Restored 성공했을 경우 paymentQueueRestoreCompletedTransactionsFinished() 실행이 안되어 아랫줄 추가
            paymentQueueRestoreCompletedTransactionsFinished(queue)
            break
          case .failed:
            print("Transaction Failed")
            SKPaymentQueue.default().finishTransaction(transaction)
            SKPaymentQueue.default().remove(self)
            purchaseActivityIndicatorView.stopAnimating()
            break
          case .deferred:
            print("Deferred")
            SKPaymentQueue.default().finishTransaction(transaction)
            SKPaymentQueue.default().remove(self)
            break
          case .purchasing:
            print("Purchasing")
            // No OP
            break
          default:
            print("Unknown Default")
            SKPaymentQueue.default().finishTransaction(transaction)
            SKPaymentQueue.default().remove(self)
            break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        print("paymentQueueRestoreCompletedTransactionsFinished")
        restoreActivityIndicatorView.stopAnimating()
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

}
