import Foundation
import StoreKit

@MainActor
class PurchaseManager: NSObject, ObservableObject {
    
    private let productIds = ["com.Jay.Calculendar.Premium.Yearly", "com.Jay.Calculendar.AdRemoval"]
    
//    @Published
    private(set) var products: [Product] = []
//    @Published
    private(set) var purchasedProductIDs = Set<String>()
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil
    
    var hasUnlockedPremium: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
    override init() {
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        self.updates?.cancel()
    }
    
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                print("continue")
                continue
            }
            
            
            print("transaction.revocationDate : \(String(describing: transaction.revocationDate))")
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
                print("\n purchasedProductIDs.insert( \(transaction.productID) )  \n")
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
                print("\n purchasedProductIDs.remove( \(transaction.productID) )  \n")
            }
        }
        
        print("\n!self.purchasedProductIDs.isEmpty = \(!self.purchasedProductIDs.isEmpty)")
        print("hasUnlockedPremium = \(hasUnlockedPremium)")
        if hasUnlockedPremium {
            UserDefaults.standard.set(true, forKey: SettingsKeys.AdRemoval)
            print("\nSet AdRemoval UserDefaults to true\n")
        } else {
            UserDefaults.standard.set(false, forKey: SettingsKeys.AdRemoval)
            print("\nSet AdRemoval UserDefaults to false\n")
        }
        
        //        hasUnlockedPro ? UserDefaults.standard.set(true, forKey: SettingsKeys.AdRemoval) : UserDefaults.standard.set(false, forKey: SettingsKeys.AdRemoval)
        
        NotificationCenter.default.post(name: .didUpdatePurchasedProducts, object: nil)
    }
    
    
    func loadProducts() async throws {
        print("loadProducts()")
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }
    
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            print("\n purchase  -  .success(.verified(transaction)): \n")
            await transaction.finish()
            await self.updatePurchasedProducts()
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
    
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                print(" observeTransactionUpdates  Transaction.updates")
                await self.updatePurchasedProducts()
            }
        }
    }
    
    
    func printProductInfo(_ product: Product) {
        print(product.id)
        print(product.displayName)      //  광고제거
        print(product.displayPrice)     //  $14.99
        print(product.price)            //  14.99
        print(product.description)      //  앱 내의 모든 광고를 제거합니다
        print(product.type)             //  Auto-Renewable Subscription , Non-Consumable
        //        print(product.debugDescription) //  {모든관련사항 출력}
        //        print(product.subscription)
        //        print(product.currentEntitlement)
        print("\n")
    }
}

//  Supporting in-app purchases from the App Store
extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("\nupdatedTransactions\n")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("\nshouldAddStorePayment\n")
        return true
    }
}
